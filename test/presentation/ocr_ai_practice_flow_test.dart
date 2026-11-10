import 'dart:async';

import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/bunly_theme.dart';
import 'package:bunly/app/config.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/analysis/domain/grammar_analysis.dart';
import 'package:bunly/features/analysis/presentation/sentence_result_screen.dart';
import 'package:bunly/features/analysis/presentation/sentence_review_screen.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/ocr/domain/ocr_draft.dart';
import 'package:bunly/features/practice/domain/practice_storage.dart';
import 'package:bunly/features/practice/presentation/practice_history_screen.dart';
import 'package:bunly/features/practice/presentation/practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_practice_storage.dart';
import 'app_shell_test.dart' show closeLearning;
import 'app_test.dart' show SessionAuth;
import 'personal_test.dart' show PersonalFake;

class _CuratedCatalog implements GrammarRepository {
  @override
  Future<GrammarCatalog> load() async => GrammarCatalog(const [
    GrammarPoint(
      id: 'g1',
      pattern: '〜たことがある',
      level: 'N4',
      category: 'experience',
      meaning: 'Đã từng làm gì đó',
      formula: 'V(た) + ことがある',
      usage: 'Kinh nghiệm trong quá khứ',
      examples: [GrammarExample('日本へ行ったことがある。', 'Tôi đã từng đi Nhật.')],
    ),
    GrammarPoint(
      id: 'g2',
      pattern: '〜たい',
      level: 'N5',
      category: 'desire',
      meaning: 'Muốn làm gì đó',
      formula: 'V(ます) + たい',
      usage: 'Mong muốn bản thân',
      examples: [GrammarExample('日本へ行きたいです。', 'Tôi muốn đi Nhật.')],
    ),
  ], origin: GrammarOrigin.source);
}

List<CuratedPracticeQuestion> _curatedBank() => [
  CuratedPracticeQuestion(
    id: 'q1',
    grammarId: 'g1',
    contentVersion: 1,
    type: PracticeBankType.mcq,
    prompt: '日本へ（　？　）ことがあります。',
    options: const ['行く', '行った', '行きます', '行かない'],
    correctOptionIndex: 1,
    explanationVi: 'Phải chia quá khứ thể た trước ことがある.',
  ),
  CuratedPracticeQuestion(
    id: 'q2',
    grammarId: 'g1',
    contentVersion: 1,
    type: PracticeBankType.cloze,
    prompt: '納豆を［　　　］ことがありません。',
    acceptedAnswers: const ['食べた', 'たべた'],
    explanationVi: 'Dạng phủ định vẫn dùng V(た) + ことがありません.',
  ),
  CuratedPracticeQuestion(
    id: 'q3',
    grammarId: 'g2',
    contentVersion: 1,
    type: PracticeBankType.mcq,
    prompt: '日本へ（　？　）たいです。',
    options: const ['行き', '行く', '行った', '行かない'],
    correctOptionIndex: 0,
    explanationVi: 'Bỏ ます rồi cộng たい.',
  ),
];

