import 'package:bunly/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const emailA = String.fromEnvironment('TEST_EMAIL_A');
  const emailB = String.fromEnvironment('TEST_EMAIL_B');
  const password = String.fromEnvironment('TEST_PASSWORD');
  const pace = int.fromEnvironment('DEMO_PACE_SECONDS');
  testWidgets(
    'connected Android: login, profile, notes, sync and account isolation',
    (tester) async {
      Future<void> waitFor(Finder finder) async {
        for (var i = 0; i < 200 && finder.evaluate().isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(finder, findsWidgets);
      }

      Future<void> pause() async {
        if (pace > 0) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(seconds: pace)),
          );
        }
      }

      Future<void> reveal(Finder finder) async {
        final scrolling = find.byType(Scrollable).last;
        final state = tester.state<ScrollableState>(scrolling);
        state.position.jumpTo(state.position.minScrollExtent);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          finder,
          150,
          scrollable: scrolling,
          maxScrolls: 40,
        );
        await tester.pumpAndSettle();
      }

      Future<void> login(String email) async {
        await waitFor(find.text('Tạo tài khoản mới'));
        await tester.enterText(find.byType(TextField).at(0), email);
        await tester.enterText(find.byType(TextField).at(1), password);
        await tester.tap(find.text('Đăng nhập').last);
        await tester.pumpAndSettle();
        await waitFor(find.text('Kho ngữ pháp'));
      }

      Future<void> syncNow() async {
        final button = find.widgetWithText(TextButton, 'Đồng bộ');
        for (var i = 0; i < 200; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (button.evaluate().isNotEmpty &&
              tester.widget<TextButton>(button).onPressed != null) {
            break;
          }
        }
        await tester.tap(button);
        await tester.pump();
        await waitFor(find.text('Đã đồng bộ lần gần nhất.'));
      }

      expect(
        emailA.isNotEmpty && emailB.isNotEmpty && password.isNotEmpty,
        isTrue,
        reason:
            'Use disposable local connected config; never production accounts.',
      );
      await app.main();
      await tester.pumpAndSettle();
      await login(emailA);
      await pause();
      await tester.tap(find.byTooltip('Hồ sơ học tập'));
      await tester.pumpAndSettle();
      await waitFor(find.byType(TextField));
      await tester.enterText(find.byType(TextField).at(0), 'Bunly M2 · A');
      await tester.enterText(find.byType(TextField).at(1), 'Ôn N4 mỗi ngày');
      await reveal(find.text('Lưu hồ sơ'));
      await tester.tap(find.text('Lưu hồ sơ'));
      await tester.pump();
      await waitFor(find.text('Đã lưu trên thiết bị.'));
      await pause();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await syncNow();
      await pause();
      await tester.enterText(find.byType(TextField).first, 'たい');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('N5 ·').last);
      await tester.pumpAndSettle();
      await reveal(find.text('Lưu mẫu'));
      await tester.tap(find.text('Lưu mẫu'));
      await tester.pump();
      await waitFor(find.text('Bỏ lưu mẫu'));
      await pause();
      final text =
          'Ghi chú từ Android M2 ${DateTime.now().millisecondsSinceEpoch}';
      await reveal(find.text('Lưu ghi chú'));
      await tester.enterText(find.byType(TextField).last, text);
      await tester.ensureVisible(find.text('Lưu ghi chú'));
      await tester.tap(find.text('Lưu ghi chú'));
      await tester.pump();
      await waitFor(find.text('Đã lưu trên thiết bị.'));
      await reveal(find.text(text));
      await pause();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await syncNow();
      await pause();
      final client = Supabase.instance.client;
      final rows = await tester.runAsync(
        () => client.from('notes').select().eq('content', text),
      );
      expect(rows, hasLength(1));
      expect(rows!.single['user_id'], client.auth.currentUser!.id);
      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      await waitFor(find.text('Tạo tài khoản mới'));
      await pause();
      await login(emailB);
      await syncNow();
      await tester.enterText(find.byType(TextField).first, 'たい');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('N5 ·').last);
      await tester.pumpAndSettle();
      await reveal(find.text('Lưu mẫu'));
      expect(find.text('Bỏ lưu mẫu'), findsNothing);
      expect(find.text(text), findsNothing);
      final inaccessible = await tester.runAsync(
        () => client.from('notes').select().eq('content', text),
      );
      expect(inaccessible, isEmpty);
      await pause();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Hồ sơ học tập'));
      await tester.pumpAndSettle();
      await waitFor(find.byType(TextField));
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        isEmpty,
      );
      await pause();
    },
  );
}
