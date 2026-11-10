import 'package:bunly/features/learning/domain/personal_repository.dart';
import 'package:bunly/main.dart' as app;
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/grammar/presentation/grammar_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android demo uses real assets and SQLite for personal learning', (
    tester,
  ) async {
    // Flutter text input is deterministic; SQLite and platform/backend adapters stay real.
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);
    Future<void> waitFor(Finder finder) async {
      for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(finder, findsWidgets);
    }

    Future<void> reveal(Finder finder) async {
      FocusManager.instance.primaryFocus?.unfocus();
      for (var i = 0; i < 50 && tester.view.viewInsets.bottom != 0; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      final scrolling = find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first;
      final state = tester.state<ScrollableState>(scrolling);
      state.position.jumpTo(state.position.minScrollExtent);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        finder,
        150,
        scrollable: find.byType(Scrollable).last,
        maxScrolls: 30,
      );
      await tester.pumpAndSettle();
    }

    final noteText = 'Ghi chú M2 ${DateTime.now().millisecondsSinceEpoch}';
    final editedText = '$noteText đã sửa';
    await app.main();
    await tester.pumpAndSettle();
    expect(find.text('Bunly'), findsOneWidget);
    await tester.tap(find.byTooltip('Hồ sơ học tập'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Bunly M2');
    await tester.enterText(find.byType(TextField).at(1), 'Ôn ngữ pháp N4');
    await tester.ensureVisible(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();
    await waitFor(find.text('Đã lưu trên thiết bị.'));
    expect(find.text('Đã lưu trên thiết bị.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tra cứu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'たい');
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('N5 ·').last);
    await tester.pumpAndSettle();
    await reveal(find.byWidgetPredicate((widget) => widget is OutlinedButton));
    if (find.text('Bỏ lưu mẫu').evaluate().isNotEmpty) {
      await tester.tap(find.text('Bỏ lưu mẫu'));
      await tester.pumpAndSettle();
      await waitFor(find.text('Lưu mẫu'));
    }
    await tester.ensureVisible(find.text('Lưu mẫu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu mẫu'));
    await tester.pumpAndSettle();
    await waitFor(find.text('Bỏ lưu mẫu'));
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
    await reveal(find.text('Lưu ghi chú'));
    await tester.ensureVisible(find.byType(TextField).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, noteText);
    await reveal(find.text('Lưu ghi chú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu ghi chú'));
    await tester.pumpAndSettle();
    await waitFor(find.text('Đã lưu trên thiết bị.'));
    await reveal(find.text(noteText));
    expect(find.text(noteText), findsOneWidget);
    final noteTile = find.ancestor(
      of: find.text(noteText),
      matching: find.byType(ListTile),
    );
    final edit = find.descendant(
      of: noteTile,
      matching: find.byTooltip('Sửa ghi chú'),
    );
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await waitFor(find.text('Lưu chỉnh sửa'));
    await tester.enterText(find.byType(TextField).last, editedText);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      editedText,
    );
    await reveal(find.text('Lưu chỉnh sửa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu chỉnh sửa'));
    await tester.pumpAndSettle();
    await waitFor(find.text('Lưu ghi chú'));
    final scope = ProviderScope.containerOf(
      tester.element(find.byType(GrammarDetailScreen)),
    );
    final db = scope.read(databaseProvider);
    final stored = await tester.runAsync(() => db.select(db.localNotes).get());
    expect(
      stored!.map((row) => row.content),
      contains(editedText),
      reason: 'Edited note must be persisted before checking UI',
    );
    await reveal(find.text(editedText));
    expect(find.text(noteText), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chỉ mẫu đã lưu'));
    await tester.pumpAndSettle();
    expect(find.textContaining('N5 ·'), findsOneWidget);
  });
}
