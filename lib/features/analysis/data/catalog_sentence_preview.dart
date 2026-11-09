import '../../grammar/domain/grammar_repository.dart';
import '../domain/sentence_preview.dart';

/// Local UI preview only: exact example lookup, without a model or OCR.
class CatalogSentencePreview implements SentencePreviewRepository {
  const CatalogSentencePreview(this.catalog);
  final GrammarRepository catalog;

  @override
  Future<SentencePreview> preview(String confirmedText) async {
    final data = await catalog.load();
    return SentencePreview(
      text: confirmedText,
      matches: List.unmodifiable(
        data.points.where(
          (point) => point.examples.any(
            (example) => example.japanese.trim() == confirmedText,
          ),
        ),
      ),
    );
  }
}
