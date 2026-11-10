import 'dart:async';

import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:bunly/features/learning/domain/personal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_practice_storage.dart'
    show FakePracticeStorageRepository;
import 'app_test.dart' show WidgetGrammar, SessionAuth;
import 'personal_test.dart' show PersonalFake;

class LongCatalog implements GrammarRepository {
  @override
  Future<GrammarCatalog> load() async => GrammarCatalog([
    for (var i = 0; i < 40; i++)
      GrammarPoint(
        id: 'item$i',
        pattern: '〜例文$i',
        level: i.isEven ? 'N5' : 'N4',
        category: 'experience',
        meaning: 'Mẫu số $i',
        formula: 'Động từ + ví dụ',
        usage: 'Cách dùng mẫu $i',
        examples: [],
      ),
  ], origin: GrammarOrigin.source);
}

Future<void> closeLearning(PersonalFake learning) async {
  await learning.changes.close();
  await learning.profileChanges.close();
  await learning.summaryChanges.close();
}

void main() {
  testWidgets(
    'tabs retain search and scroll; detail hides navigation and back restores context',
    (tester) async {
      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarRepositoryProvider.overrideWithValue(LongCatalog()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Một mẫu ngữ pháp, một bước học tiếp.'), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      await tester.tap(find.text('Tra cứu'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('grammar-search')),
        'mẫu',
      );
      await tester.pumpAndSettle();
      final list = find.byKey(const PageStorageKey('grammar-list'));
      await tester.drag(list, const Offset(0, -500));
      await tester.pumpAndSettle();
      ScrollPosition position() => tester
          .state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)).first,
          )
          .position;
      final before = position().pixels;
      expect(before, greaterThan(0));
      await tester.tap(find.text('Sổ học'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tra cứu'));
      await tester.pumpAndSettle();
      expect(position().pixels, before);
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(BunlyApp)),
        ).read(grammarFilterProvider).query,
        'mẫu',
      );
      await tester.tap(
        find
            .descendant(of: list, matching: find.byType(ListTile))
            .hitTestable()
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Chi tiết ngữ pháp'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(position().pixels, before);
      position().jumpTo(0);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('grammar-search')))
            .controller!
            .text,
        'mẫu',
      );
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      await tester.pumpWidget(const SizedBox());
      await closeLearning(learning);
    },
  );

  testWidgets(
    'notebook includes notes on unsaved patterns and updates without fake totals',
    (tester) async {
      final learning = PersonalFake()
        ..summary = const LearningSummary({'g'}, {'g': LearningStatus.review});
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      await learning.saveNote(
        Note(
          id: 'n',
          grammarId: 'h',
          content: 'Ghi chú mẫu chưa lưu',
          updatedAt: DateTime.utc(2026),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sổ học'));
      await tester.pumpAndSettle();
      expect(find.text('Mẫu đã lưu (1)'), findsOneWidget);
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      await tester.tap(find.text('Ghi chú (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Ghi chú mẫu chưa lưu'), findsOneWidget);
      await tester.tap(find.text('Mở mẫu và chỉnh ghi chú'));
      await tester.pumpAndSettle();
      expect(find.text('〜たい'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await learning.deleteNote('n');
      await tester.pumpAndSettle();
      expect(find.text('Ghi chú (0)'), findsOneWidget);
      expect(find.text('Ghi chú mẫu chưa lưu'), findsNothing);
      expect(find.textContaining('Chưa có ghi chú.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await closeLearning(learning);
    },
  );

  testWidgets(
    'progress uses actual self-assessment and exposes matching patterns',
    (tester) async {
      final learning = PersonalFake()
        ..summary = const LearningSummary(
          {'g'},
          {'g': LearningStatus.mastered, 'h': LearningStatus.review},
        );
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tiến độ'));
      await tester.pumpAndSettle();
      expect(
        find.text('Đã bắt đầu 2/2 mẫu trong kho hiện có.'),
        findsOneWidget,
      );
      final progressScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('progress')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.textContaining('Chưa có dữ liệu để tính tỷ lệ trả lời đúng'),
        200,
        scrollable: progressScroll,
      );
      expect(
        find.textContaining('Chưa có dữ liệu để tính tỷ lệ trả lời đúng'),
        findsOneWidget,
      );
      expect(find.textContaining('%'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Đã nắm'),
        -200,
        scrollable: progressScroll,
      );
      await tester.tap(find.text('Đã nắm'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('N4 · 〜たことがある'),
        200,
        scrollable: progressScroll,
      );
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      expect(find.text('N5 · 〜たい'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await closeLearning(learning);
    },
  );

  testWidgets(
    'account switch clears tab/query and notebook never shows previous user notes',
    (tester) async {
      final auth = SessionAuth();
      final a = PersonalFake()..summary = const LearningSummary({'g'}, {});
      final b = PersonalFake();
      final practiceA = FakePracticeStorageRepository();
      final practiceB = FakePracticeStorageRepository();
      addTearDown(() async {
        await practiceA.dispose();
        await practiceB.dispose();
      });
      await a.saveNote(
        Note(
          id: 'private',
          grammarId: 'g',
          content: 'Nội dung chỉ của A',
          updatedAt: DateTime.utc(2026),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWith(
              (ref) => ref.watch(userProvider).valueOrNull?.id == 'A' ? a : b,
            ),
            practiceStorageRepositoryProvider.overrideWith(
              (ref) => ref.watch(userProvider).valueOrNull?.id == 'A'
                  ? practiceA
                  : practiceB,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tra cứu'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('grammar-search')),
        'đã từng',
      );
      await tester.pumpAndSettle();
      auth.user = const AppUser('B', 'b@example.test');
      auth.controller.add(auth.user);
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      await tester.tap(find.text('Tra cứu'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('grammar-search')))
            .controller!
            .text,
        isEmpty,
      );
      await tester.tap(find.text('Sổ học'));
      await tester.pumpAndSettle();
      expect(find.text('Mẫu đã lưu (0)'), findsOneWidget);
      await tester.tap(find.text('Ghi chú (0)'));
      await tester.pumpAndSettle();
      expect(find.text('Nội dung chỉ của A'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await auth.controller.close();
      await closeLearning(a);
      await closeLearning(b);
    },
  );

  testWidgets(
    'loading and failed notebook query remain explicit and retryable',
    (tester) async {
      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      final pending = Completer<GrammarCatalog>();
      var failNotes = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogProvider.overrideWith((ref) => pending.future),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
            notebookNotesProvider.overrideWith(
              (ref) => failNotes
                  ? Stream.error(StateError('read failed'))
                  : Stream.value([]),
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete(await WidgetGrammar().load());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sổ học'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ghi chú'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa đọc được ghi chú.'), findsOneWidget);
      failNotes = false;
      await tester.tap(find.text('Thử lại ghi chú'));
      await tester.pumpAndSettle();
      expect(find.text('Ghi chú (0)'), findsOneWidget);
      expect(find.textContaining('Chưa có ghi chú.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await closeLearning(learning);
    },
  );

  testWidgets(
    'switching to a pending account never exposes previous account status',
    (tester) async {
      final auth = SessionAuth();
      final a = PersonalFake()
        ..summary = const LearningSummary(
          {'g'},
          {'g': LearningStatus.mastered},
        );
      final b = PersonalFake();
      final practiceA = FakePracticeStorageRepository();
      final practiceB = FakePracticeStorageRepository();
      addTearDown(() async {
        await practiceA.dispose();
        await practiceB.dispose();
      });
      final pendingSummary = Completer<LearningSummary>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningSummaryProvider.overrideWith(
              (ref) => ref.watch(userProvider).valueOrNull?.id == 'A'
                  ? Stream.value(a.summary)
                  : pendingSummary.future.asStream(),
            ),
            learningRepositoryProvider.overrideWith(
              (ref) => ref.watch(userProvider).valueOrNull?.id == 'A' ? a : b,
            ),
            practiceStorageRepositoryProvider.overrideWith(
              (ref) => ref.watch(userProvider).valueOrNull?.id == 'A'
                  ? practiceA
                  : practiceB,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      auth.user = const AppUser('B', 'b@example.test');
      auth.controller.add(auth.user);
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Tra cứu'));
      await tester.pump();
      expect(find.text('Đã nắm'), findsNothing);
      expect(find.text('Cần ôn'), findsNothing);
      pendingSummary.complete(const LearningSummary({}, {}));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Mới'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await auth.controller.close();
      await closeLearning(a);
      await closeLearning(b);
    },
  );

  for (final config in [
    (const Size(320, 640), 2.0, Brightness.light),
    (const Size(1024, 768), 1.4, Brightness.dark),
  ]) {
    testWidgets(
      'all tabs fit ${config.$1} at text scale ${config.$2} in ${config.$3}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = config.$1;
        tester.platformDispatcher.textScaleFactorTestValue = config.$2;
        tester.platformDispatcher.platformBrightnessTestValue = config.$3;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
          tester.platformDispatcher.clearPlatformBrightnessTestValue();
        });
        final learning = PersonalFake();
        final practiceStorage = FakePracticeStorageRepository();
        addTearDown(practiceStorage.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
              learningRepositoryProvider.overrideWithValue(learning),
              practiceStorageRepositoryProvider.overrideWithValue(
                practiceStorage,
              ),
            ],
            child: const BunlyApp(),
          ),
        );
        await tester.pumpAndSettle();
        for (final tab in ['Tra cứu', 'Sổ học', 'Tiến độ', 'Hôm nay']) {
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(tab),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
        await closeLearning(learning);
      },
    );
  }
}
