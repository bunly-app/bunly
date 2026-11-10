import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../domain/ocr_draft.dart';

typedef RecognizeImageCallback = Future<RecognizedText> Function(String path);

class MlKitOcrRepository implements OcrRepository {
  MlKitOcrRepository({
    ImagePicker? picker,
    TextRecognizer? recognizer,
    RecognizeImageCallback? recognizeImage,
    String Function()? nextId,
  }) : _picker = picker ?? ImagePicker(),
       _recognizer =
           recognizer ?? TextRecognizer(script: TextRecognitionScript.japanese),
       _recognizeImage = recognizeImage,
       _nextId = nextId ?? const Uuid().v4;

  final ImagePicker _picker;
  final TextRecognizer _recognizer;
  final RecognizeImageCallback? _recognizeImage;
  final String Function() _nextId;

  bool _disposed = false;
  bool _picking = false;

  @override
  Future<OcrDraft?> scan(OcrSource source) async {
    if (_disposed || _picking) return null;
    _picking = true;
    try {
      XFile? picked = await _picker.pickImage(
        source: source == OcrSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 92,
        requestFullMetadata: false,
      );
      if (picked == null && Platform.isAndroid) {
        try {
          final lost = await _picker.retrieveLostData();
          if (!lost.isEmpty && lost.type == RetrieveType.image) {
            picked = lost.file;
          }
        } catch (_) {
          // Best-effort lost-data recovery on Android activity recreation.
        }
      }
      if (picked == null || _disposed) return null;
      return await scanFilePath(picked.path);
    } on OcrException {
      rethrow;
    } on PlatformException catch (e) {
      throw _mapPlatformError(e);
    } on MissingPluginException {
      throw const OcrException(
        OcrFailureKind.modelUnavailable,
        'Thiết bị chưa hỗ trợ nhận diện chữ từ ảnh.',
      );
    } on UnimplementedError {
      throw const OcrException(
        OcrFailureKind.modelUnavailable,
        'Thiết bị chưa hỗ trợ nhận diện chữ từ ảnh.',
      );
    } catch (_) {
      throw const OcrException(
        OcrFailureKind.recognizerFailed,
        'Không thể mở ảnh. Hãy thử chọn lại hoặc nhập câu trực tiếp.',
      );
    } finally {
      _picking = false;
    }
  }

  @override
  Future<OcrDraft?> scanFilePath(String path) async {
    if (_disposed) return null;
    final file = File(path);
    if (!await file.exists()) {
      throw const OcrException(
        OcrFailureKind.imageUnreadable,
        'Không tìm thấy tệp ảnh đã chọn.',
      );
    }
    final size = await file.length();
    if (size <= 0) {
      throw const OcrException(
        OcrFailureKind.imageUnreadable,
        'Ảnh trống hoặc bị lỗi.',
      );
    }
    try {
      final stopwatch = Stopwatch()..start();
      final recognized = _recognizeImage != null
          ? await _recognizeImage(file.path)
          : await _recognizer.processImage(InputImage.fromFilePath(file.path));
      if (_disposed) return null;

      final normalized = normalizeOcrText(recognized.text);
      if (normalized.isEmpty) {
        throw const OcrException(
          OcrFailureKind.emptyText,
          'Không phát hiện thấy chữ tiếng Nhật trong ảnh.',
        );
      }

      final allLines = <OcrLine>[];
      final blocks = <OcrBlock>[];
      for (final block in recognized.blocks) {
        final blockText = normalizeOcrText(block.text);
        if (blockText.isEmpty) continue;

        final blockLines = <OcrLine>[];
        for (final line in block.lines) {
          final cleanLine = JapaneseOcrPostProcessor.normalizeLine(line.text);
          if (cleanLine.isEmpty) continue;
          final lineConfidence = _resolveLineConfidence(line);
          final ocrLine = OcrLine(
            text: cleanLine,
            rawText: line.text.trim(),
            confidence: lineConfidence,
          );
          blockLines.add(ocrLine);
          allLines.add(ocrLine);
        }

        final blockConfidence = _averageConfidence(
          blockLines.map((l) => l.confidence),
        );
        blocks.add(
          OcrBlock(
            text: blockText,
            lines: blockLines,
            confidence: blockConfidence,
          ),
        );
      }

      final avgConf = _averageConfidence(allLines.map((l) => l.confidence));
      final minConf = _minConfidence(allLines.map((l) => l.confidence));
      final candidateSentences = JapaneseOcrPostProcessor.splitSentences(
        normalized,
      );
      stopwatch.stop();

      return OcrDraft(
        draftId: _nextId(),
        text: normalized,
        rawText: recognized.text,
        blocks: blocks,
        lines: allLines,
        candidateSentences: candidateSentences,
        averageConfidence: avgConf,
        minConfidence: minConf,
        latencyMs: stopwatch.elapsedMilliseconds,
        wasPostProcessed: JapaneseOcrPostProcessor.wasModifiedByPostProcessing(
          recognized.text,
          normalized,
        ),
        engine: 'mlkit_text_recognition_v2',
        script: 'Japanese',
      );
    } on OcrException {
      rethrow;
    } on PlatformException catch (e) {
      throw _mapPlatformError(e);
    } on MissingPluginException {
      throw const OcrException(
        OcrFailureKind.modelUnavailable,
        'Bộ nhận diện chữ tiếng Nhật chưa khả dụng trên nền tảng này.',
      );
    } on UnimplementedError {
      throw const OcrException(
        OcrFailureKind.modelUnavailable,
        'Bộ nhận diện chữ tiếng Nhật chưa khả dụng trên nền tảng này.',
      );
    } catch (_) {
      throw const OcrException(
        OcrFailureKind.recognizerFailed,
        'Chưa đọc được chữ từ ảnh. Hãy thử ảnh rõ nét hơn hoặc nhập câu.',
      );
    }
  }

