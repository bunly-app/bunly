enum OcrSource { camera, gallery }

enum OcrFailureKind {
  permissionDenied,
  cameraUnavailable,
  imageUnreadable,
  modelUnavailable,
  emptyText,
  recognizerFailed,
}

class OcrException implements Exception {
  const OcrException(this.kind, [this.message]);

  final OcrFailureKind kind;
  final String? message;

  @override
  String toString() =>
      'OcrException($kind${message == null ? '' : ': $message'})';
}

class OcrBlock {
  const OcrBlock({required this.text});

  final String text;
}

class OcrDraft {
  OcrDraft({
    required this.draftId,
    required this.text,
    List<OcrBlock> blocks = const [],
    this.engine = 'mlkit_text_recognition_v2',
    this.script = 'Japanese',
  }) : blocks = List.unmodifiable(blocks);

  final String draftId;
  final String text;
  final List<OcrBlock> blocks;
  final String engine;
  final String script;
}

/// Normalizes line endings and trims outer whitespace without deleting
/// internal spaces or changing Kanji/Kana characters.
String normalizeOcrText(String raw) => raw.replaceAll('\r\n', '\n').trim();

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
    final clean = normalizeOcrText(draft.text);
    if (clean.isEmpty) {
      throw const OcrException(
        OcrFailureKind.emptyText,
        'Không nhận diện được chữ tiếng Nhật trong ảnh.',
      );
    }
    if (clean == draft.text) return draft;
    return OcrDraft(
      draftId: draft.draftId,
      text: clean,
      blocks: draft.blocks,
      engine: draft.engine,
      script: draft.script,
    );
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
    final clean = normalizeOcrText(draft.text);
    if (clean.isEmpty) {
      throw const OcrException(
        OcrFailureKind.emptyText,
        'Không nhận diện được chữ tiếng Nhật trong ảnh.',
      );
    }
    if (clean == draft.text) return draft;
    return OcrDraft(
      draftId: draft.draftId,
      text: clean,
      blocks: draft.blocks,
      engine: draft.engine,
      script: draft.script,
    );
  }
}
