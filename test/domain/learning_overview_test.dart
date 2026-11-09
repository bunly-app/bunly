import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/learning/domain/learning_overview.dart';
import 'package:bunly/features/learning/domain/personal_repository.dart';
import 'package:flutter_test/flutter_test.dart';

GrammarPoint point(String id) => GrammarPoint(
  id: id,
  pattern: id,
  level: 'N5',
  category: 'test',
  meaning: id,
  formula: id,
  usage: id,
  examples: [],
);

void main() {
  test(
    'overview counts current catalog only and separates self-assessed states',
    () {
      final points = [point('a'), point('b'), point('c')];
      final overview = const BuildLearningOverview()(
        points,
        const LearningSummary(
          {'b', 'not-cached'},
          {
            'a': LearningStatus.review,
            'b': LearningStatus.mastered,
            'not-cached': LearningStatus.learning,
          },
        ),
      );
      expect(overview.saved.map((p) => p.id), ['b']);
      expect(overview.started, 2);
      expect(overview.withStatus(LearningStatus.fresh).map((p) => p.id), ['c']);
      expect(overview.withStatus(LearningStatus.learning), isEmpty);
      expect(
        LearningStatus.values.fold<int>(
          0,
          (sum, status) => sum + overview.withStatus(status).length,
        ),
        3,
      );
      points.clear();
      expect(overview.points, hasLength(3));
    },
  );

  test('empty overview has no invented progress', () {
    final overview = const BuildLearningOverview()(
      [],
      const LearningSummary({}, {}),
    );
    expect(overview.started, 0);
    expect(overview.saved, isEmpty);
    for (final status in LearningStatus.values) {
      expect(overview.withStatus(status), isEmpty);
    }
  });
}
