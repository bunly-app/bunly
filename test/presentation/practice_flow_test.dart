import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bunly/app/bunly_theme.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/ocr/domain/speech_draft.dart';
import 'package:bunly/features/practice/data/stitch_demo_practice.dart';
import 'package:bunly/features/practice/domain/demo_practice.dart';
import 'package:bunly/features/practice/presentation/practice_screen.dart';
import 'package:bunly/features/practice/presentation/writing_practice_screen.dart';

class _TestSpeechRepo implements SpeechRepository {
  @override
  Future<SpeechDraft?> listenJapanese({String? prompt}) async => SpeechDraft(
    draftId: 'voice-test-1',
    text: '富 士 山 に 登った ことが あります',
    alternatives: const ['ふじさんにのぼったことがあります'],
    confidence: 0.94,
    latencyMs: 310,
  );
}

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
    'Speaking practice mic connects ja-JP speech input and verifies grammar target on-device',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            speechRepositoryProvider.overrideWithValue(_TestSpeechRepo()),
          ],
          child: MaterialApp(
            theme: bunlyTheme(Brightness.light),
            home: const WritingPracticeScreen(voice: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final micFinder = find.byKey(const ValueKey('practice-voice-mic-button'));
      await tester.scrollUntilVisible(
        micFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(micFinder);
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '富士山に登ったことがあります。',
      );
      await tester.scrollUntilVisible(
        find.textContaining('Độ tin cậy: Rõ (94%)'),
        100,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.textContaining('Độ tin cậy: Rõ (94%)'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Xác nhận văn bản'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Xác nhận văn bản'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Đối chiếu câu tham khảo'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Đối chiếu câu tham khảo'));
      await tester.pumpAndSettle();

      expect(find.text('Khớp 〜たことがある'), findsOneWidget);
      expect(find.textContaining('登ったことがあります'), findsAtLeastNWidgets(1));
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
