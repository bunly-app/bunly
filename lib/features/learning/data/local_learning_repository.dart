import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../domain/learning_repository.dart';
import '../domain/note.dart';

class LocalLearningRepository implements LearningRepository {
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
                  t.grammarId.equals(grammarId),
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
              }),
            ),
          );
    }
  });
}
