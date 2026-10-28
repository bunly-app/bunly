import 'dart:async';
import 'dart:convert';
import 'package:bunly/core/database/app_database.dart';
import 'package:bunly/features/learning/data/learning_sync.dart';
import 'package:bunly/features/learning/data/local_learning_repository.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:bunly/features/learning/domain/personal_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledRemote implements LearningRemote {
  String user = 'A';
  bool offline = false;
  bool failAfterCommit = false;
  Future<void> Function()? duringUpsert;
  Future<void> Function()? duringFetch;
  int calls = 0;
  final rows = <String, Map<String, Map<String, dynamic>>>{};
  @override
  bool ownsSession(String ownerId) => user == ownerId;
  @override
  Future<void> upsert(String table, Map<String, dynamic> payload) async {
    calls++;
    if (offline) throw StateError('offline');
    final id =
        (table == 'notes'
                ? payload['id']
                : table == 'profiles'
                ? payload['user_id']
                : payload['grammar_id'])
            as String;
    rows.putIfAbsent(table, () => {})[id] = Map.of(payload);
    await duringUpsert?.call();
    if (failAfterCommit) throw TimeoutException('response lost after commit');
  }

  @override
  Future<List<Map<String, dynamic>>> fetch(String table, String ownerId) async {
    if (offline) throw StateError('offline');
    // Capture snapshot before concurrent local edits, matching a real HTTP response.
    final snapshot = (rows[table]?.values ?? [])
        .map((r) => Map<String, dynamic>.of(r))
        .toList();
    await duringFetch?.call();
    return snapshot;
  }
}

