import '../../grammar/domain/grammar_repository.dart';
import '../domain/sentence_preview.dart';

/// Exact example lookup without morphological rule inference.
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

/// On-device grammar preview combining exact example lookup with
/// [OnDeviceGrammarDetector] morphological surface rules (M3-FR-03).
class OnDeviceSentencePreview implements SentencePreviewRepository {
  const OnDeviceSentencePreview(
    this.catalog, {
    this.detector = const OnDeviceGrammarDetector(),
  });

  final GrammarRepository catalog;
  final OnDeviceGrammarDetector detector;

  @override
  Future<SentencePreview> preview(String confirmedText) async {
    final data = await catalog.load();
    final detected = detector.detect(confirmedText, data.points);
    return SentencePreview(
      text: confirmedText,
      matches: detected.points,
      onDeviceMatches: detected.matches,
      latencyMs: detected.latencyMs,
    );
  }
}
