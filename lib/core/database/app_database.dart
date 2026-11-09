import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class CachedGrammar extends Table {
  TextColumn get namespace => text()();
  TextColumn get grammarId => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {namespace, grammarId};
}

class CachedQuestions extends Table {
  TextColumn get namespace => text()();
  TextColumn get questionId => text()();
  TextColumn get grammarId => text()();
  IntColumn get contentVersion => integer()();
  TextColumn get questionType => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {namespace, questionId};
}

class LocalNotes extends Table {
  TextColumn get namespace => text()();
  TextColumn get ownerId => text()();
  TextColumn get noteId => text()();
  TextColumn get grammarId => text()();
  TextColumn get content => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverRevision => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {namespace, ownerId, noteId};
}

class SyncOutbox extends Table {
  IntColumn get sequence => integer().autoIncrement()();
  TextColumn get namespace => text()();
  TextColumn get ownerId => text()();
  TextColumn get recordId => text()();
  TextColumn get payload => text()();
  TextColumn get entityTable => text().withDefault(const Constant('notes'))();
  TextColumn get operationId => text().withDefault(const Constant(''))();
  IntColumn get baseRevision => integer().nullable()();
  TextColumn get operationType =>
      text().withDefault(const Constant('upsert'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get conflictPayload => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

class PersonalRecords extends Table {
  TextColumn get namespace => text()();
  TextColumn get ownerId => text()();
  TextColumn get entityTable => text()();
  TextColumn get recordId => text()();
  TextColumn get payload => text()();
  IntColumn get serverRevision => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {namespace, ownerId, entityTable, recordId};
}

class LocalPracticeAttempts extends Table {
  TextColumn get namespace => text()();
  TextColumn get ownerId => text()();
  TextColumn get attemptId => text()();
  TextColumn get questionId => text()();
  TextColumn get grammarId => text()();
  IntColumn get contentVersion => integer()();
  TextColumn get sessionId => text()();
  TextColumn get retryOf => text().nullable()();
  TextColumn get answerText => text().withDefault(const Constant(''))();
  IntColumn get selectedOptionIndex => integer().nullable()();
  BoolColumn get isCorrect => boolean()();
  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();
  BoolColumn get isFirstIndependent => boolean()();
  DateTimeColumn get attemptedAt => dateTime()();
  DateTimeColumn get serverReceivedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {namespace, ownerId, attemptId};
}

class LocalReviewStates extends Table {
  TextColumn get namespace => text()();
  TextColumn get ownerId => text()();
  TextColumn get grammarId => text()();
  IntColumn get stage => integer().withDefault(const Constant(-1))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  IntColumn get algorithmVersion => integer().withDefault(const Constant(1))();
  TextColumn get lastAttemptId => text().nullable()();
  BoolColumn get isTentative => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {namespace, ownerId, grammarId};
}

@DriftDatabase(
  tables: [
    CachedGrammar,
    CachedQuestions,
    LocalNotes,
    SyncOutbox,
    PersonalRecords,
    LocalPracticeAttempts,
    LocalReviewStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'bunly'));
  @override
  int get schemaVersion => 3;

  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
    GeneratedColumn<Object> column,
  ) async {
    final rows = await customSelect(
      'PRAGMA table_info("${table.actualTableName}")',
    ).get();
    final exists = rows.any((row) => row.read<String>('name') == column.name);
    if (!exists) {
      await m.addColumn(table, column);
    }
  }

  Future<void> _createV3Indexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS cached_questions_grammar_idx ON cached_questions (namespace, grammar_id, content_version)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS local_practice_attempts_canonical_idx ON local_practice_attempts (namespace, owner_id, grammar_id, server_received_at, attempted_at, attempt_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS local_review_states_due_idx ON local_review_states (namespace, owner_id, due_at)',
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createV3Indexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _addColumnIfMissing(m, localNotes, localNotes.deletedAt);
        await _addColumnIfMissing(m, syncOutbox, syncOutbox.entityTable);
        await m.createTable(personalRecords);
      }
      if (from < 3) {
        await _addColumnIfMissing(m, localNotes, localNotes.serverRevision);
        await _addColumnIfMissing(
          m,
          personalRecords,
          personalRecords.serverRevision,
        );
        await _addColumnIfMissing(m, syncOutbox, syncOutbox.operationId);
        await _addColumnIfMissing(m, syncOutbox, syncOutbox.baseRevision);
        await _addColumnIfMissing(m, syncOutbox, syncOutbox.operationType);
        await _addColumnIfMissing(m, syncOutbox, syncOutbox.attempts);
        await _addColumnIfMissing(m, syncOutbox, syncOutbox.lastError);
        await _addColumnIfMissing(m, syncOutbox, syncOutbox.conflictPayload);
        await _addColumnIfMissing(m, syncOutbox, syncOutbox.createdAt);
        await m.createTable(cachedQuestions);
        await m.createTable(localPracticeAttempts);
        await m.createTable(localReviewStates);
        await _createV3Indexes();
      }
    },
  );
}
