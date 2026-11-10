import 'dart:convert';
import 'dart:io';

import 'package:bunly/features/analysis/data/catalog_sentence_preview.dart';
import 'package:bunly/features/analysis/domain/grammar_analysis.dart';
import 'package:bunly/features/analysis/domain/sentence_preview.dart';
import 'package:bunly/features/grammar/data/grammar_mapper.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/ocr/domain/ocr_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_practice_storage.dart';

class _FullAssetGrammarCatalog implements GrammarRepository {
  _FullAssetGrammarCatalog() {
    final raw = File('assets/data/grammar.json').readAsStringSync();
    final rows = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    points = rows.map(grammarFromJson).toList(growable: false);
  }

  late final List<GrammarPoint> points;

  @override
  Future<GrammarCatalog> load() async =>
      GrammarCatalog(points, origin: GrammarOrigin.source);
}

void main() {
  group('M3-01: JapaneseOcrPostProcessor & OcrConfidenceTier', () {
    test(
      'removes intra-CJK spaces while preserving spaces between Latin words',
      () {
        const raw = '  日 本 語 を 勉 強 し た い で す 。\r\nJLPT N4 Grammar  ';
        final normalized = JapaneseOcrPostProcessor.normalize(raw);
        expect(normalized, '日本語を勉強したいです。\nJLPT N4 Grammar');
        expect(
          JapaneseOcrPostProcessor.wasModifiedByPostProcessing(raw, normalized),
          isTrue,
        );
      },
    );

    test(
      'merges broken mid-sentence line wraps while preserving paragraph breaks and sentence-final lines',
      () {
        const brokenWrap = '今日は雨が降って\nいます。';
        expect(JapaneseOcrPostProcessor.normalize(brokenWrap), '今日は雨が降っています。');

        const paragraphBreak = '日本へ行った。\r\n\r\n楽しかった。';
        expect(
          JapaneseOcrPostProcessor.normalize(paragraphBreak),
          '日本へ行った。\n\n楽しかった。',
        );
      },
    );

    test(
      'normalizes half-width katakana punctuation, full-width digits and trailing ASCII period',
      () {
        const raw = '｢日本語｣を３時間勉強しました.';
        expect(JapaneseOcrPostProcessor.normalize(raw), '「日本語」を3時間勉強しました。');
      },
    );

    test('splits multi-sentence OCR text into candidate sentences', () {
      const text = '日本へ行ったことがあります。とても楽しかったです！また行きたいですか？';
      final sentences = JapaneseOcrPostProcessor.splitSentences(text);
      expect(sentences, ['日本へ行ったことがあります。', 'とても楽しかったです！', 'また行きたいですか？']);
    });

    test(
      'classifies OCR confidence tiers and filters low-confidence lines',
      () {
        expect(classifyOcrConfidence(0.92), OcrConfidenceTier.high);
        expect(classifyOcrConfidence(0.75), OcrConfidenceTier.medium);
        expect(classifyOcrConfidence(0.50), OcrConfidenceTier.low);
        expect(classifyOcrConfidence(null), OcrConfidenceTier.unknown);

        final draft = OcrDraft(
          draftId: 'd-conf',
          text: '日本語を勉強したいです。\n少し難しい漢字があります。',
          rawText: '日 本 語 を 勉 強 し た い で す 。\n少 し 難 し い 漢 字 が あ り ま す 。',
          averageConfidence: 0.78,
          minConfidence: 0.62,
          latencyMs: 19,
          lines: const [
            OcrLine(text: '日本語を勉強したいです。', confidence: 0.94),
            OcrLine(text: '少し難しい漢字があります。', confidence: 0.62),
          ],
        );

        expect(draft.confidenceTier, OcrConfidenceTier.low);
        expect(draft.wasPostProcessed, isTrue);
        expect(draft.lowConfidenceLines.length, 1);
        expect(draft.lowConfidenceLines.single.text, '少し難しい漢字があります。');
        expect(draft.candidateSentences.length, 2);
      },
    );
  });

  group('M3-03: OnDeviceGrammarDetector (100% Offline AI)', () {
    late _FullAssetGrammarCatalog catalog;
    const detector = OnDeviceGrammarDetector();

    setUpAll(() {
      catalog = _FullAssetGrammarCatalog();
    });

    test(
      'detects N5/N4 grammar patterns on unseen real-world sentences offline with valid UTF-16 spans in < 30 ms',
      () async {
        final unseenCases =
            <
              ({
                String sentence,
                String expectedPattern,
                String expectedSpanSubstring,
              })
            >[
              (
                sentence: '北海道でスキーをしたことがあります。',
                expectedPattern: '〜たことがある',
                expectedSpanSubstring: 'したことがあります',
              ),
              (
                sentence: 'ここで写真を撮らないでください。',
                expectedPattern: '〜ないでください',
                expectedSpanSubstring: '撮らないでください',
              ),
              (
                sentence: '明日は早く起きなければなりません。',
                expectedPattern: '〜なければならない',
                expectedSpanSubstring: '起きなければなりません',
              ),
              (
                sentence: 'コーヒーを飲みながら新聞を読みます。',
                expectedPattern: '〜ながら',
                expectedSpanSubstring: '飲みながら',
              ),
              (
                sentence: '雨が降ったら、家で映画を見ます。',
                expectedPattern: '〜たら',
                expectedSpanSubstring: '降ったら',
              ),
              (
                sentence: 'この辞書はとても使いやすいです。',
                expectedPattern: '〜やすい・〜にくい',
                expectedSpanSubstring: '使いやすいです',
              ),
              (
                sentence: '午後から雨が降るかもしれません。',
                expectedPattern: '〜かもしれない',
                expectedSpanSubstring: '降るかもしれません',
              ),
              (
                sentence: '寝るまえに本を読みます。',
                expectedPattern: '〜まえに',
                expectedSpanSubstring: '寝るまえに',
              ),
            ];

        for (final testCase in unseenCases) {
          final result = detector.detect(testCase.sentence, catalog.points);
          expect(
            result.latencyMs,
            lessThan(30),
            reason: 'On-device inference must complete in < 30 ms',
          );
          expect(
            result.matches.map((m) => m.point.pattern),
            contains(testCase.expectedPattern),
            reason:
                'Sentence "${testCase.sentence}" should match ${testCase.expectedPattern}',
          );
          final matched = result.matches.firstWhere(
            (m) => m.point.pattern == testCase.expectedPattern,
          );
          expect(matched.span, isNotNull);
          expect(matched.span!.text, contains(testCase.expectedSpanSubstring));
          expect(
            testCase.sentence.substring(
              matched.span!.startUtf16,
              matched.span!.endUtf16,
            ),
            matched.span!.text,
          );
        }
      },
    );

    test(
      'handles emoji surrogate pairs accurately without corrupting UTF-16 span offsets',
      () {
        const sentence = '🍣を食べたことがあります。';
        final result = detector.detect(sentence, catalog.points);
        expect(result.matches, isNotEmpty);
        final match = result.matches.first;
        expect(match.point.pattern, '〜たことがある');
        expect(match.span, isNotNull);
        expect(
          sentence.substring(match.span!.startUtf16, match.span!.endUtf16),
          match.span!.text,
        );
      },
    );

    test(
      'OnDeviceSentencePreview works through PreviewSentence use case on novel sentences',
      () async {
        final previewUseCase = PreviewSentence(
          OnDeviceSentencePreview(catalog),
        );
        final preview = await previewUseCase('  来年、日本へ留学するつもりです。\r\n');
        expect(preview.text, '来年、日本へ留学するつもりです。');
        expect(preview.matches.map((p) => p.pattern), contains('〜つもりだ'));
        expect(preview.onDeviceMatches, isNotEmpty);
        expect(
          preview.onDeviceMatches.first.confidencePercent,
          greaterThan(85),
        );
      },
    );

    test(
      'AnalyzeGrammarSentence (M3-04) pre-filters candidates on device and fuses UTF-16 spans into Cloud AI matches',
      () async {
        const validId = '11111111-1111-4111-8111-111111111111';
        final targetPoint = catalog.points.firstWhere(
          (p) => p.pattern == '〜たことがある',
        );
        final repo = FakeGrammarAnalysisRepository(
          onAnalyze: (reqId, text) async => GrammarAnalysisResult(
            requestId: reqId,
            text: text,
            // Simulate Gemini Flash-Lite returning grammar_id without span:
            matches: [GrammarAnalysisMatch(grammarId: targetPoint.id)],
            remainingQuota: 19,
            isLiveAi: true,
          ),
        );
        final useCase = AnalyzeGrammarSentence(repo, catalog);
        final result = await useCase(
          requestId: validId,
          draftText: '北海道でスキーをしたことがあります。',
        );

        expect(repo.submittedCandidateIds.single, contains(targetPoint.id));
        expect(result.isHybridEdgeCloud, isTrue);
        expect(result.onDeviceCandidatesCount, greaterThanOrEqualTo(1));
        expect(result.matches.single.point?.pattern, '〜たことがある');
        // Span was fused from Stage 1 OnDeviceGrammarDetector!
        expect(result.matches.single.span, isNotNull);
        expect(result.matches.single.span!.text, contains('したことがあります'));
      },
    );
  });
}
