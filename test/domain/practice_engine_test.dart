import 'package:bunly/core/database/app_database.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/practice/data/local_practice_storage_repository.dart';
import 'package:bunly/features/practice/domain/practice_engine.dart';
import 'package:bunly/features/practice/domain/practice_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final g1 = const GrammarPoint(
    id: 'g1',
    pattern: '〜たことがある',
    level: 'N4',
    category: 'experience',
    meaning: 'Đã từng',
    formula: 'Vた + ことがある',
    usage: 'Kinh nghiệm',
    examples: [],
  );
  final g2 = const GrammarPoint(
    id: 'g2',
    pattern: '〜たい',
    level: 'N5',
    category: 'desire',
    meaning: 'Muốn',
    formula: 'Vます + たい',
    usage: 'Mong muốn',
    examples: [],
  );
  final catalogById = {'g1': g1, 'g2': g2};

  final q1 = CuratedPracticeQuestion(
    id: 'q1',
    grammarId: 'g1',
    contentVersion: 1,
    type: PracticeBankType.mcq,
    prompt: '日本へ（　？　）ことがあります。',
    options: const ['行く', '行った', '行きます', '行かない'],
    correctOptionIndex: 1,
    explanationVi: 'Dùng thể た.',
  );
  final q2 = CuratedPracticeQuestion(
    id: 'q2',
    grammarId: 'g1',
    contentVersion: 1,
    type: PracticeBankType.cloze,
    prompt: '納豆を［　　　］ことがありません。',
    acceptedAnswers: const ['食べた', 'たべた'],
    explanationVi: '食べた + ことがありません.',
  );
  final q3 = CuratedPracticeQuestion(
    id: 'q3',
    grammarId: 'g2',
    contentVersion: 1,
    type: PracticeBankType.mcq,
    prompt: '水を（　？　）たいです。',
    options: const ['飲み', '飲む', '飲んで', '飲んだ'],
    correctOptionIndex: 0,
    explanationVi: 'Vます + たい.',
  );

  group('practice analytics and selection', () {
    test(
      'separates first independent attempts from skips/retries and tracks weak resolution',
      () {
        final now = DateTime.utc(2026, 11, 10, 12);
        final attempts = [
          // 10 days old (outside 7-day window): independent correct on q3.
          PracticeAttemptEntry(
            attemptId: 'a0',
            questionId: 'q3',
            grammarId: 'g2',
            contentVersion: 1,
            sessionId: 's0',
            answerText: '飲み',
            selectedOptionIndex: 0,
            isCorrect: true,
            isFirstIndependent: true,
            attemptedAt: DateTime.utc(2026, 10, 25),
          ),
          // Within 7 days: q1 independent wrong.
          PracticeAttemptEntry(
            attemptId: 'a1',
            questionId: 'q1',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's1',
            answerText: '行く',
            selectedOptionIndex: 0,
            isCorrect: false,
            isFirstIndependent: true,
            attemptedAt: DateTime.utc(2026, 11, 8, 9),
          ),
          // Same session retry right -> ignored in denominator & doesn't resolve initial wrong alone.
          PracticeAttemptEntry(
            attemptId: 'a2',
            questionId: 'q1',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's1',
            retryOf: 'a1',
            answerText: '行った',
            selectedOptionIndex: 1,
            isCorrect: true,
            isFirstIndependent: false,
            attemptedAt: DateTime.utc(2026, 11, 8, 9, 1),
          ),
          // Skipped question -> ignored in denominator.
          PracticeAttemptEntry(
            attemptId: 'a3',
            questionId: 'q2',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's1',
            isCorrect: false,
            isSkipped: true,
            isFirstIndependent: false,
            attemptedAt: DateTime.utc(2026, 11, 8, 9, 2),
          ),
          // Later session: q2 independent wrong, then resolved in s3!
          PracticeAttemptEntry(
            attemptId: 'a4',
            questionId: 'q2',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's2',
            answerText: '食べる',
            isCorrect: false,
            isFirstIndependent: true,
            attemptedAt: DateTime.utc(2026, 11, 9, 9),
          ),
          PracticeAttemptEntry(
            attemptId: 'a5',
            questionId: 'q2',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's3',
            answerText: '食べた',
            isCorrect: true,
            isFirstIndependent: true,
            attemptedAt: DateTime.utc(2026, 11, 10, 9),
          ),
        ];

        final analytics = computePracticeAnalytics(
          attempts: attempts,
          reviewStates: const [],
          nowUtc: now,
        );

        // Overall independent: a0(T), a1(F), a4(F), a5(T) => 2/4 = 50%.
        expect(analytics.overall.independentAnswered, 4);
        expect(analytics.overall.independentCorrect, 2);
        expect(analytics.overall.skippedCount, 1);
        expect(analytics.overall.retryCount, 1);
        expect(analytics.overall.accuracyPercent, 50);

        // Last 7 days: a1(F), a4(F), a5(T) => 1/3 = 33%.
        expect(analytics.last7Days.independentAnswered, 3);
        expect(analytics.last7Days.independentCorrect, 1);
        expect(analytics.last7Days.accuracyPercent, 33);

        // Error tracking: q1 still unresolved wrong, q2 resolved on a5.
        expect(analytics.unresolvedErrorCount, 1);
        expect(analytics.resolvedErrorCount, 1);
        expect(analytics.unresolvedQuestionIds, {'q1'});
        expect(analytics.weakGrammars.single.grammarId, 'g1');
        expect(analytics.weakGrammars.single.unresolvedWrongCount, 1);
        expect(analytics.weakGrammars.single.wrongIndependentCount, 2);
      },
    );

    test(
      'selects curated questions cleanly for dueSrs, weakMistakes, byGrammar and custom',
      () {
        final bank = [q1, q2, q3];
        final dueStates = [
          ReviewStateEntry(
            grammarId: 'g2',
            stage: 0,
            dueAt: DateTime.utc(2026, 11, 8),
            updatedAt: DateTime.utc(2026, 11, 7),
          ),
          ReviewStateEntry(
            grammarId: 'g1',
            stage: 1,
            dueAt: DateTime.utc(2026, 11, 9),
            updatedAt: DateTime.utc(2026, 11, 7),
          ),
        ];

        // Earliest due grammar (g2) appears first.
        final dueSelected = selectCuratedPracticeQuestions(
          bank: bank,
          source: PracticeSessionSource.dueSrs,
          catalogById: catalogById,
          dueReviewStates: dueStates,
          attempts: const [],
        );
        expect(dueSelected.map((q) => q.id).toList(), ['q3', 'q1', 'q2']);

        // Exact wrong unresolved question q2 comes before sibling q1 of same grammar.
        final weakSelected = selectCuratedPracticeQuestions(
          bank: bank,
          source: PracticeSessionSource.weakMistakes,
          catalogById: catalogById,
          dueReviewStates: const [],
          attempts: [
            PracticeAttemptEntry(
              attemptId: 'w1',
              questionId: 'q2',
              grammarId: 'g1',
              contentVersion: 1,
              sessionId: 's1',
              answerText: '違う',
              isCorrect: false,
              isFirstIndependent: true,
              attemptedAt: DateTime.utc(2026, 11, 8),
            ),
          ],
        );
        expect(weakSelected.map((q) => q.id).toList(), ['q2', 'q1']);

        final byGrammarSelected = selectCuratedPracticeQuestions(
          bank: bank,
          source: PracticeSessionSource.byGrammar,
          grammarId: 'g2',
          catalogById: catalogById,
          dueReviewStates: const [],
          attempts: const [],
        );
        expect(byGrammarSelected.map((q) => q.id).toList(), ['q3']);

        final customN5Cloze = selectCuratedPracticeQuestions(
          bank: bank,
          source: PracticeSessionSource.custom,
          level: 'N5',
          allowedTypes: const {PracticeBankType.mcq},
          catalogById: catalogById,
          dueReviewStates: const [],
          attempts: const [],
        );
        expect(customN5Cloze.map((q) => q.id).toList(), ['q3']);
      },
    );

    test(
      'buildClozeWordBank & filterPracticeHistory work deterministically',
      () {
        final wordBank = buildClozeWordBank(q2, [q1, q2, q3]);
        expect(wordBank, contains('食べた'));
        expect(wordBank.length, 4);
        expect(wordBank.toSet().length, 4);

        final now = DateTime.utc(2026, 11, 10, 12);
        final attempts = [
          PracticeAttemptEntry(
            attemptId: 'h1',
            questionId: 'q1',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's1',
            answerText: '行く',
            isCorrect: false,
            isFirstIndependent: true,
            attemptedAt: DateTime.utc(2026, 11, 10, 8),
          ),
          PracticeAttemptEntry(
            attemptId: 'h2',
            questionId: 'q2',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 's1',
            isCorrect: false,
            isSkipped: true,
            isFirstIndependent: false,
            attemptedAt: DateTime.utc(2026, 11, 10, 9),
          ),
        ];
        final byId = {'q1': q1, 'q2': q2};
        final errs = filterPracticeHistory(
          attempts: attempts,
          questionsById: byId,
          nowUtc: now,
          errorsOnly: true,
          errorFilter: 'Chưa khắc phục',
          unresolvedQuestionIds: const {'q1'},
        );
        expect(errs.map((a) => a.attemptId).toList(), ['h1']);

        final emptyVoice = filterPracticeHistory(
          attempts: attempts,
          questionsById: byId,
          nowUtc: now,
          errorsOnly: false,
          kindFilter: 'Nói',
        );
        expect(emptyVoice, isEmpty);
      },
    );
  });

  group('LocalPracticeStorageRepository (Drift)', () {
    test(
      'enforces single isFirstIndependent per session/question, preserves canonical order and outbox',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final repo = LocalPracticeStorageRepository(
          db,
          namespace: 'connected',
          ownerId: 'user-a',
          queueRemote: true,
        );

        final first = PracticeAttemptEntry(
          attemptId: 'att-1',
          questionId: 'q1',
          grammarId: 'g1',
          contentVersion: 1,
          sessionId: 'sess-1',
          answerText: '行く',
          selectedOptionIndex: 0,
          isCorrect: false,
          isFirstIndependent: true,
          attemptedAt: DateTime.utc(2026, 11, 10, 1),
        );
        await repo.recordAttempt(first);

        // Idempotent duplicate attemptId does not throw or double-queue.
        await repo.recordAttempt(first);
        expect((await db.select(db.syncOutbox).get()).length, 1);

        // Duplicate isFirstIndependent with a different attemptId for same session+question fails cleanly.
        await expectLater(
          repo.recordAttempt(
            PracticeAttemptEntry(
              attemptId: 'att-dup',
              questionId: 'q1',
              grammarId: 'g1',
              contentVersion: 1,
              sessionId: 'sess-1',
              answerText: '行った',
              selectedOptionIndex: 1,
              isCorrect: true,
              isFirstIndependent: true,
              attemptedAt: DateTime.utc(2026, 11, 10, 2),
            ),
          ),
          throwsStateError,
        );

        // Retry with isFirstIndependent = false succeeds without altering SRS stage=0 from first wrong.
        await repo.recordAttempt(
          PracticeAttemptEntry(
            attemptId: 'att-retry',
            questionId: 'q1',
            grammarId: 'g1',
            contentVersion: 1,
            sessionId: 'sess-1',
            retryOf: 'att-1',
            answerText: '行った',
            selectedOptionIndex: 1,
            isCorrect: true,
            isFirstIndependent: false,
            attemptedAt: DateTime.utc(2026, 11, 10, 2),
          ),
        );

        final watched = await repo.watchAttempts().first;
        expect(watched.map((a) => a.attemptId).toList(), [
          'att-1',
          'att-retry',
        ]);

        final review = (await repo.watchReviewStates().first).single;
        expect(review.grammarId, 'g1');
        expect(review.stage, 0);
        expect(review.lastAttemptId, 'att-1');
        expect(review.isTentative, isTrue);

        // Pending attempt in outbox protects local tentative state for g1 from stale server overwrite,
        // while allowing server updates for other grammars like g2.
        await repo.applyCanonicalReviewStates([
          ReviewStateEntry(
            grammarId: 'g1',
            stage: 3,
            dueAt: DateTime.utc(2026, 12, 1),
            lastAttemptId: 'older',
            isTentative: false,
            updatedAt: DateTime.utc(2026, 11, 10),
          ),
          ReviewStateEntry(
            grammarId: 'g2',
            stage: 2,
            dueAt: DateTime.utc(2026, 11, 20),
            lastAttemptId: 'srv-g2',
            isTentative: false,
            updatedAt: DateTime.utc(2026, 11, 10),
          ),
        ]);

        final afterCanonical = await repo.watchReviewStates().first;
        final byGrammar = {for (final r in afterCanonical) r.grammarId: r};
        expect(byGrammar['g1']!.stage, 0);
        expect(byGrammar['g1']!.isTentative, isTrue);
        expect(byGrammar['g2']!.stage, 2);
        expect(byGrammar['g2']!.isTentative, isFalse);
      },
    );
  });
}
