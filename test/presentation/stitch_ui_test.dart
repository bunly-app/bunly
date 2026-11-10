import 'dart:async';

import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/bunly_theme.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/analysis/domain/sentence_preview.dart';
import 'package:bunly/features/analysis/presentation/sentence_result_screen.dart';
import 'package:bunly/features/analysis/presentation/sentence_review_screen.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/auth/presentation/auth_screen.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/grammar/presentation/grammar_detail_screen.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:bunly/features/learning/domain/personal_repository.dart';
import 'package:bunly/features/learning/presentation/notebook_screen.dart';
import 'package:bunly/features/learning/presentation/profile_screen.dart';
import 'package:bunly/features/learning/presentation/progress_screen.dart';
import 'package:bunly/features/practice/data/stitch_demo_practice.dart';
import 'package:bunly/features/practice/domain/demo_practice.dart';
import 'package:bunly/features/practice/presentation/practice_history_screen.dart';
import 'package:bunly/features/practice/presentation/practice_screen.dart';
import 'package:bunly/features/practice/presentation/writing_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_shell_test.dart' show LongCatalog, closeLearning;
import 'app_test.dart' show WidgetGrammar;
import 'personal_test.dart' show PersonalFake;
import '../support/fake_practice_storage.dart'
    show FakePracticeStorageRepository;

class _RefreshableCatalog implements GrammarRepository {
  _RefreshableCatalog(this.refreshCompleter);

  final Completer<GrammarCatalog> refreshCompleter;
  int calls = 0;

  @override
  Future<GrammarCatalog> load() async {
    calls++;
    if (calls == 1) {
      return GrammarCatalog(const [_detailPoint], origin: GrammarOrigin.cache);
    }
    return refreshCompleter.future;
  }
}

const _detailPoint = GrammarPoint(
  id: 'g',
  pattern: '〜たことがある',
  level: 'N4',
  category: 'experience',
  meaning: 'Đã từng (trải nghiệm trong quá khứ)',
  formula: 'Động từ thể た + ことがある',
  usage: 'Diễn tả kinh nghiệm từng làm việc gì đó ít nhất một lần.',
  examples: [
    GrammarExample('日本へ行ったことがある。', 'Tôi đã từng đi Nhật Bản.'),
    GrammarExample('納豆を食べたことがあります。', 'Tôi đã từng ăn natto.'),
  ],
);

