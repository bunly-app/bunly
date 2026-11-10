import 'package:flutter_test/flutter_test.dart';
import 'package:bunly/features/analysis/domain/sentence_preview.dart';
import 'package:bunly/features/analysis/data/catalog_sentence_preview.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';

class PreviewCatalog implements GrammarRepository {
  int calls = 0;
  @override
  Future<GrammarCatalog> load() async {
    calls++;
    return GrammarCatalog(const [
      GrammarPoint(
        id: 'g',
        pattern: '〜たい',
        level: 'N5',
        category: 'desire',
        meaning: 'Muốn',
        formula: 'V + たい',
        usage: 'Mong muốn',
        examples: [GrammarExample('日本へ行きたいです。', 'Tôi muốn đi Nhật.')],
      ),
    ], origin: GrammarOrigin.source);
  }
}

void main() {
  test(
    'invalid confirmation never loads catalog; normalized exact example only',
    () async {
      final catalog = PreviewCatalog();
      final preview = PreviewSentence(CatalogSentencePreview(catalog));
      expect(() => preview('  '), throwsFormatException);
      expect(
        () => preview(List.filled(2001, 'あ').join()),
        throwsFormatException,
      );
      expect(catalog.calls, 0);
      final result = await preview('  日本へ行きたいです。\r\n');
      expect(result.text, '日本へ行きたいです。');
      expect(result.matches.single.id, 'g');
      expect((await preview('日本へ行きたい')).matches, isEmpty);
      expect((await preview('知らない文です。')).matches, isEmpty);
    },
  );
}
