import 'dart:convert';

import 'package:drift/drift.dart';

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
  final AppDatabase database;
  final String namespace;
  final String ownerId;
  final bool queueRemote;

  @override
  Stream<List<Note>> watchNotes(String grammarId) =>
      (database.select(database.localNotes)
            ..where(
              (t) =>
                  t.namespace.equals(namespace) &
                  t.ownerId.equals(ownerId) &
                  t.grammarId.equals(grammarId) &
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
          ),
        );
    if (queueRemote) {
      await database
          .into(database.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              namespace: namespace,
              ownerId: ownerId,
              recordId: note.id,
              payload: jsonEncode({
                'id': note.id,
                'user_id': ownerId,
                'grammar_id': note.grammarId,
                'content': note.content,
                'updated_at': note.updatedAt.toUtc().toIso8601String(),
                'deleted_at': null,
              }),
            ),
          );
    }
  });

  Future<void> _write(String table, String id, Map<String, dynamic> payload) =>
      database.transaction(() async {
        await database
            .into(database.personalRecords)
            .insertOnConflictUpdate(
              PersonalRecordsCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                entityTable: table,
                recordId: id,
                payload: jsonEncode(payload),
              ),
            );
        await _enqueue(table, id, payload);
      });

  Future<void> _enqueue(
    String table,
    String id,
    Map<String, dynamic> payload,
  ) async {
    if (!queueRemote) return;
    await database
        .into(database.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            namespace: namespace,
            ownerId: ownerId,
            recordId: id,
            entityTable: Value(table),
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
      });

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
    await _enqueue('notes', noteId, {
      'id': noteId,
      'user_id': ownerId,
      'grammar_id': note.grammarId,
      'content': note.content,
      'updated_at': now.toIso8601String(),
      'deleted_at': now.toIso8601String(),
    });
  });
}
