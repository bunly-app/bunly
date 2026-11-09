const List<int> srsIntervalDays = [1, 3, 7, 14, 30];

enum PracticeBankType {
  mcq('mcq'),
  cloze('cloze');

  const PracticeBankType(this.value);
  final String value;

  static PracticeBankType parse(String raw) {
    return switch (raw) {
      'mcq' => PracticeBankType.mcq,
      'cloze' => PracticeBankType.cloze,
      _ => throw FormatException('Loại câu hỏi không hợp lệ: $raw'),
    };
  }
}

class CuratedPracticeQuestion {
  CuratedPracticeQuestion({
    required this.id,
    required this.grammarId,
    required this.contentVersion,
    required this.type,
    required this.prompt,
    List<String> options = const [],
    this.correctOptionIndex,
    List<String> acceptedAnswers = const [],
    this.normalization = 'trim_only',
    required this.explanationVi,
    this.updatedAt,
  }) : options = List.unmodifiable(options),
       acceptedAnswers = List.unmodifiable(acceptedAnswers);

  final String id;
  final String grammarId;
  final int contentVersion;
  final PracticeBankType type;
  final String prompt;
  final List<String> options;
  final int? correctOptionIndex;
  final List<String> acceptedAnswers;
  final String normalization;
  final String explanationVi;
  final DateTime? updatedAt;

  bool accepts({int? selectedIndex, String? rawText}) {
    if (type == PracticeBankType.mcq) {
      if (correctOptionIndex == null) return false;
      if (selectedIndex != null) {
        return selectedIndex == correctOptionIndex;
      }
      if (rawText != null &&
          correctOptionIndex! >= 0 &&
          correctOptionIndex! < options.length) {
        return rawText.trim() == options[correctOptionIndex!];
      }
      return false;
    }
    if (rawText == null) return false;
    return acceptedAnswers.contains(rawText.trim());
  }
}

class PracticeAttemptEntry {
  const PracticeAttemptEntry({
    required this.attemptId,
    required this.questionId,
    required this.grammarId,
    required this.contentVersion,
    required this.sessionId,
    this.retryOf,
    this.answerText = '',
    this.selectedOptionIndex,
    required this.isCorrect,
    this.isSkipped = false,
    required this.isFirstIndependent,
    required this.attemptedAt,
    this.serverReceivedAt,
  });

  final String attemptId;
  final String questionId;
  final String grammarId;
  final int contentVersion;
  final String sessionId;
  final String? retryOf;
  final String answerText;
  final int? selectedOptionIndex;
  final bool isCorrect;
  final bool isSkipped;
  final bool isFirstIndependent;
  final DateTime attemptedAt;
  final DateTime? serverReceivedAt;

  DateTime get canonicalOrderTimestamp =>
      (serverReceivedAt ?? attemptedAt).toUtc();
}

int compareCanonicalAttempt(PracticeAttemptEntry a, PracticeAttemptEntry b) {
  final timeCmp = a.canonicalOrderTimestamp.compareTo(
    b.canonicalOrderTimestamp,
  );
  if (timeCmp != 0) return timeCmp;
  return a.attemptId.compareTo(b.attemptId);
}

class ReviewStateEntry {
  const ReviewStateEntry({
    required this.grammarId,
    required this.stage,
    required this.dueAt,
    this.algorithmVersion = 1,
    this.lastAttemptId,
    this.isTentative = true,
    required this.updatedAt,
  });

  final String grammarId;
  final int stage;
  final DateTime? dueAt;
  final int algorithmVersion;
  final String? lastAttemptId;
  final bool isTentative;
  final DateTime updatedAt;

  bool isDueAt(DateTime utcNow) =>
      dueAt != null && !dueAt!.toUtc().isAfter(utcNow.toUtc());
}

ReviewStateEntry computeDeterministicReviewState({
  required String grammarId,
  required Iterable<PracticeAttemptEntry> attempts,
  required DateTime nowUtc,
  required bool isTentative,
}) {
  final eligible =
      attempts
          .where(
            (a) =>
                a.grammarId == grammarId &&
                a.isFirstIndependent &&
                !a.isSkipped,
          )
          .toList()
        ..sort(compareCanonicalAttempt);

  if (eligible.isEmpty) {
    return ReviewStateEntry(
      grammarId: grammarId,
      stage: -1,
      dueAt: null,
      algorithmVersion: 1,
      lastAttemptId: null,
      isTentative: isTentative,
      updatedAt: nowUtc.toUtc(),
    );
  }

  var stage = -1;
  DateTime? dueAt;
  String? lastAttemptId;
  for (final attempt in eligible) {
    if (attempt.isCorrect) {
      stage = stage < 0 ? 0 : (stage + 1).clamp(0, srsIntervalDays.length - 1);
    } else {
      stage = 0;
    }
    final days = srsIntervalDays[stage];
    final ts = attempt.canonicalOrderTimestamp;
    final dayStartUtc = DateTime.utc(ts.year, ts.month, ts.day);
    dueAt = dayStartUtc.add(Duration(days: days));
    lastAttemptId = attempt.attemptId;
  }

  return ReviewStateEntry(
    grammarId: grammarId,
    stage: stage,
    dueAt: dueAt,
    algorithmVersion: 1,
    lastAttemptId: lastAttemptId,
    isTentative: isTentative,
    updatedAt: nowUtc.toUtc(),
  );
}

abstract interface class PracticeStorageRepository {
  Future<void> replaceCachedQuestions(List<CuratedPracticeQuestion> questions);
  Future<List<CuratedPracticeQuestion>> loadCachedQuestions({
    String? grammarId,
  });
  Future<void> recordAttempt(PracticeAttemptEntry attempt);
  Stream<List<PracticeAttemptEntry>> watchAttempts({String? grammarId});
  Stream<List<ReviewStateEntry>> watchReviewStates();
  Future<void> applyCanonicalReviewStates(List<ReviewStateEntry> states);
}

class RecordPracticeAttempt {
  const RecordPracticeAttempt(this.repository);
  final PracticeStorageRepository repository;

  Future<void> call(PracticeAttemptEntry attempt) async {
    if (attempt.contentVersion < 1) {
      throw const FormatException('Phiên bản câu hỏi không hợp lệ.');
    }
    if (attempt.isSkipped && attempt.isCorrect) {
      throw const FormatException('Câu bỏ qua không thể tính đúng.');
    }
    if (attempt.isSkipped && attempt.isFirstIndependent) {
      throw const FormatException('Câu bỏ qua không làm thay đổi lịch ôn.');
    }
    if (attempt.retryOf != null && attempt.retryOf == attempt.attemptId) {
      throw const FormatException('ID thử lại không hợp lệ.');
    }
    if (attempt.answerText.runes.length > 500) {
      throw const FormatException('Câu trả lời tối đa 500 ký tự.');
    }
    if (attempt.selectedOptionIndex != null &&
        (attempt.selectedOptionIndex! < 0 ||
            attempt.selectedOptionIndex! > 3)) {
      throw const FormatException('Lựa chọn trắc nghiệm không hợp lệ.');
    }
    await repository.recordAttempt(attempt);
  }
}

class WatchDueReviewStates {
  const WatchDueReviewStates(this.repository);
  final PracticeStorageRepository repository;

  Stream<List<ReviewStateEntry>> call(DateTime Function() nowUtc) {
    return repository.watchReviewStates().map((states) {
      final now = nowUtc().toUtc();
      final due = states.where((state) => state.isDueAt(now)).toList()
        ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
      return due;
    });
  }
}