void main() {
  testWidgets(
    'S00a/S00b: slow session restore reveals retry UI after 5s and recovers',
    (tester) async {
      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      var attempts = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith((ref) {
              attempts++;
              if (attempts == 1) {
                return Completer<AppUser?>().future.asStream();
              }
              return Stream.value(const AppUser('A', 'a@example.test'));
            }),
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pump();
      expect(find.text('Đang khôi phục phiên học…'), findsOneWidget);
      expect(find.text('Bảo mật thiết bị'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      expect(
        find.text('Kiểm tra phiên làm việc mất nhiều thời gian hơn dự kiến'),
        findsOneWidget,
      );
      expect(find.text('Bộ nhớ cục bộ an toàn'), findsOneWidget);
      expect(find.text('NGUYÊN TẮC BẢO VỆ PHIÊN'), findsOneWidget);
      expect(find.text('Thử kết nối lại'), findsOneWidget);
      await tester.tap(find.text('Thử kết nối lại'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.text('Bunly'), findsOneWidget);
      expect(find.text('Một mẫu ngữ pháp, một bước học tiếp.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await closeLearning(learning);
    },
  );

  testWidgets('S07: tapping active Tra cứu destination scrolls back to top', (
    tester,
  ) async {
    final learning = PersonalFake();
    final practiceStorage = FakePracticeStorageRepository();
    addTearDown(practiceStorage.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          grammarRepositoryProvider.overrideWithValue(LongCatalog()),
          learningRepositoryProvider.overrideWithValue(learning),
          practiceStorageRepositoryProvider.overrideWithValue(practiceStorage),
        ],
        child: const BunlyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Tra cứu'),
      ),
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
    expect(position().pixels, greaterThan(0));
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Tra cứu'),
      ),
    );
    await tester.pumpAndSettle();
    expect(position().pixels, 0);
    await tester.pumpWidget(const SizedBox());
    await closeLearning(learning);
  });

  testWidgets(
    'L03/L06: grammar uses skeleton initially and preserves cached rows during manual refresh',
    (tester) async {
      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      final pendingInitial = Completer<GrammarCatalog>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogProvider.overrideWith((ref) => pendingInitial.future),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Tra cứu'));
      await tester.pump();
      final grammarList = find.byKey(const PageStorageKey('grammar-list'));
      expect(find.text('Đang tải cấu trúc từ kho dữ liệu…'), findsOneWidget);
      expect(
        find.descendant(
          of: grammarList,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      final refreshCompleter = Completer<GrammarCatalog>();
      final repo = _RefreshableCatalog(refreshCompleter);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarRepositoryProvider.overrideWithValue(repo),
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
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      expect(
        find.text(
          'Đang đọc nội dung đã tải trên thiết bị; chưa cập nhật từ máy chủ.',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.text(
          'Đang đọc nội dung đã tải trên thiết bị; chưa cập nhật từ máy chủ.',
        ),
      );
      await tester.pump();
      expect(find.text('Đang kiểm tra cập nhật…'), findsOneWidget);
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      refreshCompleter.complete(await WidgetGrammar().load());
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Đang đọc nội dung đã tải trên thiết bị; chưa cập nhật từ máy chủ.',
        ),
        findsNothing,
      );
      expect(find.text('Đang kiểm tra cập nhật…'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('N5 · 〜たい'),
        200,
        scrollable: find
            .descendant(of: grammarList, matching: find.byType(Scrollable))
            .first,
      );
      expect(find.text('N5 · 〜たい'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await closeLearning(learning);
    },
  );

  testWidgets(
    'S13: notebook renders skeleton while loading and filters saved items by N5, N4, and notes',
    (tester) async {
      final learning = PersonalFake()
        ..summary = const LearningSummary(
          {'g', 'h'},
          {'g': LearningStatus.mastered},
        );
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(practiceStorage.dispose);
      await learning.saveNote(
        Note(
          id: 'n1',
          grammarId: 'g',
          content: 'Ghi chú cho mẫu N4',
          updatedAt: DateTime.utc(2026),
        ),
      );

      final pendingCatalog = Completer<GrammarCatalog>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogProvider.overrideWith((ref) => pendingCatalog.future),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Sổ học'));
      await tester.pump();
      final loadingNotebook = find.byKey(
        const PageStorageKey('notebook-loading'),
      );
      expect(loadingNotebook, findsOneWidget);
      expect(
        find.descendant(
          of: loadingNotebook,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsNothing,
      );

      pendingCatalog.complete(await WidgetGrammar().load());
      await tester.pumpAndSettle();
      expect(find.text('Mẫu đã lưu (2)'), findsOneWidget);
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'N5'));
      await tester.pumpAndSettle();
      expect(find.text('N5 · 〜たい'), findsOneWidget);
      expect(find.text('N4 · 〜たことがある'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'N4'));
      await tester.pumpAndSettle();
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      expect(find.text('N5 · 〜たい'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'Có ghi chú'));
      await tester.pumpAndSettle();
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      expect(find.text('N5 · 〜たい'), findsNothing);

      await tester.tap(find.text('Ghi chú (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'N5'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có ghi chú phù hợp bộ lọc này.'), findsOneWidget);
      await tester.tap(find.text('Xem tất cả ghi chú'));
      await tester.pumpAndSettle();
      expect(find.text('Ghi chú cho mẫu N4'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await closeLearning(learning);
    },
  );

  for (final config in [
    (const Size(320, 640), 2.0, Brightness.light),
    (const Size(1024, 768), 1.4, Brightness.dark),
  ]) {
    testWidgets(
      'Stitch screens fit ${config.$1} at text scale ${config.$2} in ${config.$3}',
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

        final learning = PersonalFake()
          ..summary = const LearningSummary(
            {'g'},
            {'g': LearningStatus.learning},
          );
        final practiceStorage = FakePracticeStorageRepository();
        addTearDown(practiceStorage.dispose);
        await learning.saveNote(
          Note(
            id: 'note-1',
            grammarId: 'g',
            content: 'Ví dụ ghi chú dài để kiểm tra tự xuống dòng trong thẻ.',
            updatedAt: DateTime.utc(2026),
          ),
        );

        Future<void> pumpScoped(Widget home) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
                learningRepositoryProvider.overrideWithValue(learning),
                practiceStorageRepositoryProvider.overrideWithValue(
                  practiceStorage,
                ),
              ],
              child: MaterialApp(
                theme: bunlyTheme(Brightness.light),
                darkTheme: bunlyTheme(Brightness.dark),
                home: home,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        Finder outerScrollable() {
          final inList = find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          );
          if (inList.evaluate().isNotEmpty) return inList.first;
          final inCustom = find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          );
          if (inCustom.evaluate().isNotEmpty) return inCustom.first;
          return find
              .descendant(
                of: find.byType(SingleChildScrollView),
                matching: find.byType(Scrollable),
              )
              .first;
        }

        Future<void> reveal(Finder target, {double delta = 180}) async {
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            target,
            delta,
            scrollable: outerScrollable(),
          );
          await tester.pumpAndSettle();
          final error = tester.takeException();
          expect(error, isNull);
        }

        Future<void> revealAndTap(Finder target, {double delta = 180}) async {
          await reveal(target, delta: delta);
          await tester.tap(target);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        // S00a / S00b slow session restore fits tight/large viewports
        final pendingUser = Completer<AppUser?>();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userProvider.overrideWith((ref) => pendingUser.future.asStream()),
              grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
              learningRepositoryProvider.overrideWithValue(learning),
              practiceStorageRepositoryProvider.overrideWithValue(
                practiceStorage,
              ),
            ],
            child: const BunlyApp(),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(seconds: 6));
        expect(find.text('NGUYÊN TẮC BẢO VỆ PHIÊN'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        // Populated Notebook (S13) & Progress (S20)
        await pumpScoped(Scaffold(body: NotebookScreen(onBrowse: () {})));
        await reveal(find.text('Chi tiết và ghi chú'));
        await pumpScoped(const Scaffold(body: ProgressScreen()));
        await reveal(find.text('Thực chiến 7 ngày qua'));
        await reveal(find.text('Mở sổ lỗi cần ôn'));

        // Auth sign-in & sign-up toggle
        await pumpScoped(const AuthScreen());
        await revealAndTap(find.text('Tạo tài khoản mới'));
        expect(find.text('Xác nhận mật khẩu'), findsOneWidget);

        // Detail with pinned source sentence & examples (also scroll lower half)
        await pumpScoped(
          const GrammarDetailScreen(
            point: _detailPoint,
            sourceSentence: '日本へ行ったことがある。',
          ),
        );
        await reveal(find.text('Ghi chú của bạn'));

        // Profile
        await pumpScoped(const ProfileScreen());
        await reveal(find.text('Lưu hồ sơ'));

        // Sentence review & insert
        await pumpScoped(
          const SentenceReviewScreen(initialText: '日本へ行ったことがある'),
        );
        await revealAndTap(find.text('。'));

        // Sentence result (matched & empty)
        await pumpScoped(
          const SentenceResultScreen(
            key: ValueKey('result-match'),
            result: SentencePreview(
              text: '日本へ行ったことがある。',
              matches: [_detailPoint],
            ),
          ),
        );
        await reveal(find.text('Lưu câu làm ghi chú'));
        await pumpScoped(
          const SentenceResultScreen(
            key: ValueKey('result-empty'),
            result: SentencePreview(text: '別の文です。', matches: []),
          ),
        );

        // Practice setup
        await pumpScoped(const PracticeSetupScreen());
        await reveal(find.text('Bắt đầu luyện tập (2 câu)'));

        // Practice session (MCQ -> feedback -> Cloze word bank & IME -> feedback -> Summary)
        final session = const StartDemoPractice(StitchDemoPractice())({
          ...PracticeKind.values,
        });
        await pumpScoped(PracticeSessionScreen(session: session));
        await revealAndTap(find.text('行く'));
        await revealAndTap(find.text('Kiểm tra đáp án'));
        await reveal(find.text('Quy tắc nói:'));
        await revealAndTap(find.text('Câu tiếp theo'));
        await revealAndTap(find.text('食べた'));
        await reveal(find.text('Bàn phím Nhật'), delta: -120);
        await tester.tap(find.text('Bàn phím Nhật'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await reveal(find.byType(TextField), delta: -120);
        await tester.enterText(find.byType(TextField), 'たべた');
        await revealAndTap(find.text('Kiểm tra đáp án'));
        await revealAndTap(find.text('Xem tổng kết'));
        await reveal(find.text('Mẫu ngữ pháp trong phiên'));

        // Writing / Translation & Voice text-only preview flows
        for (final isVoice in [false, true]) {
          await pumpScoped(
            WritingPracticeScreen(
              key: ValueKey('writing-$isVoice'),
              voice: isVoice,
            ),
          );
          await revealAndTap(find.text('Xem gợi ý cấu trúc'));
          await reveal(find.byType(TextField), delta: -120);
          await tester.enterText(find.byType(TextField), '日本に行ったことがあります');
          await revealAndTap(find.text('。'));
          await revealAndTap(find.text('Xác nhận văn bản'));
          await revealAndTap(find.text('Đối chiếu câu tham khảo'));
          await reveal(find.text('3 tiêu chí mẫu'));
          await reveal(find.text('GỢI Ý CÂU THAM KHẢO'));
        }

        // Practice history & error notebook with sample diff card expanded
        await pumpScoped(
          const PracticeHistoryScreen(
            key: ValueKey('history-all'),
            errorsOnly: false,
          ),
        );
        await revealAndTap(find.text('Xem bố cục thẻ nhật ký (Minh họa)'));
        await reveal(find.text('Bản sửa chuẩn xác (ví dụ):'));
        await pumpScoped(
          const PracticeHistoryScreen(
            key: ValueKey('history-errors'),
            errorsOnly: true,
          ),
        );
        await revealAndTap(find.text('Xem bố cục thẻ Sổ lỗi (Minh họa)'));
        await reveal(find.text('Bản sửa chuẩn xác (ví dụ):'));

        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await closeLearning(learning);
      },
    );
  }
}
