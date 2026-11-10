// Automated M2 checks; manual follow-up and known limits: documents/development/M2-TEST-HANDOFF.md.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:bunly/app/config.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/grammar/presentation/grammar_screen.dart';
import 'package:bunly/features/grammar/presentation/grammar_detail_screen.dart';
import 'package:bunly/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const emailA = String.fromEnvironment('TEST_EMAIL_A');
  const emailB = String.fromEnvironment('TEST_EMAIL_B');
  const password = String.fromEnvironment('TEST_PASSWORD');
  const signupFirst = bool.fromEnvironment('TEST_SIGNUP_FIRST');
  const offlineCycle = bool.fromEnvironment('TEST_OFFLINE_CYCLE');
  testWidgets(
    'connected Android: login, profile, notes, sync and account isolation',
    (tester) async {
      // Flutter text input is deterministic; SQLite and platform/backend adapters stay real.
      tester.testTextInput.register();
      addTearDown(tester.testTextInput.unregister);
      Future<void> waitFor(Finder finder) async {
        for (var i = 0; i < 200 && finder.evaluate().isEmpty; i++) {
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
        await waitFor(find.text('Một mẫu ngữ pháp, một bước học tiếp.'));
        await tester.tap(find.text('Tra cứu'));
        await tester.pumpAndSettle();
        await waitFor(find.text('Tìm mẫu hoặc ý nghĩa'));
      }

      Future<void> syncNow() async {
        for (var i = 0; i < 200; i++) {
          final retry = find.text('Chưa đồng bộ được. Chạm để thử lại.');
          if (retry.evaluate().isNotEmpty) {
            await tester.tap(retry);
          }
          await tester.pump(const Duration(milliseconds: 100));
          final anchor = find.byTooltip('Hồ sơ học tập');
          if (anchor.evaluate().isEmpty) continue;
          final scope = ProviderScope.containerOf(tester.element(anchor));
          final config = scope.read(configProvider);
          final user = scope.read(userProvider).valueOrNull;
          if (user == null) continue;
          final db = scope.read(databaseProvider);
          final pending = await tester.runAsync(
            () =>
                (db.select(db.syncOutbox)..where(
                      (r) =>
                          r.namespace.equals(config.namespace) &
                          r.ownerId.equals(user.id),
                    ))
                    .get(),
          );
          final syncingBanner = find.textContaining('Đang tự đồng bộ');
          final failedBanner = find.text('Chưa đồng bộ được. Chạm để thử lại.');
          if (pending != null &&
              pending.isEmpty &&
              syncingBanner.evaluate().isEmpty &&
              failedBanner.evaluate().isEmpty) {
            return;
          }
        }
        fail('Auto-sync did not finish draining outbox cleanly');
      }

      final config = AppConfig.fromEnvironment();
      Future<bool> reachable() async {
        final http = HttpClient()
          ..connectionTimeout = const Duration(seconds: 1);
        try {
          final request = await http.getUrl(
            Uri.parse('${config.supabaseUrl}/auth/v1/health'),
          );
          request.headers.set('apikey', config.supabaseAnonKey);
          final response = await request.close().timeout(
            const Duration(seconds: 2),
          );
          return response.statusCode == 200;
        } on SocketException {
          return false;
        } on HttpException {
          return false;
        } on TimeoutException {
          return false;
        } finally {
          http.close(force: true);
        }
      }

      Future<void> waitNetwork(bool online) async {
        for (var i = 0; i < 100; i++) {
          final available = await tester.runAsync(reachable);
          if (available == online) {
            return;
          }
          await tester.pump(const Duration(milliseconds: 500));
        }
        fail('Emulator network did not reach the expected test state');
      }

      expect(
        emailA.isNotEmpty && emailB.isNotEmpty && password.isNotEmpty,
        isTrue,
        reason:
            'Use disposable local connected config; never production accounts.',
      );
      await app.main();
      await tester.pumpAndSettle();
      if (Supabase.instance.client.auth.currentSession != null) {
        await tester.runAsync(
          () =>
              Supabase.instance.client.auth.signOut(scope: SignOutScope.local),
        );
        await tester.pumpAndSettle();
      }
      if (signupFirst) {
        await waitFor(find.text('Tạo tài khoản mới'));
        await tester.tap(find.text('Tạo tài khoản mới'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(0), emailA);
        await tester.enterText(find.byType(TextField).at(1), password);
        await reveal(find.text('Đăng ký'));
        await tester.tap(find.text('Đăng ký'));
        await tester.pump();
        await waitFor(
          find.text(
            'Kiểm tra hộp thư để xác nhận tài khoản, sau đó đăng nhập.',
          ),
        );
        final probe = SupabaseClient(
          config.supabaseUrl,
          config.supabaseAnonKey,
        );
        var confirmed = false;
        try {
          for (var i = 0; i < 40 && !confirmed; i++) {
            final valid = await tester.runAsync(() async {
              try {
                await probe.auth.signInWithPassword(
                  email: emailA,
                  password: password,
                );
                return true;
              } on AuthException {
                return false;
              }
            });
            confirmed = valid == true;
            if (!confirmed) {
              await tester.pump(const Duration(seconds: 1));
            }
          }
          expect(
            confirmed,
            isTrue,
            reason: 'Local signup email must be verified',
          );
        } finally {
          await probe.dispose();
        }
        await tester.tap(find.text('Đã có tài khoản? Đăng nhập'));
        await tester.pumpAndSettle();
      }
      await login(emailA);
      await tester.tap(find.byTooltip('Hồ sơ học tập'));
      await tester.pumpAndSettle();
      await waitFor(find.byType(TextField));
      await tester.enterText(find.byType(TextField).at(0), 'Bunly M2 · A');
      await tester.enterText(find.byType(TextField).at(1), 'Ôn N4 mỗi ngày');
      await reveal(find.text('Lưu hồ sơ'));
      await tester.tap(find.text('Lưu hồ sơ'));
      await tester.pump();
      await waitFor(find.text('Đã lưu trên thiết bị.'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await syncNow();
      await tester.enterText(find.byType(TextField).first, 'たい');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('N5 ·').last);
      await tester.pumpAndSettle();
      await reveal(find.text('Lưu mẫu'));
      await tester.tap(find.text('Lưu mẫu'));
      await tester.pump();
      await waitFor(find.text('Bỏ lưu mẫu'));
      if (offlineCycle) {
        final http = HttpClient()
          ..connectionTimeout = const Duration(seconds: 3);
        try {
          await tester.runAsync(() async {
            final request = await http.postUrl(
              Uri.parse(
                '${const String.fromEnvironment('TEST_CONTROL_URL')}/offline',
              ),
            );
            request.headers.set(
              'X-M2-Test',
              const String.fromEnvironment('TEST_CONTROL_TOKEN'),
            );
            await request.close().timeout(const Duration(seconds: 5));
          });
        } finally {
          http.close(force: true);
        }
        await waitNetwork(false);
        final scope = ProviderScope.containerOf(
          tester.element(find.byType(GrammarDetailScreen)),
        );
        scope.invalidate(catalogProvider);
        final cached = await tester.runAsync(
          () => scope.read(catalogProvider.future),
        );
        expect(
          cached?.points,
          isNotEmpty,
          reason: 'Android must reload cached grammar while API is unreachable',
        );
      }
      final text =
          'Ghi chú từ Android M2 ${DateTime.now().millisecondsSinceEpoch}';
      await reveal(find.text('Lưu ghi chú'));
      await tester.enterText(find.byType(TextField).last, text);
      await reveal(find.text('Lưu ghi chú'));
      await tester.tap(find.text('Lưu ghi chú'));
      await tester.pump();
      await waitFor(find.text('Đã lưu trên thiết bị.'));
      await reveal(find.text(text));
      await tester.pageBack();
      await tester.pumpAndSettle();
      if (offlineCycle) {
        final scope = ProviderScope.containerOf(
          tester.element(find.byType(GrammarScreen)),
        );
        expect(
          find.text(
            'Đang đọc nội dung đã tải trên thiết bị; chưa cập nhật từ máy chủ.',
          ),
          findsOneWidget,
        );
        final db = scope.read(databaseProvider);
        final queued = await tester.runAsync(
          () => db.select(db.syncOutbox).get(),
        );
        expect(
          queued!.any(
            (row) =>
                row.entityTable == 'notes' &&
                (jsonDecode(row.payload) as Map<String, dynamic>)['content'] ==
                    text,
          ),
          isTrue,
          reason: 'Offline note must remain queued on Android',
        );
        await waitNetwork(true);
      }
      await syncNow();
      final client = Supabase.instance.client;
      final rows = await tester.runAsync(
        () => client.from('notes').select().eq('content', text),
      );
      expect(rows, hasLength(1));
      expect(rows!.single['user_id'], client.auth.currentUser!.id);
      await tester.tap(find.byTooltip('Hồ sơ học tập'));
      await tester.pumpAndSettle();
      await reveal(find.text('Đăng xuất'));
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      await waitFor(find.text('Tạo tài khoản mới'));
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
      final restored = SupabaseClient(
        config.supabaseUrl,
        config.supabaseAnonKey,
      );
      try {
        await tester.runAsync(
          () => restored.auth.recoverSession(
            jsonEncode(client.auth.currentSession!.toJson()),
          ),
        );
        expect(restored.auth.currentUser!.id, client.auth.currentUser!.id);
      } finally {
        await restored.dispose();
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Hồ sơ học tập'));
      await tester.pumpAndSettle();
      await waitFor(find.byType(TextField));
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        isEmpty,
      );
    },
  );
}
