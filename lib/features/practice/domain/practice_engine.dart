import '../../grammar/domain/grammar_point.dart';
import 'practice_storage.dart';

enum PracticeSessionSource { dueSrs, weakMistakes, byGrammar, custom }

class WeakGrammarStat {
  const WeakGrammarStat({
    required this.grammarId,
    required this.wrongIndependentCount,
    required this.unresolvedWrongCount,
    required this.totalIndependentCount,
    this.lastWrongAt,
    this.reviewState,
  });

  final String grammarId;
  final int wrongIndependentCount;
  final int unresolvedWrongCount;
  final int totalIndependentCount;
  final DateTime? lastWrongAt;
  final ReviewStateEntry? reviewState;
}

class PracticeAccuracyStats {
  const PracticeAccuracyStats({
    required this.independentAnswered,
    required this.independentCorrect,
    required this.skippedCount,
    required this.retryCount,
  });

  final int independentAnswered;
  final int independentCorrect;
  final int skippedCount;
  final int retryCount;

  double? get accuracyRatio => independentAnswered == 0
      ? null
      : independentCorrect / independentAnswered;

  int? get accuracyPercent =>
      accuracyRatio == null ? null : (accuracyRatio! * 100).round();
}

class PracticeAnalyticsSnapshot {
  const PracticeAnalyticsSnapshot({
    required this.overall,
    required this.last7Days,
    required this.weakGrammars,
    required this.unresolvedErrorCount,
    required this.resolvedErrorCount,
    required this.unresolvedQuestionIds,
  });

  final PracticeAccuracyStats overall;
  final PracticeAccuracyStats last7Days;
  final List<WeakGrammarStat> weakGrammars;
  final int unresolvedErrorCount;
  final int resolvedErrorCount;
  final Set<String> unresolvedQuestionIds;
}

class QuestionHistoryOutcome {
  const QuestionHistoryOutcome({
    required this.everWrong,
    required this.isCurrentlyResolved,
  });

  final bool everWrong;
  final bool isCurrentlyResolved;
}

Map<String, QuestionHistoryOutcome> computeQuestionOutcomes(
  Iterable<PracticeAttemptEntry> attempts,
) {
  final byQuestion = <String, List<PracticeAttemptEntry>>{};
  for (final attempt in attempts) {
    if (!attempt.isFirstIndependent || attempt.isSkipped) continue;
    byQuestion.putIfAbsent(attempt.questionId, () => []).add(attempt);
  }

  final outcomes = <String, QuestionHistoryOutcome>{};
  for (final entry in byQuestion.entries) {
    final sorted = List<PracticeAttemptEntry>.of(entry.value)
      ..sort(compareCanonicalAttempt);
    final everWrong = sorted.any((a) => !a.isCorrect);
    final latestCorrect = sorted.last.isCorrect;
    outcomes[entry.key] = QuestionHistoryOutcome(
      everWrong: everWrong,
      isCurrentlyResolved: everWrong && latestCorrect,
    );
  }
  return outcomes;
}

