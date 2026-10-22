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
  @override
  Set<Column> get primaryKey => {namespace, ownerId, noteId};
}

class SyncOutbox extends Table {
  IntColumn get sequence => integer().autoIncrement()();
  TextColumn get namespace => text()();
  TextColumn get ownerId => text()();
  TextColumn get recordId => text()();
  TextColumn get payload => text()();
}

@DriftDatabase(tables: [CachedGrammar, LocalNotes, SyncOutbox])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'bunly'));
  @override
  int get schemaVersion => 1;
}
