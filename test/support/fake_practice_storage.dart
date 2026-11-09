import 'dart:async';

import 'package:bunly/features/analysis/domain/grammar_analysis.dart';
import 'package:bunly/features/ocr/domain/ocr_draft.dart';
import 'package:bunly/features/practice/domain/practice_storage.dart';

class FakePracticeStorageRepository implements PracticeStorageRepository {
  FakePracticeStorageRepository({
    List<CuratedPracticeQuestion> initialQuestions = const [],
    List<PracticeAttemptEntry> initialAttempts = const [],
    List<ReviewStateEntry> initialReviewStates = const [],
    this.isTentative = false,
  }) : _questions = List<CuratedPracticeQuestion>.of(initialQuestions),
       _attempts = List<PracticeAttemptEntry>.of(initialAttempts),
       _reviewStates = {
         for (final state in initialReviewStates) state.grammarId: state,
       };

  final bool isTentative;
  final List<CuratedPracticeQuestion> _questions;
  final List<PracticeAttemptEntry> _attempts;
  final Map<String, ReviewStateEntry> _reviewStates;
  final _attemptsController =
      StreamController<List<PracticeAttemptEntry>>.broadcast();
  final _reviewController =
      StreamController<List<ReviewStateEntry>>.broadcast();

  Object? nextRecordAttemptError;

  List<PracticeAttemptEntry> get attempts => List.unmodifiable(_attempts);
  List<ReviewStateEntry> get reviewStates =>
      List.unmodifiable(_reviewStates.values);

  @override
  Future<void> replaceCachedQuestions(
    List<CuratedPracticeQuestion> questions,
  ) async {
    _questions
      ..clear()
      ..addAll(questions);
  }

  @override
  Future<List<CuratedPracticeQuestion>> loadCachedQuestions({
    String? grammarId,
  }) async {
    if (grammarId == null) return List.unmodifiable(_questions);
    return List.unmodifiable(_questions.where((q) => q.grammarId == grammarId));
  }

  @override
  Future<void> recordAttempt(PracticeAttemptEntry attempt) async {
    if (nextRecordAttemptError != null) {
      final err = nextRecordAttemptError!;
      nextRecordAttemptError = null;
      throw err;
    }
    if (_attempts.any((a) => a.attemptId == attempt.attemptId)) return;
    if (attempt.isFirstIndependent &&
        _attempts.any(
          (a) =>
              a.sessionId == attempt.sessionId &&
              a.questionId == attempt.questionId &&
              a.isFirstIndependent,
        )) {
      throw StateError('Đã ghi nhận lần làm độc lập đầu tiên cho câu hỏi này.');
    }
    _attempts.add(attempt);
    if (!_attemptsController.isClosed) {
      _attemptsController.add(List.unmodifiable(_attempts));
    }

    if (attempt.isFirstIndependent && !attempt.isSkipped) {
      final computed = computeDeterministicReviewState(
        grammarId: attempt.grammarId,
        attempts: _attempts,
        nowUtc: DateTime.now().toUtc(),
        isTentative: isTentative && attempt.serverReceivedAt == null,
      );
      _reviewStates[attempt.grammarId] = computed;
      if (!_reviewController.isClosed) {
        _reviewController.add(List.unmodifiable(_reviewStates.values));
      }
    }
  }

  @override
  Stream<List<PracticeAttemptEntry>> watchAttempts({String? grammarId}) async* {
    List<PracticeAttemptEntry> snapshot() {
      final filtered = grammarId == null
          ? List<PracticeAttemptEntry>.of(_attempts)
          : _attempts.where((a) => a.grammarId == grammarId).toList();
      filtered.sort(compareCanonicalAttempt);
      return List.unmodifiable(filtered);
    }

    yield snapshot();
    yield* _attemptsController.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ReviewStateEntry>> watchReviewStates() async* {
    List<ReviewStateEntry> snapshot() {
      final list = _reviewStates.values.toList()
        ..sort((a, b) => a.grammarId.compareTo(b.grammarId));
      return List.unmodifiable(list);
    }

    yield snapshot();
    yield* _reviewController.stream.map((_) => snapshot());
  }

  @override
  Future<void> applyCanonicalReviewStates(List<ReviewStateEntry> states) async {
    for (final state in states) {
      _reviewStates[state.grammarId] = state;
    }
    if (!_reviewController.isClosed) {
      _reviewController.add(List.unmodifiable(_reviewStates.values));
    }
  }

  Future<void> dispose() async {
    await _attemptsController.close();
    await _reviewController.close();
  }
}

class FakeOcrRepository implements OcrRepository {
  FakeOcrRepository({this.nextDraft, this.errorToThrow});

  OcrDraft? nextDraft;
  Object? errorToThrow;
  final List<OcrSource> sourceCalls = [];
  final List<String> pathCalls = [];
  bool disposed = false;

  @override
  Future<OcrDraft?> scan(OcrSource source) async {
    sourceCalls.add(source);
    final err = errorToThrow;
    if (err != null) throw err;
    return nextDraft;
  }

  @override
  Future<OcrDraft?> scanFilePath(String path) async {
    pathCalls.add(path);
    final err = errorToThrow;
    if (err != null) throw err;
    return nextDraft;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class FakeGrammarAnalysisRepository implements GrammarAnalysisRepository {
  FakeGrammarAnalysisRepository({
    AnalysisQuotaStatus? initialQuota,
    this.onAnalyze,
  }) : quota =
           initialQuota ??
           AnalysisQuotaStatus(
             hasEntitlement: true,
             dailyLimit: 20,
             usedToday: 1,
             reservedToday: 0,
             remainingQuota: 19,
             resetAtUtc: DateTime.utc(2026, 11, 10),
           );

  AnalysisQuotaStatus quota;
  Object? quotaError;
  Future<GrammarAnalysisResult> Function(String requestId, String text)?
  onAnalyze;
  final List<({String requestId, String text})> submittedRequests = [];

  @override
  Future<AnalysisQuotaStatus> loadQuota() async {
    if (quotaError != null) throw quotaError!;
    return quota;
  }

  @override
  Future<GrammarAnalysisResult> analyze({
    required String requestId,
    required String normalizedText,
    String locale = 'vi',
  }) async {
    submittedRequests.add((requestId: requestId, text: normalizedText));
    final fn = onAnalyze;
    if (fn != null) {
      return fn(requestId, normalizedText);
    }
    return GrammarAnalysisResult(
      requestId: requestId,
      text: normalizedText,
      matches: const [],
      remainingQuota: quota.remainingQuota > 0 ? quota.remainingQuota - 1 : 0,
      isLiveAi: true,
    );
  }
}
