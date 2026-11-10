import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';

abstract interface class LearningRemote {
  bool ownsSession(String ownerId);
  Future<void> upsert(String table, Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> fetch(String table, String ownerId);
}

class SupabaseLearningRemote implements LearningRemote {
  SupabaseLearningRemote(
    this.authClient, {
    required String url,
    required String key,
    required String ownerId,
  }) : client = SupabaseClient(
         url,
         key,
         accessToken: () async {
           final session = authClient.auth.currentSession;
           if (session == null || session.user.id != ownerId) {
             throw StateError('Session owner changed');
           }
           // Capture the owner's token for this request, never a new user's token.
           return session.accessToken;
         },
       );
  final SupabaseClient authClient;
  final SupabaseClient client;
  Future<void> dispose() => client.dispose();
  @override
  bool ownsSession(String ownerId) =>
      authClient.auth.currentSession != null &&
      authClient.auth.currentUser?.id == ownerId;
  @override
  Future<void> upsert(String table, Map<String, dynamic> payload) async {
    final conflict = switch (table) {
      'profiles' => 'user_id',
      'notes' => 'id',
      _ => 'user_id,grammar_id',
    };
    await client.from(table).upsert(payload, onConflict: conflict);
  }

  @override
  Future<List<Map<String, dynamic>>> fetch(String table, String ownerId) async {
    final result = <Map<String, dynamic>>[];
    for (var start = 0; ; start += 500) {
      final rows = await client
          .from(table)
          .select()
          .eq('user_id', ownerId)
          .order(
            table == 'notes'
                ? 'id'
                : table == 'profiles'
                ? 'user_id'
                : 'grammar_id',
          )
          .range(start, start + 499);
      result.addAll(rows);
      if (rows.length < 500) return result;
    }
  }
}

/// Single-device sync for M2 personal entities. Pending local writes take
/// priority over pull. Practice attempts & revision conflict RPCs use the
/// extended Drift v3 columns cleanly alongside this worker.
class LearningSync {
  LearningSync(
    this.database,
    this.remote, {
    required this.namespace,
    required this.ownerId,
  });
  final AppDatabase database;
  final LearningRemote remote;
  final String namespace;
  final String ownerId;
  bool _active = true;
  Future<void>? _running;
  void stop() => _active = false;
  bool get _valid => _active && remote.ownsSession(ownerId);
  void _requireSession() {
    if (!_valid) {
      throw StateError(
        'Phiên đăng nhập đã thay đổi. Dữ liệu chờ vẫn được giữ trên máy.',
      );
    }
  }

  Future<void> run() {
    if (_running != null) return _running!;
    return _running = _run().whenComplete(() => _running = null);
  }