PracticeAnalyticsSnapshot computePracticeAnalytics({
  required Iterable<PracticeAttemptEntry> attempts,
  required Iterable<ReviewStateEntry> reviewStates,
  required DateTime nowUtc,
}) {
  final utcNow = nowUtc.toUtc();
  final cutoff = utcNow.subtract(const Duration(days: 7));
  final reviewByGrammar = <String, ReviewStateEntry>{
    for (final state in reviewStates) state.grammarId: state,
  };

  var allIndAnswered = 0;
  var allIndCorrect = 0;
  var allSkipped = 0;
  var allRetry = 0;

  var weekIndAnswered = 0;
  var weekIndCorrect = 0;
  var weekSkipped = 0;
  var weekRetry = 0;

  final wrongByGrammar = <String, int>{};
  final totalByGrammar = <String, int>{};
  final lastWrongByGrammar = <String, DateTime>{};

  final list = attempts.toList(growable: false);
  for (final a in list) {
    final ts = a.canonicalOrderTimestamp;
    final inWeek = !ts.isBefore(cutoff);

    if (a.isSkipped) {
      allSkipped++;
      if (inWeek) weekSkipped++;
      continue;
    }

    if (!a.isFirstIndependent || a.retryOf != null) {
      allRetry++;
      if (inWeek) weekRetry++;
      continue;
    }

    allIndAnswered++;
    totalByGrammar[a.grammarId] = (totalByGrammar[a.grammarId] ?? 0) + 1;
    if (a.isCorrect) {
      allIndCorrect++;
    } else {
      wrongByGrammar[a.grammarId] = (wrongByGrammar[a.grammarId] ?? 0) + 1;
      final prev = lastWrongByGrammar[a.grammarId];
      if (prev == null || ts.isAfter(prev)) {
        lastWrongByGrammar[a.grammarId] = ts;
      }
    }

    if (inWeek) {
      weekIndAnswered++;
      if (a.isCorrect) weekIndCorrect++;
    }
  }

  final outcomes = computeQuestionOutcomes(list);
  final unresolvedQuestionIds = <String>{};
  var resolvedErrors = 0;
  for (final entry in outcomes.entries) {
    if (!entry.value.everWrong) continue;
    if (entry.value.isCurrentlyResolved) {
      resolvedErrors++;
    } else {
      unresolvedQuestionIds.add(entry.key);
    }
  }

  // Count unresolved wrong questions per grammar by walking latest independent answer per question.
  final unresolvedByGrammar = <String, int>{};
  final questionToGrammar = <String, String>{};
  for (final a in list) {
    questionToGrammar[a.questionId] = a.grammarId;
  }
  for (final qId in unresolvedQuestionIds) {
    final gId = questionToGrammar[qId];
    if (gId != null) {
      unresolvedByGrammar[gId] = (unresolvedByGrammar[gId] ?? 0) + 1;
    }
  }

  final weakGrammars = <WeakGrammarStat>[];
  for (final entry in wrongByGrammar.entries) {
    weakGrammars.add(
      WeakGrammarStat(
        grammarId: entry.key,
        wrongIndependentCount: entry.value,
        unresolvedWrongCount: unresolvedByGrammar[entry.key] ?? 0,
        totalIndependentCount: totalByGrammar[entry.key] ?? entry.value,
        lastWrongAt: lastWrongByGrammar[entry.key],
        reviewState: reviewByGrammar[entry.key],
      ),
    );
  }
  weakGrammars.sort((a, b) {
    final unresCmp = b.unresolvedWrongCount.compareTo(a.unresolvedWrongCount);
    if (unresCmp != 0) return unresCmp;
    final wrongCmp = b.wrongIndependentCount.compareTo(a.wrongIndependentCount);
    if (wrongCmp != 0) return wrongCmp;
    final aTs =
        a.lastWrongAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final bTs =
        b.lastWrongAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return bTs.compareTo(aTs);
  });

  return PracticeAnalyticsSnapshot(
    overall: PracticeAccuracyStats(
      independentAnswered: allIndAnswered,
      independentCorrect: allIndCorrect,
      skippedCount: allSkipped,
      retryCount: allRetry,
    ),
    last7Days: PracticeAccuracyStats(
      independentAnswered: weekIndAnswered,
      independentCorrect: weekIndCorrect,
      skippedCount: weekSkipped,
      retryCount: weekRetry,
    ),
    weakGrammars: weakGrammars,
    unresolvedErrorCount: unresolvedQuestionIds.length,
    resolvedErrorCount: resolvedErrors,
    unresolvedQuestionIds: unresolvedQuestionIds,
  );
}

List<CuratedPracticeQuestion> selectCuratedPracticeQuestions({
  required List<CuratedPracticeQuestion> bank,
  required PracticeSessionSource source,
  required Map<String, GrammarPoint> catalogById,
  required List<ReviewStateEntry> dueReviewStates,
  required List<PracticeAttemptEntry> attempts,
  String? grammarId,
  String? level,
  Set<PracticeBankType> allowedTypes = const {
    PracticeBankType.mcq,
    PracticeBankType.cloze,
  },
  int maxQuestions = 10,
}) {
  if (allowedTypes.isEmpty || maxQuestions <= 0 || bank.isEmpty) {
    return const [];
  }

  final filtered = bank.where((q) {
    if (!allowedTypes.contains(q.type)) return false;
    if (level != null) {
      final point = catalogById[q.grammarId];
      if (point == null || point.level != level) return false;
    }
    return true;
  }).toList();

  List<CuratedPracticeQuestion> selected;
  switch (source) {
    case PracticeSessionSource.byGrammar:
      if (grammarId == null || grammarId.isEmpty) return const [];
      selected = filtered.where((q) => q.grammarId == grammarId).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      break;
    case PracticeSessionSource.dueSrs:
      final dueOrder = <String, int>{};
      final sortedDue = List<ReviewStateEntry>.of(dueReviewStates)
        ..sort((a, b) {
          final aDue = a.dueAt ?? DateTime.utc(1970);
          final bDue = b.dueAt ?? DateTime.utc(1970);
          return aDue.compareTo(bDue);
        });
      for (var i = 0; i < sortedDue.length; i++) {
        dueOrder[sortedDue[i].grammarId] = i;
      }
      selected =
          filtered.where((q) => dueOrder.containsKey(q.grammarId)).toList()
            ..sort((a, b) {
              final orderCmp = dueOrder[a.grammarId]!.compareTo(
                dueOrder[b.grammarId]!,
              );
              if (orderCmp != 0) return orderCmp;
              return a.id.compareTo(b.id);
            });
      break;
    case PracticeSessionSource.weakMistakes:
      final outcomes = computeQuestionOutcomes(attempts);
      final unresolvedQIds = <String>{};
      final unresolvedGrammarIds = <String>{};
      for (final entry in outcomes.entries) {
        if (entry.value.everWrong && !entry.value.isCurrentlyResolved) {
          unresolvedQIds.add(entry.key);
        }
      }
      for (final a in attempts) {
        if (unresolvedQIds.contains(a.questionId)) {
          unresolvedGrammarIds.add(a.grammarId);
        }
      }
      selected =
          filtered
              .where(
                (q) =>
                    unresolvedQIds.contains(q.id) ||
                    unresolvedGrammarIds.contains(q.grammarId),
              )
              .toList()
            ..sort((a, b) {
              // Exact unresolved wrong questions come first.
              final aExact = unresolvedQIds.contains(a.id) ? 0 : 1;
              final bExact = unresolvedQIds.contains(b.id) ? 0 : 1;
              if (aExact != bExact) return aExact.compareTo(bExact);
              return a.id.compareTo(b.id);
            });
      break;
    case PracticeSessionSource.custom:
      selected = List<CuratedPracticeQuestion>.of(filtered)
        ..sort((a, b) {
          final lvlA = catalogById[a.grammarId]?.level ?? 'Z';
          final lvlB = catalogById[b.grammarId]?.level ?? 'Z';
          final lvlCmp = lvlA.compareTo(lvlB);
          if (lvlCmp != 0) return lvlCmp;
          final gCmp = a.grammarId.compareTo(b.grammarId);
          if (gCmp != 0) return gCmp;
          return a.id.compareTo(b.id);
        });
      break;
  }

  if (selected.length <= maxQuestions) return List.unmodifiable(selected);
  return List.unmodifiable(selected.take(maxQuestions));
}