  double? _resolveLineConfidence(TextLine line) {
    final direct = line.confidence;
    if (direct != null && direct >= 0.0 && direct <= 1.0) {
      return direct;
    }
    return _averageConfidence(line.elements.map((e) => e.confidence));
  }

  double? _averageConfidence(Iterable<double?> values) {
    var sum = 0.0;
    var count = 0;
    for (final v in values) {
      if (v != null && v >= 0.0 && v <= 1.0) {
        sum += v;
        count++;
      }
    }
    if (count == 0) return null;
    return sum / count;
  }

  double? _minConfidence(Iterable<double?> values) {
    double? currentMin;
    for (final v in values) {
      if (v != null && v >= 0.0 && v <= 1.0) {
        if (currentMin == null || v < currentMin) {
          currentMin = v;
        }
      }
    }
    return currentMin;
  }

  OcrException _mapPlatformError(PlatformException error) {
    final code = error.code.toLowerCase();
    final msg = (error.message ?? '').toLowerCase();
    if (code.contains('camera_access_denied') ||
        code.contains('photo_access_denied') ||
        code.contains('permission')) {
      return const OcrException(
        OcrFailureKind.permissionDenied,
        'Ứng dụng chưa được cấp quyền Camera hoặc Thư viện ảnh.',
      );
    }
    if (code.contains('no_available_camera')) {
      return const OcrException(
        OcrFailureKind.cameraUnavailable,
        'Thiết bị không có camera khả dụng.',
      );
    }
    if (code.contains('invalid_image') ||
        msg.contains('filenotfound') ||
        msg.contains('decode') ||
        msg.contains('bitmap')) {
      return const OcrException(
        OcrFailureKind.imageUnreadable,
        'Không đọc được định dạng ảnh này.',
      );
    }
    if (msg.contains('model') ||
        msg.contains('optional module') ||
        msg.contains('download') ||
        msg.contains('not initialized')) {
      return const OcrException(
        OcrFailureKind.modelUnavailable,
        'Bộ nhận diện tiếng Nhật ngoại tuyến chưa sẵn sàng trên thiết bị.',
      );
    }
    return const OcrException(
      OcrFailureKind.recognizerFailed,
      'Quá trình nhận diện chữ từ ảnh gặp lỗi. Hãy thử lại.',
    );
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      await _recognizer.close();
    } catch (_) {
      // Safe cleanup if running in a test/non-platform environment.
    }
  }
}
