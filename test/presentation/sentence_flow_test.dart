import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/analysis/presentation/sentence_review_screen.dart';
import 'package:bunly/features/analysis/presentation/sentence_result_screen.dart';
import '../domain/sentence_preview_test.dart' show PreviewCatalog;
import 'personal_test.dart' show PersonalFake;
import 'app_shell_test.dart' show closeLearning;
import '../support/fake_practice_storage.dart'
    show FakePracticeStorageRepository;

void main() {
  testWidgets(
    'confirm/edit demo sentence, detail preserves context, save creates one real note',
    (tester) async {
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

      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarRepositoryProvider.overrideWithValue(PreviewCatalog()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tra cứu'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Quét / nhập câu tiếng Nhật'));
      await tester.pumpAndSettle();
      expect(find.byType(SentenceReviewScreen), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('sentence-input')),
        '日本へ行きたいです。',
      );
      Future<void> confirm() async {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await reveal(find.text('Xác nhận và đối chiếu mẫu'), 250);
        await tester.tap(find.text('Xác nhận và đối chiếu mẫu'));
        await tester.pumpAndSettle();
      }

      await confirm();
      expect(find.byType(SentenceResultScreen), findsOneWidget);
      expect(find.text('Kết quả đối chiếu cục bộ'), findsOneWidget);
      expect(learning.notes, isEmpty);
      await reveal(find.text('Xem chi tiết mẫu và ví dụ'), 200);
      await tester.tap(find.text('Xem chi tiết mẫu và ví dụ'));
      await tester.pumpAndSettle();
      expect(find.text('Câu bạn đã xác nhận'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await reveal(find.text('Lưu câu làm ghi chú'), 200);
      await tester.tap(find.text('Lưu câu làm ghi chú'));
      await tester.pumpAndSettle();
      expect(learning.notes.single.content, '日本へ行きたいです。');
      expect(learning.notes.single.grammarId, 'g');
      await tester.tap(find.text('Đã lưu câu làm ghi chú trên thiết bị'));
      await tester.pumpAndSettle();
      expect(learning.notes.length, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await reveal(find.byKey(const ValueKey('sentence-input')), -250);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('sentence-input')))
            .controller!
            .text,
        '日本へ行きたいです。',
      );
      await tester.enterText(
        find.byKey(const ValueKey('sentence-input')),
        '別の文です。',
      );
      await confirm();
      expect(
        find.text('Chưa có ví dụ trùng trong kho hiện tại.'),
        findsOneWidget,
      );
      expect(find.text('Lưu câu làm ghi chú'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await closeLearning(learning);
    },
  );
}
