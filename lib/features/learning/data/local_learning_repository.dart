import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/learning_repository.dart';
import '../domain/note.dart';
import '../domain/personal_repository.dart';

class LocalLearningRepository
    implements LearningRepository, PersonalRepository {
  LocalLearningRepository(
    this.database, {
    required this.namespace,
    required this.ownerId,
    required this.queueRemote,
  });
  static const Uuid _uuid = Uuid();
  final AppDatabase database;
  final String namespace;
  final String ownerId;
  final bool queueRemote;

  @override
  Stream<List<Note>> watchNotes(String grammarId) => _watchNotes(grammarId);

  @override
  Stream<List<Note>> watchAllNotes() => _watchNotes(null);

  Stream<List<Note>> _watchNotes(String? grammarId) =>
      (database.select(database.localNotes)
            ..where(
              (t) =>
                  t.namespace.equals(namespace) &
                  t.ownerId.equals(ownerId) &
                  (grammarId == null
                      ? const Constant(true)
                      : t.grammarId.equals(grammarId)) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => Note(
                    id: row.noteId,
                    grammarId: row.grammarId,
                    content: row.content,
                    updatedAt: row.updatedAt,
                  ),
                )
                .toList(),
          );

  @override
  Future<void> saveNote(Note note) => database.transaction(() async {
    final existing =
        await (database.select(database.localNotes)..where(
              (t) =>
                  t.namespace.equals(namespace) &
                  t.ownerId.equals(ownerId) &
                  t.noteId.equals(note.id),
            ))
            .getSingleOrNull();
    final pendingRows =
        await (database.select(database.syncOutbox)
              ..where(
                (t) =>
                    t.namespace.equals(namespace) &
                    t.ownerId.equals(ownerId) &
                    t.entityTable.equals('notes') &
                    t.recordId.equals(note.id),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
            .get();

    String? baseContent;
    if (pendingRows.isNotEmpty) {
      try {
        final firstPayload =
            jsonDecode(pendingRows.first.payload) as Map<String, dynamic>;
        baseContent = firstPayload['base_content'] as String?;
      } catch (_) {}
    } else if (existing != null && existing.serverRevision > 0) {
      baseContent = existing.content;
    }

    final baseRevision = existing?.serverRevision ?? 0;

    await database
        .into(database.localNotes)
        .insertOnConflictUpdate(
          LocalNotesCompanion.insert(
            namespace: namespace,
            ownerId: ownerId,
            noteId: note.id,
            grammarId: note.grammarId,
            content: note.content,
            updatedAt: note.updatedAt,
            deletedAt: const Value(null),
            serverRevision: Value(baseRevision),
          ),
        );
    if (queueRemote) {
      final now = DateTime.now().toUtc();
      await database
          .into(database.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              namespace: namespace,
              ownerId: ownerId,
              recordId: note.id,
              operationId: Value(_uuid.v4()),
              baseRevision: Value(baseRevision),
              operationType: const Value('upsert'),
              createdAt: Value(now),
              payload: jsonEncode({
                'id': note.id,
                'user_id': ownerId,
                'grammar_id': note.grammarId,
                'content': note.content,
                'updated_at': note.updatedAt.toUtc().toIso8601String(),
                'deleted_at': null,
                if (baseContent != null) 'base_content': baseContent,
              }),
            ),
          );
    }
  });

  Stream<List<NoteConflict>> watchNoteConflicts() {
    final outboxStream =
        (database.select(database.syncOutbox)
              ..where(
                (t) =>
                    t.namespace.equals(namespace) &
                    t.ownerId.equals(ownerId) &
                    t.entityTable.equals('notes') &
                    t.conflictPayload.isNotNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.sequence)]))
            .watch();

    return outboxStream.asyncMap((rows) async {
      if (rows.isEmpty) return const <NoteConflict>[];
      final localRows =
          await (database.select(database.localNotes)..where(
                (t) =>
                    t.namespace.equals(namespace) & t.ownerId.equals(ownerId),
              ))
              .get();
      final localById = {for (final r in localRows) r.noteId: r};
      final seenNoteIds = <String>{};
      final conflicts = <NoteConflict>[];

      for (final row in rows) {
        if (!seenNoteIds.add(row.recordId)) continue;
        final rawConflict = row.conflictPayload;
        if (rawConflict == null) continue;
        try {
          final remoteMap = jsonDecode(rawConflict) as Map<String, dynamic>;
          final localPayload = jsonDecode(row.payload) as Map<String, dynamic>;
          final localRow = localById[row.recordId];
          final grammarId =
              localRow?.grammarId ??
              (remoteMap['grammar_id'] as String?) ??
              (localPayload['grammar_id'] as String?) ??
              '';
          final localContent =
              localRow?.content ?? (localPayload['content'] as String?) ?? '';
          final localUpdatedAt =
              localRow?.updatedAt.toUtc() ??
              DateTime.tryParse(
                localPayload['updated_at'] as String? ?? '',
              )?.toUtc() ??
              DateTime.now().toUtc();
          final remoteContent = remoteMap['content'] as String? ?? '';
          final remoteUpdatedAt =
              DateTime.tryParse(
                remoteMap['updated_at'] as String? ?? '',
              )?.toUtc() ??
              localUpdatedAt;

          conflicts.add(
            NoteConflict(
              noteId: row.recordId,
              grammarId: grammarId,
              localContent: localContent,
              localUpdatedAt: localUpdatedAt,
              remoteContent: remoteContent,
              remoteUpdatedAt: remoteUpdatedAt,
            ),
          );
        } catch (_) {}
      }
      return List.unmodifiable(conflicts);
    });
  }

  Future<void> resolveNoteConflict(String noteId, {required bool keepLocal}) =>
      database.transaction(() async {
        final outboxRows =
            await (database.select(database.syncOutbox)
                  ..where(
                    (t) =>
                        t.namespace.equals(namespace) &
                        t.ownerId.equals(ownerId) &
                        t.entityTable.equals('notes') &
                        t.recordId.equals(noteId),
                  )
                  ..orderBy([(t) => OrderingTerm.desc(t.sequence)]))
                .get();
        final localRow =
            await (database.select(database.localNotes)..where(
                  (t) =>
                      t.namespace.equals(namespace) &
                      t.ownerId.equals(ownerId) &
                      t.noteId.equals(noteId),
                ))
                .getSingleOrNull();

        Map<String, dynamic>? conflictMap;
        for (final row in outboxRows) {
          if (row.conflictPayload != null) {
            try {
              conflictMap =
                  jsonDecode(row.conflictPayload!) as Map<String, dynamic>;
              break;
            } catch (_) {}
          }
        }

        await (database.delete(database.syncOutbox)..where(
              (t) =>
                  t.namespace.equals(namespace) &
                  t.ownerId.equals(ownerId) &
                  t.entityTable.equals('notes') &
                  t.recordId.equals(noteId),
            ))
            .go();

        final nowUtc = DateTime.now().toUtc();
        if (keepLocal) {
          if (localRow == null) return;
          await database
              .into(database.localNotes)
              .insertOnConflictUpdate(
                LocalNotesCompanion.insert(
                  namespace: namespace,
                  ownerId: ownerId,
                  noteId: localRow.noteId,
                  grammarId: localRow.grammarId,
                  content: localRow.content,
                  updatedAt: nowUtc,
                  deletedAt: const Value(null),
                  serverRevision: const Value(1),
                ),
              );
          if (queueRemote) {
            await database
                .into(database.syncOutbox)
                .insert(
                  SyncOutboxCompanion.insert(
                    namespace: namespace,
                    ownerId: ownerId,
                    recordId: localRow.noteId,
                    operationId: Value(_uuid.v4()),
                    baseRevision: const Value(1),
                    operationType: const Value('upsert'),
                    createdAt: Value(nowUtc),
                    payload: jsonEncode({
                      'id': localRow.noteId,
                      'user_id': ownerId,
                      'grammar_id': localRow.grammarId,
                      'content': localRow.content,
                      'updated_at': nowUtc.toIso8601String(),
                      'deleted_at': null,
                      'force_resolve': true,
                    }),
                  ),
                );
          }
        } else if (conflictMap != null) {
          final grammarId =
              (conflictMap['grammar_id'] as String?) ??
              localRow?.grammarId ??
              '';
          final remoteContent = conflictMap['content'] as String? ?? '';
          final remoteUpdatedAt =
              DateTime.tryParse(
                conflictMap['updated_at'] as String? ?? '',
              )?.toUtc() ??
              nowUtc;
          await database
              .into(database.localNotes)
              .insertOnConflictUpdate(
                LocalNotesCompanion.insert(
                  namespace: namespace,
                  ownerId: ownerId,
                  noteId: noteId,
                  grammarId: grammarId,
                  content: remoteContent,
                  updatedAt: remoteUpdatedAt,
                  deletedAt: const Value(null),
                  serverRevision: const Value(1),
                ),
              );
        }
      });

  Future<void> simulateNoteConflict(Note note, {String? remoteContent}) =>
      database.transaction(() async {
        final nowUtc = DateTime.now().toUtc();
        final simulatedRemote = {
          'id': note.id,
          'user_id': ownerId,
          'grammar_id': note.grammarId,
          'content':
              remoteContent ??
              '${note.content}\n[Bản cập nhật từ thiết bị thứ 2 trên Cloud]',
          'updated_at': nowUtc
              .add(const Duration(minutes: 2))
              .toIso8601String(),
          'revision': 2,
        };
        await (database.delete(database.syncOutbox)..where(
              (t) =>
                  t.namespace.equals(namespace) &
                  t.ownerId.equals(ownerId) &
                  t.entityTable.equals('notes') &
                  t.recordId.equals(note.id),
            ))
            .go();
        await database
            .into(database.syncOutbox)
            .insert(
              SyncOutboxCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                recordId: note.id,
                operationId: Value(_uuid.v4()),
                baseRevision: const Value(1),
                operationType: const Value('upsert'),
                lastError: const Value('conflict'),
                conflictPayload: Value(jsonEncode(simulatedRemote)),
                createdAt: Value(nowUtc),
                payload: jsonEncode({
                  'id': note.id,
                  'user_id': ownerId,
                  'grammar_id': note.grammarId,
                  'content': note.content,
                  'updated_at': note.updatedAt.toUtc().toIso8601String(),
                  'deleted_at': null,
                  'base_content': note.content,
                }),
              ),
            );
      });

  Future<void> _write(
    String table,
    String id,
    Map<String, dynamic> payload, {
    String operationType = 'upsert',
  }) => database.transaction(() async {
    final existing =
        await (database.select(database.personalRecords)..where(
              (t) =>
                  t.namespace.equals(namespace) &
                  t.ownerId.equals(ownerId) &
                  t.entityTable.equals(table) &
                  t.recordId.equals(id),
            ))
            .getSingleOrNull();
    final baseRevision = existing?.serverRevision ?? 0;

    await database
        .into(database.personalRecords)
        .insertOnConflictUpdate(
          PersonalRecordsCompanion.insert(
            namespace: namespace,
            ownerId: ownerId,
            entityTable: table,
            recordId: id,
            payload: jsonEncode(payload),
            serverRevision: Value(baseRevision),
          ),
        );
    await _enqueue(
      table,
      id,
      payload,
      baseRevision: baseRevision,
      operationType: operationType,
    );
  });

  Future<void> _enqueue(
    String table,
    String id,
    Map<String, dynamic> payload, {
    int? baseRevision,
    String operationType = 'upsert',
  }) async {
    if (!queueRemote) return;
    await database
        .into(database.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            namespace: namespace,
            ownerId: ownerId,
            recordId: id,
            entityTable: Value(table),
            operationId: Value(_uuid.v4()),
            baseRevision: Value(baseRevision),
            operationType: Value(operationType),
            createdAt: Value(DateTime.now().toUtc()),
            payload: jsonEncode(payload),
          ),
        );
  }

  Stream<List<PersonalRecord>> _records(String table) =>
      (database.select(database.personalRecords)..where(
            (r) =>
                r.namespace.equals(namespace) &
                r.ownerId.equals(ownerId) &
                r.entityTable.equals(table),
          ))
          .watch();

  @override
  Stream<UserProfile> watchProfile() => _records('profiles').map((rows) {
    if (rows.isEmpty) return const UserProfile();
    final p = jsonDecode(rows.first.payload) as Map<String, dynamic>;
    return UserProfile(
      displayName: p['display_name'] as String,
      level: p['jlpt_level'] as String,
      goal: p['goal'] as String,
      dailyMinutes: p['daily_minutes'] as int,
    );
  });

  @override
  Future<void> saveProfile(UserProfile profile) => _write('profiles', ownerId, {
    'user_id': ownerId,
    'display_name': profile.displayName,
    'jlpt_level': profile.level,
    'goal': profile.goal,
    'daily_minutes': profile.dailyMinutes,
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  });

  @override
  Stream<LearningSummary> watchSummary() =>
      (database.select(database.personalRecords)..where(
            (r) => r.namespace.equals(namespace) & r.ownerId.equals(ownerId),
          ))
          .watch()
          .map((rows) {
            final saved = <String>{};
            final statuses = <String, LearningStatus>{};
            for (final row in rows) {
              final p = jsonDecode(row.payload) as Map<String, dynamic>;
              if (row.entityTable == 'saved_grammar' &&
                  p['deleted_at'] == null) {
                saved.add(row.recordId);
              }
              if (row.entityTable == 'progress') {
                statuses[row.recordId] = LearningStatus.parse(
                  p['status'] as String?,
                );
              }
            }
            return LearningSummary(saved, statuses);
          });

  @override
  Future<void> setSaved(String grammarId, bool saved) =>
      _write('saved_grammar', grammarId, {
        'user_id': ownerId,
        'grammar_id': grammarId,
        'deleted_at': saved ? null : DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, operationType: saved ? 'upsert' : 'delete');

  @override
  Future<void> setStatus(String grammarId, LearningStatus status) =>
      _write('progress', grammarId, {
        'user_id': ownerId,
        'grammar_id': grammarId,
        'status': status.value,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

  @override
  Future<void> deleteNote(String noteId) => database.transaction(() async {
    final query = database.select(database.localNotes)
      ..where(
        (r) =>
            r.namespace.equals(namespace) &
            r.ownerId.equals(ownerId) &
            r.noteId.equals(noteId),
      );
    final note = await query.getSingleOrNull();
    if (note == null) return;
    final now = DateTime.now().toUtc();
    await (database.update(database.localNotes)..where(
          (r) =>
              r.namespace.equals(namespace) &
              r.ownerId.equals(ownerId) &
              r.noteId.equals(noteId),
        ))
        .write(
          LocalNotesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
    await _enqueue(
      'notes',
      noteId,
      {
        'id': noteId,
        'user_id': ownerId,
        'grammar_id': note.grammarId,
        'content': note.content,
        'updated_at': now.toIso8601String(),
        'deleted_at': now.toIso8601String(),
      },
      baseRevision: note.serverRevision,
      operationType: 'delete',
    );
  });
}