Future<void> _reveal(
  WidgetTester tester,
  Finder target, {
  required Finder scrollable,
  double delta = 150,
}) async {
  await tester.scrollUntilVisible(target, delta, scrollable: scrollable);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> _revealAndTap(
  WidgetTester tester,
  Finder target, {
  required Finder scrollable,
  double delta = 150,
}) async {
  await _reveal(tester, target, scrollable: scrollable, delta: delta);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'OCR empty warning, editable draft, timeout/processing retry with identical request_id, live AI highlight and save note',
    (tester) async {
      final auth = SessionAuth()..user = const AppUser('u1', 'u1@bunly.edu.vn');
      final learning = PersonalFake();
      final ocr = FakeOcrRepository(
        errorToThrow: const OcrException(
          OcrFailureKind.emptyText,
          'Không nhận diện được chữ tiếng Nhật trong ảnh.',
        ),
      );
      var callCount = 0;
      final analysisRepo = FakeGrammarAnalysisRepository(
        onAnalyze: (reqId, text) async {
          callCount++;
          if (callCount == 1) {
            throw AnalysisException(
              AnalysisFailureKind.processing,
              requestId: reqId,
              retryAfterMs: 500,
              retryable: true,
              message: 'Đang xử lý.',
            );
          }
          if (callCount == 2) {
            throw AnalysisException(
              AnalysisFailureKind.timeout,
              requestId: reqId,
              retryable: true,
              message: 'Hết thời gian chờ (30s). Hãy thử lại.',
            );
          }
          return GrammarAnalysisResult(
            requestId: reqId,
            text: text,
            matches: const [
              GrammarAnalysisMatch(
                grammarId: 'g1',
                span: AnalysisUtf16Span(
                  startUtf16: 3,
                  endUtf16: 11,
                  text: '行ったことがある',
                ),
              ),
            ],
            remainingQuota: 18,
            isLiveAi: true,
          );
        },
      );
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(() async {
        await auth.controller.close();
        await auth.recoveryController.close();
        await closeLearning(learning);
        await practiceStorage.dispose();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWithValue(
              const AppConfig(
                connected: true,
                supabaseUrl: 'https://example.supabase.co',
                supabaseAnonKey: 'anon-key',
              ),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(_CuratedCatalog()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
            ocrRepositoryProvider.overrideWithValue(ocr),
            grammarAnalysisRepositoryProvider.overrideWithValue(analysisRepo),
            learningSyncProvider.overrideWithValue(null),
            pendingSyncProvider.overrideWith((ref) => Stream.value(0)),
          ],
          child: MaterialApp(
            theme: bunlyTheme(Brightness.light),
            home: const SentenceReviewScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Quota banner loaded cleanly.
      expect(find.textContaining('còn 19/20 lượt'), findsOneWidget);

      final reviewScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('sentence-review')),
            matching: find.byType(Scrollable),
          )
          .first;

      // 1) Camera OCR fails with emptyText -> non-blocking warning, AI not invoked.
      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('ocr-camera-button')),
        scrollable: reviewScroll,
      );
      await _reveal(
        tester,
        find.text('Không nhận diện được chữ tiếng Nhật trong ảnh.'),
        scrollable: reviewScroll,
      );
      expect(
        find.text('Không nhận diện được chữ tiếng Nhật trong ảnh.'),
        findsOneWidget,
      );
      expect(analysisRepo.submittedRequests, isEmpty);

      // 2) Gallery OCR succeeds -> fills editable draft, still never auto-calls AI.
      ocr.errorToThrow = null;
      ocr.nextDraft = OcrDraft(draftId: 'ocr-1', text: '  日本へ行ったことがある。\r\n');
      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('ocr-gallery-button')),
        scrollable: reviewScroll,
        delta: -150,
      );
      await _reveal(
        tester,
        find.textContaining('Đã điền chữ từ OCR trên thiết bị'),
        scrollable: reviewScroll,
      );
      expect(
        find.textContaining('Đã điền chữ từ OCR trên thiết bị'),
        findsOneWidget,
      );
      await _reveal(
        tester,
        find.byKey(const ValueKey('sentence-input')),
        scrollable: reviewScroll,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('sentence-input')))
            .controller!
            .text,
        '日本へ行ったことがある。',
      );
      expect(analysisRepo.submittedRequests, isEmpty);

      // 3) Tap AI CTA -> auto-retries 202 processing once with SAME request_id, then surfaces timeout preserving draft.
      await tester.tap(find.byKey(const ValueKey('sentence-primary-cta')));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(analysisRepo.submittedRequests.length, 2);
      expect(
        analysisRepo.submittedRequests[0].requestId,
        analysisRepo.submittedRequests[1].requestId,
      );
      expect(
        find.text('Hết thời gian chờ (30s). Hãy thử lại.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('sentence-input')))
            .controller!
            .text,
        '日本へ行ったことがある。',
      );

      // 4) Manual retry WITHOUT editing reuses EXACT same request_id and opens SentenceResultScreen!
      await tester.tap(find.byKey(const ValueKey('sentence-primary-cta')));
      await tester.pumpAndSettle();

      expect(analysisRepo.submittedRequests.length, 3);
      expect(
        analysisRepo.submittedRequests[2].requestId,
        analysisRepo.submittedRequests[0].requestId,
      );
      expect(find.byType(SentenceResultScreen), findsOneWidget);
      expect(find.text('Phân tích AI · Còn 18 lượt'), findsOneWidget);

      final resultScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('sentence-result')),
            matching: find.byType(Scrollable),
          )
          .first;
      await _reveal(
        tester,
        find.text('Đoạn khớp trong câu: 「行ったことがある」'),
        scrollable: resultScroll,
        delta: 180,
      );
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      expect(find.text('Đoạn khớp trong câu: 「行ったことがある」'), findsOneWidget);

      // 5) Bookmark pattern & save note from SentenceResultScreen.
      await _revealAndTap(
        tester,
        find.text('Lưu mẫu'),
        scrollable: resultScroll,
        delta: 180,
      );
      expect(learning.summary.saved, contains('g1'));

      await _revealAndTap(
        tester,
        find.text('Lưu câu làm ghi chú'),
        scrollable: resultScroll,
        delta: 180,
      );
      expect(learning.notes.single.grammarId, 'g1');
      expect(learning.notes.single.content, '日本へ行ったことがある。');

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'curated practice, SRS due card on TodayScreen, real accuracy & weak mistake in Progress and PracticeHistoryScreen',
    (tester) async {
      final auth = SessionAuth()..user = const AppUser('u1', 'u1@bunly.edu.vn');
      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository(
        initialQuestions: _curatedBank(),
        initialReviewStates: [
          ReviewStateEntry(
            grammarId: 'g1',
            stage: 0,
            dueAt: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
            isTentative: true,
            updatedAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
          ),
        ],
        isTentative: true,
      );
      addTearDown(() async {
        await auth.controller.close();
        await auth.recoveryController.close();
        await closeLearning(learning);
        await practiceStorage.dispose();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(_CuratedCatalog()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // TodayScreen highlights SRS due queue separately from self-assessment status.
      expect(find.text('1 mẫu đến hạn ôn (SRS)'), findsOneWidget);
      final todayScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('today')),
            matching: find.byType(Scrollable),
          )
          .first;
      await _revealAndTap(
        tester,
        find.text('Ôn ngay (2 câu)'),
        scrollable: todayScroll,
      );
      expect(find.byType(CuratedPracticeSessionScreen), findsOneWidget);

      Finder sessionScroll() => find
          .descendant(
            of: find.byType(CuratedPracticeSessionScreen),
            matching: find.byType(Scrollable),
          )
          .first;

      // Q1: Submit wrong independent answer -> triggers feedback + retry button.
      await _revealAndTap(tester, find.text('行く'), scrollable: sessionScroll());
      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('curated-submit-btn')),
        scrollable: sessionScroll(),
      );
      await _reveal(
        tester,
        find.text('Chưa chính xác'),
        scrollable: sessionScroll(),
      );
      expect(find.text('Chưa chính xác'), findsOneWidget);
      expect(practiceStorage.attempts.length, 1);
      expect(practiceStorage.attempts.single.isFirstIndependent, isTrue);
      expect(practiceStorage.attempts.single.isCorrect, isFalse);

      // Retry Q1 correctly -> recorded as non-independent retry, does NOT overwrite initial wrong.
      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('curated-retry-btn')),
        scrollable: sessionScroll(),
      );
      await _revealAndTap(
        tester,
        find.text('行った'),
        scrollable: sessionScroll(),
        delta: -150,
      );
      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('curated-submit-btn')),
        scrollable: sessionScroll(),
      );
      await _reveal(
        tester,
        find.textContaining('Đã ghi nhận 1 lần thử lại để luyện thêm'),
        scrollable: sessionScroll(),
      );
      expect(find.text('Chính xác'), findsOneWidget);
      expect(
        find.textContaining('Đã ghi nhận 1 lần thử lại để luyện thêm'),
        findsOneWidget,
      );
      expect(practiceStorage.attempts.length, 2);
      expect(practiceStorage.attempts[1].isFirstIndependent, isFalse);
      expect(practiceStorage.attempts[1].isCorrect, isTrue);

      // Advance to Q2 and tap Skip -> recorded as skipped (not counted in independent accuracy/SRS).
      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('curated-next-btn')),
        scrollable: sessionScroll(),
      );
      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('curated-skip-btn')),
        scrollable: sessionScroll(),
      );
      await _reveal(
        tester,
        find.text('Đã bỏ qua (không tính SRS)'),
        scrollable: sessionScroll(),
      );
      expect(find.text('Đã bỏ qua (không tính SRS)'), findsOneWidget);

      // Summary screen verifies exact breakdown: 0/1 independent correct, 1 skipped, 1 retry.
      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('curated-next-btn')),
        scrollable: sessionScroll(),
      );
      expect(find.text('Đúng 0/1 câu lần đầu'), findsOneWidget);
      expect(find.text('Bỏ qua 1 câu · Thử lại thêm 1 lần'), findsOneWidget);

      // Return to Today -> open Progress tab -> verify real 0% and weak mistake g1, then open Error Notebook.
      await _revealAndTap(
        tester,
        find.text('Về chọn phiên'),
        scrollable: sessionScroll(),
      );
      await tester.tap(find.text('Tiến độ'));
      await tester.pumpAndSettle();

      final progressScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('progress')),
            matching: find.byType(Scrollable),
          )
          .first;
      await _reveal(
        tester,
        find.text('0%'),
        scrollable: progressScroll,
        delta: 200,
      );
      expect(find.text('0%'), findsOneWidget);
      await _revealAndTap(
        tester,
        find.text('Mở sổ lỗi cần ôn (1)'),
        scrollable: progressScroll,
        delta: 200,
      );

      expect(find.byType(PracticeHistoryScreen), findsOneWidget);
      expect(find.text('1 lỗi cần ôn'), findsOneWidget);
      final errorScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('practice-errors')),
            matching: find.byType(Scrollable),
          )
          .first;
      await _reveal(
        tester,
        find.text('Đáp án chuẩn: 行った'),
        scrollable: errorScroll,
      );
      expect(find.text('Câu trả lời của bạn: 行く'), findsOneWidget);
      expect(find.text('Đáp án chuẩn: 行った'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'M3-01 & M3-03: OCR confidence indicator, post-processed badge, sentence chip selection, and 100% offline OnDeviceGrammarDetector span highlight on unseen sentence',
    (tester) async {
      final auth = SessionAuth()..user = const AppUser('u1', 'u1@bunly.edu.vn');
      final learning = PersonalFake();
      final ocr = FakeOcrRepository(
        nextDraft: OcrDraft(
          draftId: 'ocr-m3',
          text: '北海道 で スキー を した こと が あります 。\nまだ 東京 へ 行きたい です 。',
          rawText: '北海道 で スキー を した こと が あります 。\nまだ 東京 へ 行きたい です 。',
          averageConfidence: 0.78,
          minConfidence: 0.62,
          latencyMs: 18,
          lines: const [
            OcrLine(text: '北海道でスキーをしたことがあります。', confidence: 0.94),
            OcrLine(text: 'まだ東京へ行きたいです。', confidence: 0.62),
          ],
        ),
      );
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(() async {
        await auth.controller.close();
        await auth.recoveryController.close();
        await closeLearning(learning);
        await practiceStorage.dispose();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWithValue(const AppConfig(connected: false)),
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(_CuratedCatalog()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
            ocrRepositoryProvider.overrideWithValue(ocr),
          ],
          child: MaterialApp(
            theme: bunlyTheme(Brightness.light),
            home: const SentenceReviewScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final reviewScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('sentence-review')),
            matching: find.byType(Scrollable),
          )
          .first;

      await _revealAndTap(
        tester,
        find.byKey(const ValueKey('ocr-gallery-button')),
        scrollable: reviewScroll,
      );

      // Post-processing cleaned intra-CJK spaces and displayed OCR confidence + low-confidence warning.
      expect(
        find.byKey(const ValueKey('ocr-confidence-badge')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ocr-postprocessed-badge')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ocr-low-confidence-warning')),
        findsOneWidget,
      );

      // Tap the first candidate sentence chip to focus on the unseen sentence.
      await _revealAndTap(
        tester,
        find.widgetWithText(ActionChip, '北海道でスキーをしたことがあります。'),
        scrollable: reviewScroll,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('sentence-input')))
            .controller!
            .text,
        '北海道でスキーをしたことがあります。',
      );

      // Confirm in 100% offline mode -> OnDeviceGrammarDetector matches N4 〜たことがある with span & confidence!
      await tester.tap(find.byKey(const ValueKey('sentence-primary-cta')));
      await tester.pumpAndSettle();

      expect(find.byType(SentenceResultScreen), findsOneWidget);
      expect(find.text('OCR + Nhận diện trên máy'), findsOneWidget);

      final resultScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('sentence-result')),
            matching: find.byType(Scrollable),
          )
          .first;
      await _reveal(
        tester,
        find.text('N4 · 〜たことがある'),
        scrollable: resultScroll,
        delta: 180,
      );
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ondevice-confidence-g1')),
        findsOneWidget,
      );
      expect(find.textContaining('したことがあります'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'scanJapaneseTextProvider stays alive across external picker pause',
    () async {
      final delayedOcr = _DelayedDisposeCheckingOcrRepository();
      final container = ProviderContainer(
        overrides: [
          ocrRepositoryProvider.overrideWith((ref) {
            ref.onDispose(() => unawaited(delayedOcr.dispose()));
            return delayedOcr;
          }),
        ],
      );
      addTearDown(container.dispose);

      final draft = await container.read(scanJapaneseTextProvider)(
        OcrSource.gallery,
      );
      expect(draft?.text, '本を読んでいます。');
      expect(delayedOcr.wasDisposed, isFalse);

      container.dispose();
      expect(delayedOcr.wasDisposed, isTrue);
    },
  );
}

class _DelayedDisposeCheckingOcrRepository implements OcrRepository {
  bool wasDisposed = false;

  @override
  Future<OcrDraft?> scan(OcrSource source) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (wasDisposed) return null;
    return OcrDraft(draftId: 'delayed-1', text: '本を読んでいます。');
  }

  @override
  Future<OcrDraft?> scanFilePath(String path) async => null;

  @override
  Future<void> dispose() async {
    wasDisposed = true;
  }
}
