import '../../grammar/domain/grammar_point.dart';

class SentencePreview {
  const SentencePreview({required this.text, required this.matches});
  final String text;
  final List<GrammarPoint> matches;
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
