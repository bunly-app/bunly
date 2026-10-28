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

class LocalNotes extends Table {
  TextColumn get namespace => text()();
  TextColumn get ownerId => text()();
  TextColumn get noteId => text()();
  TextColumn get grammarId => text()();
  TextColumn get content => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
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
}

class PersonalRecords extends Table {
  TextColumn get namespace => text()();
  TextColumn get ownerId => text()();
  TextColumn get entityTable => text()();
  TextColumn get recordId => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {namespace, ownerId, entityTable, recordId};
}

@DriftDatabase(tables: [CachedGrammar, LocalNotes, SyncOutbox, PersonalRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'bunly'));
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(localNotes, localNotes.deletedAt);
        await m.addColumn(syncOutbox, syncOutbox.entityTable);
        await m.createTable(personalRecords);
      }
    },
  );
}
