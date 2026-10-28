import 'dart:io';
import 'package:bunly/core/database/app_database.dart';
import 'package:bunly/features/grammar/data/cached_grammar_repository.dart';
import 'package:bunly/features/grammar/data/grammar_sources.dart';
import 'package:bunly/features/learning/data/local_learning_repository.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledSource implements GrammarSource {
  bool offline = false;
  List<Map<String, dynamic>> rows = [
    {
      'id': 'g',
      'pattern': '〜たい',
      'level': 'N5',
      'category': 'desire',
      'meaning_vi': 'Muốn',
      'formula': 'x',
      'usage_vi': 'x',
      'grammar_examples': [],
    },
  ];
  @override
  Future<List<Map<String, dynamic>>> fetch() async {
    if (offline) throw const SocketException('offline');
    return rows;
  }
}

void main() {
  late AppDatabase database;
  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await database.close();
  });
  Note note(String id, String text) => Note(
    id: id,
    grammarId: 'g',
    content: text,
    updatedAt: DateTime.utc(2026),
  );
  LocalLearningRepository learning(
    String owner, {
    String namespace = 'backend',
  }) => LocalLearningRepository(
    database,
    namespace: namespace,
    ownerId: owner,
    queueRemote: true,
  );

  test(
    'note and outbox commit together and remain scoped to owner and backend',
    () async {
      await learning('A').saveNote(note('n', 'private A'));
      expect(
        (await learning('A').watchNotes('g').first).single.content,
        'private A',
      );
      expect(await learning('B').watchNotes('g').first, isEmpty);
      expect(
        await learning('A', namespace: 'another-backend').watchNotes('g').first,
        isEmpty,
      );
      expect(
        (await database.select(database.syncOutbox).get()).single.ownerId,
        'A',
      );
    },
  );
  test('outbox failure rolls back the note write', () async {
    await database.customStatement(
      "CREATE TRIGGER fail_outbox BEFORE INSERT ON sync_outbox BEGIN SELECT RAISE(ABORT, 'test failure'); END;",
    );
    await expectLater(
      learning('A').saveNote(note('n', 'must rollback')),
      throwsA(anything),
    );
    expect(await learning('A').watchNotes('g').first, isEmpty);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });
  test('saving same stable ID updates one note', () async {
    await learning('A').saveNote(note('n', 'old'));
    await learning('A').saveNote(note('n', 'new'));
    final notes = await learning('A').watchNotes('g').first;
    expect(notes, hasLength(1));
    expect(notes.single.content, 'new');
  });
  test(
    'cached content survives offline; successful empty source clears cache',
    () async {
      final source = ControlledSource();
      final repository = CachedGrammarRepository(database, source, 'backend');
      expect(await repository.load(), hasLength(1));
      source.offline = true;
      expect(await repository.load(), hasLength(1));
      await expectLater(
        CachedGrammarRepository(database, source, 'other').load(),
        throwsA(isA<SocketException>()),
      );
      source.offline = false;
      source.rows = [];
      expect(await repository.load(), isEmpty);
      source.offline = true;
      await expectLater(repository.load(), throwsA(isA<SocketException>()));
    },
  );
  test('notes persist after database close and reopen', () async {
    await database.close();
    final directory = await Directory.systemTemp.createTemp('bunly-test-');
    final file = File('${directory.path}/notes.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    await LocalLearningRepository(
      db,
      namespace: 'demo',
      ownerId: 'A',
      queueRemote: false,
    ).saveNote(note('n', 'persisted'));
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    try {
      final notes = await LocalLearningRepository(
        db,
        namespace: 'demo',
        ownerId: 'A',
        queueRemote: false,
      ).watchNotes('g').first;
      expect(notes.single.content, 'persisted');
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    } finally {
      await db.close();
      await directory.delete(recursive: true);
      database = AppDatabase(NativeDatabase.memory());
    }
  });
}
