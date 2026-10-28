import 'package:bunly/features/learning/domain/personal_repository.dart';
import 'package:bunly/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android demo uses real assets and SQLite for personal learning',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      expect(find.text('Bunly · Demo'), findsOneWidget);
      await tester.tap(find.byTooltip('Hồ sơ học tập'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Bunly M2');
      await tester.enterText(find.byType(TextField).at(1), 'Ôn ngữ pháp N4');
      await tester.ensureVisible(find.text('Lưu hồ sơ'));
      await tester.tap(find.text('Lưu hồ sơ'));
      await tester.pumpAndSettle();
      expect(find.text('Đã lưu trên thiết bị.'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'たい');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('N5 ·').last);
      await tester.pumpAndSettle();
      if (find.text('Bỏ lưu mẫu').evaluate().isNotEmpty) {
        await tester.tap(find.text('Bỏ lưu mẫu'));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.text('Lưu mẫu'));
      await tester.tap(find.text('Lưu mẫu'));
      await tester.pumpAndSettle();
      expect(find.text('Bỏ lưu mẫu'), findsOneWidget);
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is DropdownButtonFormField<LearningStatus>,
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đang học').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextField).last);
      await tester.enterText(
        find.byType(TextField).last,
        'Ghi chú kiểm thử M2',
      );
      await tester.ensureVisible(find.text('Lưu ghi chú'));
      await tester.tap(find.text('Lưu ghi chú'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ghi chú kiểm thử M2').last);
      expect(find.text('Ghi chú kiểm thử M2'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Sửa ghi chú').last);
      await tester.tap(find.byTooltip('Sửa ghi chú').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Đã sửa ghi chú M2');
      await tester.ensureVisible(find.text('Lưu chỉnh sửa'));
      await tester.tap(find.text('Lưu chỉnh sửa'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Đã sửa ghi chú M2'));
      expect(find.text('Ghi chú kiểm thử M2'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chỉ mẫu đã lưu'));
      await tester.pumpAndSettle();
      expect(find.textContaining('N5 ·'), findsOneWidget);
    },
  );
}