  Future<void> _run() async {
    _requireSession();
    const m2Tables = ['profiles', 'notes', 'saved_grammar', 'progress'];
    // Snapshot means writes added during this run remain queued for the next run.
    final operations =
        await (database.select(database.syncOutbox)
              ..where(
                (r) =>
                    r.namespace.equals(namespace) &
                    r.ownerId.equals(ownerId) &
                    r.entityTable.isIn(m2Tables),
              )
              ..orderBy([(r) => OrderingTerm.asc(r.sequence)]))
            .get();
    final hasPendingNotePush = operations.any(
      (op) => op.entityTable == 'notes' && op.conflictPayload == null,
    );
    final preSyncRemoteNotes = <String, Map<String, dynamic>>{};
    if (hasPendingNotePush) {
      _requireSession();
      final existingRemoteNotes = await remote.fetch('notes', ownerId);
      for (final row in existingRemoteNotes) {
        final id = row['id'];
        if (id is String) {
          preSyncRemoteNotes[id] = row;
        }
      }
    }

    final conflictedNoteIds = <String>{
      for (final op in operations)
        if (op.entityTable == 'notes' && op.conflictPayload != null)
          op.recordId,
    };

    for (final operation in operations) {
      _requireSession();
      if (operation.conflictPayload != null) {
        continue;
      }
      if (operation.entityTable == 'notes' &&
          conflictedNoteIds.contains(operation.recordId)) {
        continue;
      }
      final payload = jsonDecode(operation.payload) as Map<String, dynamic>;
      if (payload['user_id'] != ownerId ||
          !m2Tables.contains(operation.entityTable)) {
        throw StateError('Thao tác đồng bộ không hợp lệ.');
      }

      if (operation.entityTable == 'notes') {
        final remoteRow = preSyncRemoteNotes[operation.recordId];
        final forceResolve = payload['force_resolve'] == true;
        final isDeleteTombstone = payload['deleted_at'] != null;
        if (remoteRow != null && !forceResolve && !isDeleteTombstone) {
          final localContent = payload['content'] as String? ?? '';
          final remoteContent = remoteRow['content'] as String? ?? '';
          final baseContent = payload['base_content'] as String?;
          final localUpdatedAt = DateTime.tryParse(
            payload['updated_at'] as String? ?? '',
          )?.toUtc();
          final remoteUpdatedAt = DateTime.tryParse(
            remoteRow['updated_at'] as String? ?? '',
          )?.toUtc();
          final remoteRevision = (remoteRow['revision'] as num?)?.toInt() ?? 0;
          final baseRevision = operation.baseRevision ?? 0;

          final hasDivergentBase =
              baseContent != null && remoteContent != baseContent;
          final hasNewerRemoteRevision =
              baseRevision > 0 && remoteRevision > baseRevision;
          final hasNewerRemoteTimestamp =
              localUpdatedAt != null &&
              remoteUpdatedAt != null &&
              remoteUpdatedAt.isAfter(localUpdatedAt);

          if (remoteContent != localContent &&
              (hasDivergentBase ||
                  hasNewerRemoteRevision ||
                  hasNewerRemoteTimestamp)) {
            conflictedNoteIds.add(operation.recordId);
            await (database.update(database.syncOutbox)..where(
                  (r) =>
                      r.sequence.equals(operation.sequence) &
                      r.ownerId.equals(ownerId) &
                      r.namespace.equals(namespace),
                ))
                .write(
                  SyncOutboxCompanion(
                    lastError: const Value('conflict'),
                    conflictPayload: Value(jsonEncode(remoteRow)),
                  ),
                );
            continue;
          }
        }
      }

      final remotePayload = Map<String, dynamic>.of(payload)
        ..remove('base_content')
        ..remove('force_resolve');
      await remote.upsert(operation.entityTable, remotePayload);
      _requireSession();
      // Delete exactly this operation, never newer operations for the same record.
      await (database.delete(database.syncOutbox)..where(
            (r) =>
                r.sequence.equals(operation.sequence) &
                r.ownerId.equals(ownerId) &
                r.namespace.equals(namespace),
          ))
          .go();
    }
    for (final table in m2Tables) {
      _requireSession();
      final rows = await remote.fetch(table, ownerId);
      _requireSession();
      await database.transaction(() async {
        _requireSession();
        final pending =
            await (database.select(database.syncOutbox)..where(
                  (r) =>
                      r.namespace.equals(namespace) &
                      r.ownerId.equals(ownerId) &
                      r.entityTable.equals(table),
                ))
                .get();
        final protectedIds = pending.map((r) => r.recordId).toSet();
        for (final row in rows) {
          if (row['user_id'] != ownerId) {
            throw StateError('Sai chủ sở hữu dữ liệu.');
          }
          final id =
              (table == 'notes'
                      ? row['id']
                      : table == 'profiles'
                      ? row['user_id']
                      : row['grammar_id'])
                  as String;
          if (protectedIds.contains(id)) continue;
          if (table == 'notes') {
            await database
                .into(database.localNotes)
                .insertOnConflictUpdate(
                  LocalNotesCompanion.insert(
                    namespace: namespace,
                    ownerId: ownerId,
                    noteId: id,
                    grammarId: row['grammar_id'] as String,
                    content: row['content'] as String,
                    updatedAt: DateTime.parse(row['updated_at'] as String),
                    deletedAt: Value(
                      row['deleted_at'] == null
                          ? null
                          : DateTime.parse(row['deleted_at'] as String),
                    ),
                    serverRevision: const Value(1),
                  ),
                );
          } else {
            await database
                .into(database.personalRecords)
                .insertOnConflictUpdate(
                  PersonalRecordsCompanion.insert(
                    namespace: namespace,
                    ownerId: ownerId,
                    entityTable: table,
                    recordId: id,
                    payload: jsonEncode(row),
                  ),
                );
          }
        }
      });
    }
  }
}
