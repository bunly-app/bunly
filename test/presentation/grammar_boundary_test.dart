import 'dart:async';

import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/config.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_practice_storage.dart'
    show FakePracticeStorageRepository;
import 'app_test.dart' show WidgetGrammar, WidgetLearning;
import 'sign_out_controller_test.dart' show ControlledSignOut;

class CatalogFixture implements GrammarRepository {
  GrammarOrigin origin = GrammarOrigin.cache;
  bool fail = false;

  @override
  Future<GrammarCatalog> load() async {
    if (fail) throw StateError('unauthorized');
    return GrammarCatalog(
      (await WidgetGrammar().load()).points,
      origin: origin,
    );
  }
}

void main() {
  testWidgets(
    'cache notice follows domain result and disappears on errors or fresh loads',
    (tester) async {
      final catalog = CatalogFixture();
      final learning = WidgetLearning();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarRepositoryProvider.overrideWithValue(catalog),
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
      final notice = find.text(
        'Đang đọc nội dung đã tải trên thiết bị; chưa cập nhật từ máy chủ.',
      );
      expect(notice, findsOneWidget);
      final scope = ProviderScope.containerOf(
        tester.element(find.byType(BunlyApp)),
      );
      catalog.fail = true;
      scope.invalidate(catalogProvider);
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
      expect(find.text('Chưa tải được kho ngữ pháp.'), findsOneWidget);
      catalog.fail = false;
      catalog.origin = GrammarOrigin.source;
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await learning.changes.close();
    },
  );

  testWidgets(
    'logout disables repeated taps, reports failure, and retries into auth screen',
    (tester) async {
      final auth = ControlledSignOut()..pending = Completer<void>();
      final learning = WidgetLearning();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWithValue(const AppConfig(connected: true)),
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
            learningSyncProvider.overrideWithValue(null),
            pendingSyncProvider.overrideWith((ref) => Stream.value(0)),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Hồ sơ học tập'));
      await tester.pumpAndSettle();
      final profileScroll = find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Đăng xuất'),
        200,
        scrollable: profileScroll,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng xuất'));
      await tester.pump();
      expect(
        tester
            .widget<ButtonStyleButton>(
              find.ancestor(
                of: find.text('Đang đăng xuất…'),
                matching: find.byWidgetPredicate(
                  (widget) => widget is ButtonStyleButton,
                ),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(auth.calls, 1);
      auth.pending!.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa thể đăng xuất. Hãy thử lại.'), findsOneWidget);
      expect(auth.currentUser?.id, 'A');
      auth.pending = null;
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(auth.calls, 2);
      expect(find.text('Tạo tài khoản mới'), findsOneWidget);
      expect(find.text('Kho ngữ pháp'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await auth.controller.close();
      await learning.changes.close();
    },
  );
}