void main() {
  late AppDatabase db;
  late LocalLearningRepository repository;
  late ControlledRemote remote;
  late LearningSync sync;
  Note note(String content) => Note(
    id: 'n',
    grammarId: 'g',
    content: content,
    updatedAt: DateTime.utc(2026),
  );
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = LocalLearningRepository(
      db,
      namespace: 'test',
      ownerId: 'A',
      queueRemote: true,
    );
    remote = ControlledRemote();
    sync = LearningSync(db, remote, namespace: 'test', ownerId: 'A');
  });
  tearDown(() async => db.close());

  test(
    'saved/profile/status persist, duplicate saves do not duplicate records; owner is isolated',
    () async {
      await repository.setSaved('g', true);
      await repository.setSaved('g', true);
      await repository.setStatus('g', LearningStatus.review);
      await UpdateLearning(
        repository,
      ).saveProfile(const UserProfile(displayName: ' Hoàng ', goal: ' N4 '));
      expect((await repository.watchSummary().first).saved, {'g'});
      expect(
        (await repository.watchSummary().first).statusOf('g'),
        LearningStatus.review,
      );
      expect((await repository.watchProfile().first).displayName, 'Hoàng');
      final other = LocalLearningRepository(
        db,
        namespace: 'test',
        ownerId: 'B',
        queueRemote: true,
      );
      expect((await other.watchSummary().first).saved, isEmpty);
      expect((await other.watchProfile().first).displayName, isEmpty);
      await repository.setSaved('g', false);
      expect((await repository.watchSummary().first).saved, isEmpty);
    },
  );
  test('invalid profile does not write or enqueue', () async {
    expect(
      () => UpdateLearning(
        repository,
      ).saveProfile(const UserProfile(dailyMinutes: 0)),
      throwsFormatException,
    );
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });
  test('personal record rolls back if outbox insert fails', () async {
    await db.customStatement(
      "CREATE TRIGGER fail_personal_outbox BEFORE INSERT ON sync_outbox BEGIN SELECT RAISE(ABORT, 'fail'); END;",
    );
    await expectLater(repository.setSaved('g', true), throwsA(anything));
    expect((await repository.watchSummary().first).saved, isEmpty);
  });
  test('deleting another owners note does not create an operation', () async {
    await repository.saveNote(note('private'));
    final other = LocalLearningRepository(
      db,
      namespace: 'test',
      ownerId: 'B',
      queueRemote: true,
    );
    await other.deleteNote('n');
    expect((await repository.watchNotes('g').first).single.content, 'private');
    expect((await db.select(db.syncOutbox).get()).length, 1);
  });
  test(
    'offline preserves queue; retry after remote commit is idempotent and pulls tombstones',
    () async {
      await repository.saveNote(note('old'));
      remote.offline = true;
      await expectLater(sync.run(), throwsStateError);
      expect(await db.select(db.syncOutbox).get(), hasLength(1));
      remote.offline = false;
      remote.failAfterCommit = true;
      await expectLater(sync.run(), throwsA(isA<TimeoutException>()));
      expect(await db.select(db.syncOutbox).get(), hasLength(1));
      remote.failAfterCommit = false;
      await sync.run();
      expect(remote.rows['notes'], hasLength(1));
      expect(await db.select(db.syncOutbox).get(), isEmpty);
      await repository.saveNote(note('edited'));
      await repository.deleteNote('n');
      expect(await repository.watchNotes('g').first, isEmpty);
      await sync.run();
      expect(remote.rows['notes']!['n']!['deleted_at'], isNotNull);
      expect(await repository.watchNotes('g').first, isEmpty);
    },
  );
  test(
    'old acknowledgment never removes a newer local edit; pull protects pending edit',
    () async {
      await repository.saveNote(note('old'));
      remote.duringUpsert = () async {
        remote.duringUpsert = null;
        await repository.saveNote(note('new'));
      };
      await sync.run();
      expect((await repository.watchNotes('g').first).single.content, 'new');
      final pending = await db.select(db.syncOutbox).get();
      expect(pending, hasLength(1));
      expect((jsonDecode(pending.single.payload) as Map)['content'], 'new');
      await sync.run();
      expect(remote.rows['notes']!['n']!['content'], 'new');
    },
  );
  test('edit during pull wins over stale server response', () async {
    await repository.saveNote(note('old'));
    await sync.run();
    remote.duringFetch = () async {
      remote.duringFetch = null;
      await repository.saveNote(note('new'));
    };
    await sync.run();
    expect((await repository.watchNotes('g').first).single.content, 'new');
    expect(await db.select(db.syncOutbox).get(), hasLength(1));
  });
  test(
    'session switch during request preserves queue and prevents subsequent sends',
    () async {
      await repository.saveNote(note('A only'));
      await repository.setSaved('g', true);
      remote.duringUpsert = () async => remote.user = 'B';
      await expectLater(sync.run(), throwsStateError);
      expect(remote.calls, 1);
      expect(await db.select(db.syncOutbox).get(), hasLength(2));
      await expectLater(sync.run(), throwsStateError);
      expect(remote.calls, 1);
    },
  );
  test(
    'overlapping runs share one request; stopped worker does not send',
    () async {
      await repository.saveNote(note('one'));
      final gate = Completer<void>();
      remote.duringUpsert = () => gate.future;
      final first = sync.run();
      final second = sync.run();
      gate.complete();
      await Future.wait([first, second]);
      expect(remote.calls, 1);
      sync.stop();
      await expectLater(sync.run(), throwsStateError);
    },
  );
  test('migration v1 preserves legacy note and pending operation', () async {
    await db.close();
    db = AppDatabase(
      NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute(
            'CREATE TABLE cached_grammar (namespace TEXT NOT NULL, grammar_id TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(namespace, grammar_id))',
          );
          sqlite.execute(
            'CREATE TABLE local_notes (namespace TEXT NOT NULL, owner_id TEXT NOT NULL, note_id TEXT NOT NULL, grammar_id TEXT NOT NULL, content TEXT NOT NULL, updated_at INTEGER NOT NULL, PRIMARY KEY(namespace, owner_id, note_id))',
          );
          sqlite.execute(
            'CREATE TABLE sync_outbox (sequence INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, namespace TEXT NOT NULL, owner_id TEXT NOT NULL, record_id TEXT NOT NULL, payload TEXT NOT NULL)',
          );
          sqlite.execute(
            "INSERT INTO local_notes VALUES ('test','A','n','g','legacy',1767225600)",
          );
          sqlite.execute(
            "INSERT INTO sync_outbox(namespace,owner_id,record_id,payload) VALUES ('test','A','n','{}')",
          );
          sqlite.execute('PRAGMA user_version = 1');
        },
      ),
    );
    final migrated = LocalLearningRepository(
      db,
      namespace: 'test',
      ownerId: 'A',
      queueRemote: true,
    );
    expect((await migrated.watchNotes('g').first).single.content, 'legacy');
    expect((await db.select(db.syncOutbox).get()).single.entityTable, 'notes');
    await migrated.setSaved('g', true);
    expect((await migrated.watchSummary().first).saved, {'g'});
  });
}
