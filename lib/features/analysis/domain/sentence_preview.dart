import '../../grammar/domain/grammar_point.dart';
import 'on_device_grammar_detector.dart';

export 'on_device_grammar_detector.dart';

class SentencePreview {
  const SentencePreview({
    required this.text,
    required this.matches,
    this.onDeviceMatches = const [],
    this.latencyMs,
  });

  final String text;
  final List<GrammarPoint> matches;
  final List<OnDeviceGrammarMatch> onDeviceMatches;
  final int? latencyMs;
}

abstract interface class SentencePreviewRepository {
  Future<SentencePreview> preview(String confirmedText);
}

class PreviewSentence {
  const PreviewSentence(this.repository);
  final SentencePreviewRepository repository;

  Future<SentencePreview> call(String draft) {
    final text = draft.replaceAll('\r\n', '\n').trim();
    if (text.isEmpty || text.runes.length > 2000) {
      throw const FormatException('Nhập câu từ 1 đến 2000 ký tự.');
    }
    return repository.preview(text);
  }
}
