import 'package:bunly/features/practice/domain/practice_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CuratedPracticeQuestion mcq() => CuratedPracticeQuestion(
    id: '25000000-0000-0000-0000-000000000001',
    grammarId: '10000000-0000-0000-0000-000000000001',
    contentVersion: 1,
    type: PracticeBankType.mcq,
    prompt: 'Chọn nghĩa đúng',
    options: const ['Đã từng', 'Muốn', 'Đang', 'Cấm'],
    correctOptionIndex: 0,
    explanationVi: 'Diễn tả trải nghiệm.',
  );

  CuratedPracticeQuestion cloze() => CuratedPracticeQuestion(
    id: '25000000-0000-0000-0000-000000000002',
    grammarId: '10000000-0000-0000-0000-000000000001',
    contentVersion: 1,
    type: PracticeBankType.cloze,
    prompt: '日本へ（　）ことがあります。',
    acceptedAnswers: const ['行った'],
    explanationVi: 'Dùng thể た.',
  );

  PracticeAttemptEntry attempt({
    required String id,
    required bool correct,
    DateTime? attemptedAt,
    DateTime? serverReceivedAt,
    bool skipped = false,
    bool first = true,
    String? retryOf,
  }) => PracticeAttemptEntry(
    attemptId: id,
    questionId: '25000000-0000-0000-0000-000000000001',
    grammarId: '10000000-0000-0000-0000-000000000001',
    contentVersion: 1,
    sessionId: '60000000-0000-0000-0000-000000000001',
    retryOf: retryOf,
    answerText: correct ? '行った' : '行く',
    selectedOptionIndex: correct ? 0 : 1,
    isCorrect: correct,
    isSkipped: skipped,
    isFirstIndependent: first,
    attemptedAt: attemptedAt ?? DateTime.utc(2026, 11, 9, 10),
    serverReceivedAt: serverReceivedAt,
  );

  test('MCQ and cloze grading strictly follows trim_only and option index', () {
    expect(mcq().accepts(selectedIndex: 0), isTrue);
    expect(mcq().accepts(selectedIndex: 2), isFalse);
    expect(mcq().accepts(rawText: '  Đã từng '), isTrue);

    expect(cloze().accepts(rawText: '  行った  '), isTrue);
    // Kana vs Kanji is not auto-blurred under baseline trim_only normalization.
    expect(cloze().accepts(rawText: 'いった'), isFalse);
  });

  test('SRS replay advances 1/3/7/14/30 days and resets wrong to stage 0', () {
    final gId = '10000000-0000-0000-0000-000000000001';
    final now = DateTime.utc(2026, 11, 20);
    final entries = <PracticeAttemptEntry>[];

    // No attempts -> stage -1
    var state = computeDeterministicReviewState(
      grammarId: gId,
      attempts: entries,
      nowUtc: now,
      isTentative: true,
    );
    expect(state.stage, -1);
    expect(state.dueAt, isNull);

    // 5 consecutive independent correct answers: stage 0,1,2,3,4 (+1,3,7,14,30d)
    const expectedIntervals = [1, 3, 7, 14, 30];
    for (var i = 0; i < 6; i++) {
      final t = DateTime.utc(2026, 11, 1 + i, 12);
      entries.add(attempt(id: 'a-$i', correct: true, serverReceivedAt: t));
      state = computeDeterministicReviewState(
        grammarId: gId,
        attempts: entries,
        nowUtc: now,
        isTentative: false,
      );
      final expectedStage = i.clamp(0, 4);
      final expectedDays = expectedIntervals[expectedStage];
      expect(state.stage, expectedStage);
      expect(
        state.dueAt,
        DateTime.utc(2026, 11, 1 + i).add(Duration(days: expectedDays)),
      );
    }

    // Skips and post-answer retries do not affect stage or dueAt
    entries.add(
      attempt(
        id: 'a-skip',
        correct: false,
        skipped: true,
        first: false,
        serverReceivedAt: DateTime.utc(2026, 11, 7),
      ),
    );
    entries.add(
      attempt(
        id: 'a-retry',
        correct: false,
        first: false,
        retryOf: 'a-5',
        serverReceivedAt: DateTime.utc(2026, 11, 7, 1),
      ),
    );
    state = computeDeterministicReviewState(
      grammarId: gId,
      attempts: entries,
      nowUtc: now,
      isTentative: false,
    );
    expect(state.stage, 4);

    // Wrong independent attempt resets to stage 0 (1 day)
    entries.add(
      attempt(
        id: 'a-wrong',
        correct: false,
        serverReceivedAt: DateTime.utc(2026, 11, 8, 9),
      ),
    );
    state = computeDeterministicReviewState(
      grammarId: gId,
      attempts: entries,
      nowUtc: now,
      isTentative: false,
    );
    expect(state.stage, 0);
    expect(state.dueAt, DateTime.utc(2026, 11, 9));
  });

  test(
    'canonical order matches sync.cases.json review_case (ignores client clock)',
    () {
      final gId = '10000000-0000-0000-0000-000000000001';
      final state = computeDeterministicReviewState(
        grammarId: gId,
        attempts: [
          // Later UUID with same server receipt arrives first in list, with future client clock.
          attempt(
            id: '50000000-0000-0000-0000-000000000002',
            correct: false,
            attemptedAt: DateTime.utc(2026, 11, 10),
            serverReceivedAt: DateTime.utc(2026, 11, 9, 10),
          ),
          attempt(
            id: '50000000-0000-0000-0000-000000000001',
            correct: true,
            attemptedAt: DateTime.utc(2026, 11, 8),
            serverReceivedAt: DateTime.utc(2026, 11, 9, 10),
          ),
        ],
        nowUtc: DateTime.utc(2026, 11, 9, 10),
        isTentative: false,
      );
      expect(state.stage, 0);
      expect(state.dueAt, DateTime.utc(2026, 11, 10));
      expect(state.lastAttemptId, '50000000-0000-0000-0000-000000000002');
    },
  );

  test(
    'RecordPracticeAttempt rejects invalid skip, self-retry, or overflow',
    () async {
      final repo = _FakePracticeStorage();
      final record = RecordPracticeAttempt(repo);

      await expectLater(
        record(attempt(id: '1', correct: true, skipped: true, first: false)),
        throwsFormatException,
      );
      await expectLater(
        record(attempt(id: '1', correct: false, skipped: true, first: true)),
        throwsFormatException,
      );
      await expectLater(
        record(attempt(id: '1', correct: true, retryOf: '1', first: false)),
        throwsFormatException,
      );
      await expectLater(
        record(
          PracticeAttemptEntry(
            attemptId: '1',
            questionId: 'q',
            grammarId: 'g',
            contentVersion: 0,
            sessionId: 's',
            isCorrect: true,
            isFirstIndependent: true,
            attemptedAt: DateTime.utc(2026),
          ),
        ),
        throwsFormatException,
      );
      expect(repo.saved, isEmpty);
    },
  );
}

class _FakePracticeStorage implements PracticeStorageRepository {
  final List<PracticeAttemptEntry> saved = [];

  @override
  Future<void> applyCanonicalReviewStates(
    List<ReviewStateEntry> states,
  ) async {}

  @override
  Future<List<CuratedPracticeQuestion>> loadCachedQuestions({
    String? grammarId,
  }) async => const [];

  @override
  Future<void> recordAttempt(PracticeAttemptEntry attempt) async {
    saved.add(attempt);
  }

  @override
  Future<void> replaceCachedQuestions(
    List<CuratedPracticeQuestion> questions,
  ) async {}

  @override
  Stream<List<PracticeAttemptEntry>> watchAttempts({String? grammarId}) =>
      Stream.value(saved);

  @override
  Stream<List<ReviewStateEntry>> watchReviewStates() => Stream.value(const []);
}
