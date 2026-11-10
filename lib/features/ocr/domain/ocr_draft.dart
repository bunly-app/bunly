import 'japanese_ocr_post_processor.dart';

export 'japanese_ocr_post_processor.dart';

enum OcrSource { camera, gallery }

enum OcrFailureKind {
  permissionDenied,
  cameraUnavailable,
  imageUnreadable,
  modelUnavailable,
  emptyText,
  recognizerFailed,
}

enum OcrConfidenceTier { high, medium, low, unknown }

OcrConfidenceTier classifyOcrConfidence(double? confidence) {
  if (confidence == null) return OcrConfidenceTier.unknown;
  if (confidence >= 0.85) return OcrConfidenceTier.high;
  if (confidence >= 0.65) return OcrConfidenceTier.medium;
  return OcrConfidenceTier.low;
}

String ocrConfidenceLabel(OcrConfidenceTier tier) => switch (tier) {
  OcrConfidenceTier.high => 'Rõ',
  OcrConfidenceTier.medium => 'Cần kiểm tra',
  OcrConfidenceTier.low => 'Thấp — nên sửa tay',
  OcrConfidenceTier.unknown => 'Chưa có điểm tự tin',
};

class OcrException implements Exception {
  const OcrException(this.kind, [this.message]);

  final OcrFailureKind kind;
  final String? message;

  @override
  String toString() =>
      'OcrException($kind${message == null ? '' : ': $message'})';
}

class OcrLine {
  const OcrLine({required this.text, String? rawText, this.confidence})
    : rawText = rawText ?? text;

  final String text;
  final String rawText;
  final double? confidence;

  OcrConfidenceTier get confidenceTier => classifyOcrConfidence(confidence);
}

class OcrBlock {
  OcrBlock({
    required this.text,
    List<OcrLine> lines = const [],
    this.confidence,
  }) : lines = List.unmodifiable(lines);

  final String text;
  final List<OcrLine> lines;
  final double? confidence;
}

class OcrDraft {
  OcrDraft({
    required this.draftId,
    required this.text,
    String? rawText,
    List<OcrBlock> blocks = const [],
    List<OcrLine> lines = const [],
    List<String>? candidateSentences,
    this.averageConfidence,
    this.minConfidence,
    this.latencyMs,
    bool? wasPostProcessed,
    this.engine = 'mlkit_text_recognition_v2',
    this.script = 'Japanese',
  }) : rawText = rawText ?? text,
       blocks = List.unmodifiable(blocks),
       lines = List.unmodifiable(lines),
       candidateSentences = List.unmodifiable(
         candidateSentences ?? JapaneseOcrPostProcessor.splitSentences(text),
       ),
       wasPostProcessed =
           wasPostProcessed ??
           JapaneseOcrPostProcessor.wasModifiedByPostProcessing(
             rawText ?? text,
             text,
           );

  final String draftId;
  final String text;
  final String rawText;
  final List<OcrBlock> blocks;
  final List<OcrLine> lines;
  final List<String> candidateSentences;
  final double? averageConfidence;
  final double? minConfidence;
  final int? latencyMs;
  final bool wasPostProcessed;
  final String engine;
  final String script;

  OcrConfidenceTier get confidenceTier =>
      classifyOcrConfidence(minConfidence ?? averageConfidence);

  List<OcrLine> get lowConfidenceLines => lines
      .where((line) => line.confidence != null && line.confidence! < 0.80)
      .toList(growable: false);
}

/// Normalizes Japanese OCR text via [JapaneseOcrPostProcessor] (removes
/// intra-CJK spaces, merges broken mid-sentence line wraps, and normalizes
/// punctuation while preserving intentional paragraph breaks).
String normalizeOcrText(String raw) => JapaneseOcrPostProcessor.normalize(raw);

abstract interface class OcrRepository {
  Future<OcrDraft?> scan(OcrSource source);
  Future<OcrDraft?> scanFilePath(String path);
  Future<void> dispose();
}

class ScanJapaneseText {
  const ScanJapaneseText(this.repository);

  final OcrRepository repository;

  Future<OcrDraft?> call(OcrSource source) async {
    final draft = await repository.scan(source);
    if (draft == null) return null;
    return _finalizeDraft(draft);
  }

  Future<OcrDraft?> fromPath(String path) async {
    if (path.trim().isEmpty) {
      throw const OcrException(
        OcrFailureKind.imageUnreadable,
        'Đường dẫn ảnh không hợp lệ.',
      );
    }
    final draft = await repository.scanFilePath(path);
    if (draft == null) return null;
    return _finalizeDraft(draft);
  }

  OcrDraft _finalizeDraft(OcrDraft draft) {
    final clean = normalizeOcrText(draft.text);
    if (clean.isEmpty) {
      throw const OcrException(
        OcrFailureKind.emptyText,
        'Không nhận diện được chữ tiếng Nhật trong ảnh.',
      );
    }
    final candidateSentences = JapaneseOcrPostProcessor.splitSentences(clean);
    final wasModified = JapaneseOcrPostProcessor.wasModifiedByPostProcessing(
      draft.rawText,
      clean,
    );
    if (clean == draft.text &&
        draft.candidateSentences.length == candidateSentences.length &&
        draft.wasPostProcessed == wasModified) {
      return draft;
    }
    return OcrDraft(
      draftId: draft.draftId,
      text: clean,
      rawText: draft.rawText,
      blocks: draft.blocks,
      lines: draft.lines,
      candidateSentences: candidateSentences,
      averageConfidence: draft.averageConfidence,
      minConfidence: draft.minConfidence,
      latencyMs: draft.latencyMs,
      wasPostProcessed: wasModified,
      engine: draft.engine,
      script: draft.script,
    );
  }
}
