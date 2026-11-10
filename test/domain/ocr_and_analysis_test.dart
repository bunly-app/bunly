import 'package:bunly/features/analysis/domain/grammar_analysis.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/ocr/domain/ocr_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_practice_storage.dart';

class _ApprovedGrammarCatalog implements GrammarRepository {
  @override
  Future<GrammarCatalog> load() async => GrammarCatalog(const [
    GrammarPoint(
      id: '10000000-0000-0000-0000-000000000001',
      pattern: '〜たことがある',
      level: 'N4',
      category: 'experience',
      meaning: 'Đã từng làm gì đó',
      formula: 'V(た) + ことがある',
      usage: 'Diễn tả kinh nghiệm trong quá khứ',
      examples: [],
    ),
  ], origin: GrammarOrigin.source);
}

void main() {
  group('ScanJapaneseText', () {
    test('returns null cleanly when user cancels image picker', () async {
      final repo = FakeOcrRepository(nextDraft: null);
      final useCase = ScanJapaneseText(repo);

      final result = await useCase(OcrSource.camera);
      expect(result, isNull);
      expect(repo.sourceCalls, [OcrSource.camera]);
    });

    test(
      'normalizes CRLF and outer spaces without dropping internal newlines',
      () async {
        final repo = FakeOcrRepository(
          nextDraft: OcrDraft(draftId: 'd1', text: '  日本へ行った。\r\n\r\n楽しかった。  '),
        );
        final useCase = ScanJapaneseText(repo);

        final result = await useCase(OcrSource.gallery);
        expect(result, isNotNull);
        expect(result!.text, '日本へ行った。\n\n楽しかった。');
      },
    );

    test(
      'throws OcrException.emptyText when OCR extracts only whitespace',
      () async {
        final repo = FakeOcrRepository(
          nextDraft: OcrDraft(draftId: 'd2', text: '  \r\n\t  '),
        );
        final useCase = ScanJapaneseText(repo);

        await expectLater(
          useCase(OcrSource.camera),
          throwsA(
            isA<OcrException>().having(
              (e) => e.kind,
              'kind',
              OcrFailureKind.emptyText,
            ),
          ),
        );
      },
    );

    test('fromPath rejects blank path before invoking recognizer', () async {
      final repo = FakeOcrRepository();
      final useCase = ScanJapaneseText(repo);

      await expectLater(
        useCase.fromPath('   '),
        throwsA(
          isA<OcrException>().having(
            (e) => e.kind,
            'kind',
            OcrFailureKind.imageUnreadable,
          ),
        ),
      );
      expect(repo.pathCalls, isEmpty);
    });
  });

  group('UTF-16 span validation & AnalyzeGrammarSentence', () {
    test(
      'validateSpanOnText handles surrogate pairs and rejects torn boundaries',
      () {
        const text = '🍣を食べたことがある。';
        // 🍣 occupies UTF-16 indices [0, 2), を is at [2, 3), 食べたことがある is at [3, 11).
        final valid = validateSpanOnText(
          text,
          startUtf16: 3,
          endUtf16: 11,
          spanText: '食べたことがある',
        );
        expect(valid, isNotNull);
        expect(valid!.text, '食べたことがある');

        // Torn surrogate pair starting inside 🍣 at offset 1 must fail.
        expect(
          validateSpanOnText(
            text,
            startUtf16: 1,
            endUtf16: 3,
            spanText: text.substring(1, 3),
          ),
          isNull,
        );

        // Text mismatch must fail.
        expect(
          validateSpanOnText(
            text,
            startUtf16: 3,
            endUtf16: 11,
            spanText: '行ったことがある',
          ),
          isNull,
        );
      },
    );

    test(
      'rejects invalid UUID, unpaired surrogates, empty and overlong input offline',
      () async {
        final repo = FakeGrammarAnalysisRepository();
        final useCase = AnalyzeGrammarSentence(repo, _ApprovedGrammarCatalog());
        const validId = '11111111-1111-4111-8111-111111111111';

        await expectLater(
          useCase(requestId: 'not-a-uuid', draftText: '日本へ行く。'),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.kind,
              'kind',
              AnalysisFailureKind.invalidInput,
            ),
          ),
        );

        await expectLater(
          useCase(requestId: validId, draftText: 'bad\uD800pair'),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.kind,
              'kind',
              AnalysisFailureKind.invalidInput,
            ),
          ),
        );

        await expectLater(
          useCase(requestId: validId, draftText: '  \r\n '),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.kind,
              'kind',
              AnalysisFailureKind.invalidInput,
            ),
          ),
        );

        await expectLater(
          useCase(requestId: validId, draftText: 'あ' * 1001),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.kind,
              'kind',
              AnalysisFailureKind.invalidInput,
            ),
          ),
        );

        expect(repo.submittedRequests, isEmpty);
      },
    );

    test(
      'rejects unapproved grammar IDs or invalid server spans as invalidOutput',
      () async {
        const validId = '11111111-1111-4111-8111-111111111111';
        final unapprovedRepo = FakeGrammarAnalysisRepository(
          onAnalyze: (reqId, text) async => GrammarAnalysisResult(
            requestId: reqId,
            text: text,
            matches: const [
              GrammarAnalysisMatch(
                grammarId: '99999999-9999-9999-9999-999999999999',
              ),
            ],
            remainingQuota: 18,
            isLiveAi: true,
          ),
        );
        final useCase1 = AnalyzeGrammarSentence(
          unapprovedRepo,
          _ApprovedGrammarCatalog(),
        );

        await expectLater(
          useCase1(requestId: validId, draftText: '日本へ行ったことがある。'),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.kind,
              'kind',
              AnalysisFailureKind.invalidOutput,
            ),
          ),
        );

        final badSpanRepo = FakeGrammarAnalysisRepository(
          onAnalyze: (reqId, text) async => GrammarAnalysisResult(
            requestId: reqId,
            text: text,
            matches: const [
              GrammarAnalysisMatch(
                grammarId: '10000000-0000-0000-0000-000000000001',
                span: AnalysisUtf16Span(
                  startUtf16: 0,
                  endUtf16: 3,
                  text: '別の文字',
                ),
              ),
            ],
            remainingQuota: 18,
            isLiveAi: true,
          ),
        );
        final useCase2 = AnalyzeGrammarSentence(
          badSpanRepo,
          _ApprovedGrammarCatalog(),
        );

        await expectLater(
          useCase2(requestId: validId, draftText: '日本へ行ったことがある。'),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.kind,
              'kind',
              AnalysisFailureKind.invalidOutput,
            ),
          ),
        );
      },
    );

    test(
      'hydrates approved grammar point with surrogate-pair UTF-16 span',
      () async {
        const validId = '11111111-1111-4111-8111-111111111111';
        final repo = FakeGrammarAnalysisRepository(
          onAnalyze: (reqId, text) async => GrammarAnalysisResult(
            requestId: reqId,
            text: text,
            matches: const [
              GrammarAnalysisMatch(
                grammarId: '10000000-0000-0000-0000-000000000001',
                span: AnalysisUtf16Span(
                  startUtf16: 3,
                  endUtf16: 11,
                  text: '食べたことがある',
                ),
              ),
            ],
            remainingQuota: 18,
            isLiveAi: true,
          ),
        );
        final useCase = AnalyzeGrammarSentence(repo, _ApprovedGrammarCatalog());

        final result = await useCase(
          requestId: validId.toUpperCase(),
          draftText: '  🍣を食べたことがある。 \r\n',
        );

        expect(repo.submittedRequests.single.requestId, validId);
        expect(repo.submittedRequests.single.text, '🍣を食べたことがある。');
        expect(result.matches.single.point?.pattern, '〜たことがある');
        expect(result.matches.single.span?.text, '食べたことがある');
        expect(result.remainingQuota, 18);
      },
    );

    test(
      'AnalysisRequestSession preserves requestId on retry and rotates on text change',
      () {
        var counter = 0;
        String nextUuid() {
          counter++;
          return '11111111-1111-4111-8111-00000000000$counter';
        }

        final session = AnalysisRequestSession();
        final id1 = session.resolveIdForText('  日本へ行った。\r\n', nextUuid);
        final retrySameNormalized = session.resolveIdForText(
          '日本へ行った。',
          nextUuid,
        );
        expect(retrySameNormalized, id1);

        final editedId = session.resolveIdForText('日本へ行ったことがある。', nextUuid);
        expect(editedId, isNot(id1));

        final forcedId = session.forceNewIdForText('日本へ行ったことがある。', nextUuid);
        expect(forcedId, isNot(editedId));

        session.reset();
        final afterResetId = session.resolveIdForText('日本へ行ったことがある。', nextUuid);
        expect(afterResetId, isNot(forcedId));
      },
    );
  });
}
