import 'dart:async';
import 'dart:io';

import 'package:bunly/core/database/app_database.dart';
import 'package:bunly/features/learning/data/learning_sync.dart';
import 'package:bunly/features/learning/data/local_learning_repository.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:bunly/features/practice/data/local_practice_storage_repository.dart';
import 'package:bunly/features/practice/data/supabase_practice_sync.dart';
import 'package:bunly/features/practice/domain/practice_storage.dart';
import 'package:bunly/features/settings/data/local_app_settings_repository.dart';
import 'package:bunly/features/settings/domain/app_settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _ControlledLearningRemote implements LearningRemote {
  String user = 'A';
  @override
  bool ownsSession(String ownerId) => user == ownerId;

  final List<String> upsertedTables = [];
  @override
  Future<void> upsert(String table, Map<String, dynamic> payload) async {
    upsertedTables.add(table);
  }

  @override
  Future<List<Map<String, dynamic>>> fetch(
    String table,
    String ownerId,
  ) async => const [];
}

class _ControlledPracticeRemote implements PracticeRemote {
  String user = 'A';
  bool failAttemptPush = false;
  final List<Map<String, dynamic>> insertedAttempts = [];
  List<Map<String, dynamic>> remoteQuestions = [];
  List<Map<String, dynamic>> remoteReviews = [];

  @override
  bool ownsSession(String ownerId) => user == ownerId;

  @override
  Future<List<Map<String, dynamic>>> fetchQuestions() async => remoteQuestions;

