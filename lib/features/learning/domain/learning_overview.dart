import '../../grammar/domain/grammar_point.dart';
import 'personal_repository.dart';

class LearningOverview {
  LearningOverview(Iterable<GrammarPoint> points, LearningSummary summary)
    : points = List.unmodifiable(points),
      summary = LearningSummary(
        Set.unmodifiable(summary.saved),
        Map.unmodifiable(summary.statuses),
      );

  final List<GrammarPoint> points;
  final LearningSummary summary;

  List<GrammarPoint> get saved => List.unmodifiable(
    points.where((point) => summary.saved.contains(point.id)),
  );

  List<GrammarPoint> withStatus(LearningStatus status) => List.unmodifiable(
    points.where((point) => summary.statusOf(point.id) == status),
  );

  int get started => points.length - withStatus(LearningStatus.fresh).length;
}

class BuildLearningOverview {
  const BuildLearningOverview();

  LearningOverview call(List<GrammarPoint> points, LearningSummary summary) =>
      LearningOverview(points, summary);
}