List<String> buildClozeWordBank(
  CuratedPracticeQuestion question,
  List<CuratedPracticeQuestion> pool,
) {
  if (question.options.isNotEmpty) return question.options;
  final primary = question.acceptedAnswers.isNotEmpty
      ? question.acceptedAnswers.first.trim()
      : '';
  if (primary.isEmpty) return const [];

  final distractors = <String>[];
  final seen = <String>{
    primary,
    ...question.acceptedAnswers.map((e) => e.trim()),
  };

  // Prefer same-grammar alternatives first, then broader pool, sorted deterministically.
  final sameGrammar = pool.where(
    (q) => q.id != question.id && q.grammarId == question.grammarId,
  );
  final others = pool.where(
    (q) => q.id != question.id && q.grammarId != question.grammarId,
  );

  for (final candidate in [...sameGrammar, ...others]) {
    final tokens = candidate.type == PracticeBankType.mcq
        ? candidate.options
        : candidate.acceptedAnswers;
    for (final raw in tokens) {
      final token = raw.trim();
      if (token.isEmpty || seen.contains(token)) continue;
      seen.add(token);
      distractors.add(token);
      if (distractors.length >= 3) break;
    }
    if (distractors.length >= 3) break;
  }

  if (distractors.isEmpty) return const [];
  final combined = <String>[primary, ...distractors]
    ..sort((a, b) => a.compareTo(b));
  return List.unmodifiable(combined);
}

List<PracticeAttemptEntry> filterPracticeHistory({
  required List<PracticeAttemptEntry> attempts,
  required Map<String, CuratedPracticeQuestion> questionsById,
  required DateTime nowUtc,
  bool errorsOnly = false,
  String kindFilter = 'Tất cả',
  String rangeFilter = '7 ngày qua',
  String errorFilter = 'Tất cả',
  Set<String> unresolvedQuestionIds = const {},
}) {
  final utcNow = nowUtc.toUtc();
  final todayStart = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);

  final filtered = attempts.where((a) {
    final ts = a.canonicalOrderTimestamp;

    if (errorsOnly) {
      if (a.isSkipped || a.isCorrect) return false;
      final q = questionsById[a.questionId];
      switch (errorFilter) {
        case 'Chưa khắc phục':
          if (!unresolvedQuestionIds.contains(a.questionId)) return false;
          break;
        case 'Trắc nghiệm':
          if (q?.type != PracticeBankType.mcq) return false;
          break;
        case 'Điền khuyết':
          if (q?.type != PracticeBankType.cloze) return false;
          break;
        default:
          break;
      }
      return true;
    }

    if (kindFilter == 'Dịch' || kindFilter == 'Nói') {
      return false;
    }

    switch (rangeFilter) {
      case 'Hôm nay':
        if (ts.isBefore(todayStart)) return false;
        break;
      case '7 ngày qua':
        if (ts.isBefore(utcNow.subtract(const Duration(days: 7)))) return false;
        break;
      case 'Tháng này':
        if (ts.isBefore(DateTime.utc(utcNow.year, utcNow.month, 1))) {
          return false;
        }
        break;
      default:
        break;
    }

    return true;
  }).toList();

  filtered.sort((a, b) => compareCanonicalAttempt(b, a));
  return List.unmodifiable(filtered);
}

String formatSrsStageLabel(int stage) {
  if (stage < 0) return 'Chưa có lịch ôn';
  final safe = stage.clamp(0, srsIntervalDays.length - 1);
  return 'Mốc ${srsIntervalDays[safe]} ngày (Bậc ${safe + 1}/${srsIntervalDays.length})';
}