  @override
  Future<void> insertAttemptIdempotent(Map<String, dynamic> payload) async {
    if (failAttemptPush) throw TimeoutException('network timeout');
    insertedAttempts.add(Map.of(payload));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAttempts(String ownerId) async =>
      insertedAttempts
          .map((a) => {...a, 'server_received_at': '2026-11-09T12:00:00Z'})
          .toList();

  @override
  Future<List<Map<String, dynamic>>> fetchReviewStates(String ownerId) async =>
      remoteReviews;
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  LocalPracticeStorageRepository practiceRepo(
    String owner, {
    String namespace = 'connected',
    bool queueRemote = true,
  }) => LocalPracticeStorageRepository(
    db,
    namespace: namespace,
    ownerId: owner,
    queueRemote: queueRemote,
  );

  test(
    'cached questions, attempts and review states persist and isolate by namespace/owner',
    () async {
      final a = practiceRepo('A');
      final b = practiceRepo('B');
      final q = CuratedPracticeQuestion(
        id: '25000000-0000-0000-0000-000000000001',
        grammarId: '10000000-0000-0000-0000-000000000001',
        contentVersion: 1,
        type: PracticeBankType.cloze,
        prompt: '日本へ（　）ことがあります。',
        acceptedAnswers: const ['行った'],
        explanationVi: 'Dùng thể た.',
      );

      await a.replaceCachedQuestions([q]);
      expect(await a.loadCachedQuestions(), hasLength(1));
      expect(
        await practiceRepo('A', namespace: 'other').loadCachedQuestions(),
        isEmpty,
      );

      final attempt = PracticeAttemptEntry(
        attemptId: '51000000-0000-0000-0000-000000000001',
        questionId: q.id,
        grammarId: q.grammarId,
        contentVersion: 1,
        sessionId: '61000000-0000-0000-0000-000000000001',
        answerText: '行った',
        isCorrect: true,
        isFirstIndependent: true,
        attemptedAt: DateTime.utc(2026, 11, 9, 8),
      );
      await a.recordAttempt(attempt);
      // Recording identical attemptId again must be an idempotent no-op.
      await a.recordAttempt(attempt);

      expect(await a.watchAttempts().first, hasLength(1));
      expect(await b.watchAttempts().first, isEmpty);
      expect(await db.select(db.syncOutbox).get(), hasLength(1));
      final reviewA = (await a.watchReviewStates().first).single;
      expect(reviewA.stage, 0);
      expect(reviewA.dueAt, DateTime.utc(2026, 11, 10));
      expect(reviewA.isTentative, isTrue);
      expect(await b.watchReviewStates().first, isEmpty);
    },
  );

  test(
    'outbox failure rolls back both attempt insert and review update',
    () async {
      await db.customStatement(
        "CREATE TRIGGER fail_practice_outbox BEFORE INSERT ON sync_outbox BEGIN SELECT RAISE(ABORT, 'test failure'); END;",
      );
      final a = practiceRepo('A');
      await expectLater(
        a.recordAttempt(
          PracticeAttemptEntry(
            attemptId: '51000000-0000-0000-0000-000000000002',
            questionId: 'q1',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's1',
            isCorrect: true,
            isFirstIndependent: true,
            attemptedAt: DateTime.utc(2026, 11, 9),
          ),
        ),
        throwsA(anything),
      );
      expect(await a.watchAttempts().first, isEmpty);
      expect(await a.watchReviewStates().first, isEmpty);
    },
  );

  test(
    'LearningSync ignores queued practice_attempts while PracticeSync pushes attempts and protects pending review states',
    () async {
      final learning = LocalLearningRepository(
        db,
        namespace: 'ns',
        ownerId: 'A',
        queueRemote: true,
      );
      await learning.saveNote(
        Note(
          id: 'n1',
          grammarId: 'g1',
          content: 'note content',
          updatedAt: DateTime.utc(2026, 11, 9),
        ),
      );
      final storage = practiceRepo('A', namespace: 'ns');
      await storage.recordAttempt(
        PracticeAttemptEntry(
          attemptId: '51000000-0000-0000-0000-000000000003',
          questionId: '25000000-0000-0000-0000-000000000001',
          grammarId: 'g1',
          contentVersion: 1,
          sessionId: 's1',
          isCorrect: true,
          isFirstIndependent: true,
          attemptedAt: DateTime.utc(2026, 11, 9),
        ),
      );

      final outboxRows = await db.select(db.syncOutbox).get();
      expect(outboxRows, hasLength(2));
      expect(outboxRows.first.operationId, isNotEmpty);
      expect(outboxRows.first.baseRevision, 0);

      final learningRemote = _ControlledLearningRemote();
      await LearningSync(
        db,
        learningRemote,
        namespace: 'ns',
        ownerId: 'A',
      ).run();
      expect(learningRemote.upsertedTables, ['notes']);
      // Practice outbox entry stays queued until PracticeSync drains it.
      expect(
        (await db.select(db.syncOutbox).get()).single.entityTable,
        'practice_attempts',
      );

      final practiceRemote = _ControlledPracticeRemote()
        ..remoteQuestions = [
          {
            'id': '25000000-0000-0000-0000-000000000001',
            'grammar_id': 'g1',
            'content_version': 1,
            'question_type': 'mcq',
            'prompt': 'P?',
            'options': ['A', 'B', 'C', 'D'],
            'correct_option_index': 0,
            'accepted_answers': null,
            'normalization': 'trim_only',
            'explanation_vi': 'E',
          },
        ]
        ..remoteReviews = [
          {
            'user_id': 'A',
            'grammar_id': 'g1',
            'stage': 2,
            'due_at': '2026-11-16T00:00:00Z',
            'algorithm_version': 1,
            'last_attempt_id': '51000000-0000-0000-0000-000000000003',
            'updated_at': '2026-11-09T12:00:00Z',
          },
        ];

      await PracticeSync(
        db,
        practiceRemote,
        storage,
        namespace: 'ns',
        ownerId: 'A',
      ).run();

      expect(await db.select(db.syncOutbox).get(), isEmpty);
      expect(await storage.loadCachedQuestions(), hasLength(1));
      final syncedReview = (await storage.watchReviewStates().first).single;
      expect(syncedReview.stage, 2);
      expect(syncedReview.isTentative, isFalse);
      final syncedAttempt = (await storage.watchAttempts().first).single;
      expect(syncedAttempt.serverReceivedAt, DateTime.utc(2026, 11, 9, 12));
    },
  );

  test(
    'migration v2 -> v3 preserves notes, personal records, theme settings and pending outbox',
    () async {
      await db.close();
      final directory = await Directory.systemTemp.createTemp('bunly-v2v3-');
      final file = File('${directory.path}/bunly_v2.sqlite');
      try {
        var v2 = AppDatabase(
          NativeDatabase(
            file,
            setup: (sqlite) {
              sqlite.execute(
                'CREATE TABLE cached_grammar (namespace TEXT NOT NULL, grammar_id TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(namespace, grammar_id))',
              );
              sqlite.execute(
                'CREATE TABLE local_notes (namespace TEXT NOT NULL, owner_id TEXT NOT NULL, note_id TEXT NOT NULL, grammar_id TEXT NOT NULL, content TEXT NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER, PRIMARY KEY(namespace, owner_id, note_id))',
              );
              sqlite.execute(
                "CREATE TABLE sync_outbox (sequence INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, namespace TEXT NOT NULL, owner_id TEXT NOT NULL, record_id TEXT NOT NULL, payload TEXT NOT NULL, entity_table TEXT NOT NULL DEFAULT 'notes')",
              );
              sqlite.execute(
                'CREATE TABLE personal_records (namespace TEXT NOT NULL, owner_id TEXT NOT NULL, entity_table TEXT NOT NULL, record_id TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(namespace, owner_id, entity_table, record_id))',
              );
              sqlite.execute(
                "INSERT INTO local_notes VALUES ('demo','demo-user','n1','g1','preserved v2 note',1767225600,NULL)",
              );
              sqlite.execute(
                "INSERT INTO personal_records VALUES ('app','device','app_settings','theme_mode','{\"theme_mode\":\"dark\"}')",
              );
              sqlite.execute(
                "INSERT INTO personal_records VALUES ('demo','demo-user','saved_grammar','g1','{\"user_id\":\"demo-user\",\"grammar_id\":\"g1\",\"deleted_at\":null}')",
              );
              sqlite.execute(
                "INSERT INTO sync_outbox(namespace,owner_id,record_id,payload,entity_table) VALUES ('conn','u1','n2','{\"id\":\"n2\"}','notes')",
              );
              sqlite.execute('PRAGMA user_version = 2');
            },
          ),
        );

        final notes = await LocalLearningRepository(
          v2,
          namespace: 'demo',
          ownerId: 'demo-user',
          queueRemote: false,
        ).watchAllNotes().first;
        expect(notes.single.content, 'preserved v2 note');

        final settings = await LocalAppSettingsRepository(
          v2,
        ).loadThemePreference();
        expect(settings, AppThemePreference.dark);

        final learningSummary = await LocalLearningRepository(
          v2,
          namespace: 'demo',
          ownerId: 'demo-user',
          queueRemote: false,
        ).watchSummary().first;
        expect(learningSummary.saved, {'g1'});

        final outbox = await v2.select(v2.syncOutbox).get();
        expect(outbox.single.recordId, 'n2');
        expect(outbox.single.operationType, 'upsert');
        expect(outbox.single.attempts, 0);

        // New v3 practice storage works cleanly on migrated file DB across reopen.
        final storage = LocalPracticeStorageRepository(
          v2,
          namespace: 'demo',
          ownerId: 'demo-user',
          queueRemote: false,
        );
        await storage.recordAttempt(
          PracticeAttemptEntry(
            attemptId: 'att-v3',
            questionId: 'q1',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's1',
            isCorrect: true,
            isFirstIndependent: true,
            attemptedAt: DateTime.utc(2026, 11, 9),
          ),
        );
        await v2.close();

        v2 = AppDatabase(NativeDatabase(file));
        final reloaded = LocalPracticeStorageRepository(
          v2,
          namespace: 'demo',
          ownerId: 'demo-user',
          queueRemote: false,
        );
        expect(
          (await reloaded.watchAttempts().first).single.attemptId,
          'att-v3',
        );
        expect((await reloaded.watchReviewStates().first).single.stage, 0);
        await v2.close();
      } finally {
        await directory.delete(recursive: true);
        db = AppDatabase(NativeDatabase.memory());
      }
    },
  );
}
