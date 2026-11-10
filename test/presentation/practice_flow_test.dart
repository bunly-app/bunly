import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bunly/app/bunly_theme.dart';
import 'package:bunly/features/practice/data/stitch_demo_practice.dart';
import 'package:bunly/features/practice/domain/demo_practice.dart';
import 'package:bunly/features/practice/presentation/practice_screen.dart';
import 'package:bunly/features/practice/presentation/writing_practice_screen.dart';

void main() {
  testWidgets(
    'voice text preview confirms and edits without ASR or AI claims',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: bunlyTheme(Brightness.light),
          home: const WritingPracticeScreen(voice: true),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> tapText(String label) async {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text(label),
          200,
          scrollable: find
              .descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      await tester.scrollUntilVisible(
        find.byType(TextField),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), '自分で書いた文です。');
      await tapText('Xác nhận văn bản');
      await tapText('Đối chiếu câu tham khảo');
      expect(find.text('Câu tham khảo'), findsOneWidget);
      await tapText('Tự sửa và thử lại');
      await tester.scrollUntilVisible(
        find.byType(TextField),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '自分で書いた文です。',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).readOnly,
        isFalse,
      );
    },
  );
  testWidgets(
    'demo answers once, shows feedback and summary from actual inputs',
    (tester) async {
      final session = const StartDemoPractice(StitchDemoPractice())({
        ...PracticeKind.values,
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: bunlyTheme(Brightness.light),
          home: PracticeSessionScreen(session: session),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> reveal(Finder finder, double delta) async {
        await tester.scrollUntilVisible(
          finder,
          delta,
          scrollable: find
              .descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('行く'));
      await reveal(find.text('Kiểm tra đáp án'), 200);
      await tester.tap(find.text('Kiểm tra đáp án'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa chính xác'), findsOneWidget);
      expect(session.correct, 0);
      await reveal(find.text('Câu tiếp theo'), 200);
      await tester.tap(find.text('Câu tiếp theo'));
      await tester.pumpAndSettle();
      await reveal(find.text('Bàn phím Nhật'), 200);
      await tester.tap(find.text('Bàn phím Nhật'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'たべた');
      await reveal(find.text('Kiểm tra đáp án'), 200);
      await tester.tap(find.text('Kiểm tra đáp án'));
      await tester.pumpAndSettle();
      expect(session.correct, 1);
      await reveal(find.text('Xem tổng kết'), 200);
      await tester.tap(find.text('Xem tổng kết'));
      await tester.pumpAndSettle();
      expect(find.text('Đúng 1/2 câu đã trả lời'), findsOneWidget);
      expect(find.text('Bỏ qua 0 câu'), findsOneWidget);
    },
  );
}
