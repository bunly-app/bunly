import 'package:flutter_test/flutter_test.dart';
import 'package:bunly/features/practice/data/stitch_demo_practice.dart';
import 'package:bunly/features/practice/domain/demo_practice.dart';

void main() {
  test(
    'demo first answer wins, accepts only explicit variants, skipped stays separate',
    () {
      final session = const StartDemoPractice(StitchDemoPractice())({
        ...PracticeKind.values,
      });
      expect(session.submit(0, '行く'), isTrue);
      expect(session.submit(0, '行った'), isFalse);
      expect(session.correct, 0);
      expect(session.submit(1, ' たべた '), isTrue);
      expect(session.correct, 1);
      expect(session.answered, 2);
      expect(session.submit(2, 'bad'), isFalse);
      final skipped = const StartDemoPractice(StitchDemoPractice())({
        PracticeKind.cloze,
      });
      expect(skipped.submit(0, null), isTrue);
      expect(skipped.skipped, 1);
      expect(skipped.answered, 0);
      expect(skipped.questions.single.accepts('食 べた'), isFalse);
    },
  );
}
