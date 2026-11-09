import 'dart:convert';

import '../../grammar/domain/grammar_point.dart';
import '../../grammar/domain/grammar_repository.dart';

const int analysisMaxCodepoints = 1000;
const int analysisMaxUtf8Bytes = 8192;

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

String normalizeAnalysisText(String raw) => raw.replaceAll('\r\n', '\n').trim();

bool hasUnpairedSurrogates(String text) {
  for (var i = 0; i < text.length; i++) {
    final unit = text.codeUnitAt(i);
    if (unit >= 0xd800 && unit <= 0xdbff) {
      if (i + 1 >= text.length) return true;
      final next = text.codeUnitAt(++i);
      if (next < 0xdc00 || next > 0xdfff) return true;
    } else if (unit >= 0xdc00 && unit <= 0xdfff) {
      return true;
    }
  }
  return false;
}

bool isValidUtf16Boundary(String text, int offset) {
  if (offset <= 0 || offset >= text.length) return true;
  final before = text.codeUnitAt(offset - 1);
  final after = text.codeUnitAt(offset);
  return !(before >= 0xd800 &&
      before <= 0xdbff &&
      after >= 0xdc00 &&
      after <= 0xdfff);
}

AnalysisUtf16Span? validateSpanOnText(
  String text, {
  required int startUtf16,
  required int endUtf16,
  required String spanText,
}) {
  if (startUtf16 < 0 || endUtf16 > text.length || startUtf16 >= endUtf16) {
    return null;
  }
  if (!isValidUtf16Boundary(text, startUtf16) ||
      !isValidUtf16Boundary(text, endUtf16)) {
    return null;
  }
  if (text.substring(startUtf16, endUtf16) != spanText) {
    return null;
  }
  return AnalysisUtf16Span(
    startUtf16: startUtf16,
    endUtf16: endUtf16,
    text: spanText,
  );
}

class AnalysisUtf16Span {
  const AnalysisUtf16Span({
    required this.startUtf16,
    required this.endUtf16,
    required this.text,
  });

  final int startUtf16;
  final int endUtf16;
  final String text;
}

class GrammarAnalysisMatch {
  const GrammarAnalysisMatch({required this.grammarId, this.point, this.span});

  final String grammarId;
  final GrammarPoint? point;
  final AnalysisUtf16Span? span;
}

class GrammarAnalysisResult {
  GrammarAnalysisResult({
    required this.requestId,
    required this.text,
    required List<GrammarAnalysisMatch> matches,
    this.remainingQuota,
    required this.isLiveAi,
  }) : matches = List.unmodifiable(matches);

  final String requestId;
  final String text;
  final List<GrammarAnalysisMatch> matches;
  final int? remainingQuota;
  final bool isLiveAi;
}

class AnalysisQuotaStatus {
  const AnalysisQuotaStatus({
    required this.hasEntitlement,
    required this.dailyLimit,
    required this.usedToday,
    required this.reservedToday,
    required this.remainingQuota,
    required this.resetAtUtc,
  });

  final bool hasEntitlement;
  final int dailyLimit;
  final int usedToday;
  final int reservedToday;
  final int remainingQuota;
  final DateTime resetAtUtc;
}

enum AnalysisFailureKind {
  invalidInput,
  unauthenticated,
  requestConflict,
  quotaExceeded,
  invalidOutput,
  unavailable,
  timeout,
  processing,
  offline,
}

class AnalysisException implements Exception {
  const AnalysisException(
    this.kind, {
    this.requestId,
    this.retryAfterMs,
    this.message,
    this.retryable = false,
  });

  final AnalysisFailureKind kind;
  final String? requestId;
  final int? retryAfterMs;
  final String? message;
  final bool retryable;

  @override
  String toString() =>
      'AnalysisException($kind, retryable=$retryable${message == null ? '' : ', $message'})';
}

abstract interface class GrammarAnalysisRepository {
  Future<GrammarAnalysisResult> analyze({
    required String requestId,
    required String normalizedText,
    String locale = 'vi',
  });

  Future<AnalysisQuotaStatus> loadQuota();
}

class AnalyzeGrammarSentence {
  const AnalyzeGrammarSentence(this.repository, this.grammarRepository);

  final GrammarAnalysisRepository repository;
  final GrammarRepository grammarRepository;

  Future<GrammarAnalysisResult> call({
    required String requestId,
    required String draftText,
  }) async {
    final normalizedId = requestId.trim().toLowerCase();
    if (!_uuidPattern.hasMatch(normalizedId)) {
      throw const AnalysisException(
        AnalysisFailureKind.invalidInput,
        message: 'Mã yêu cầu phân tích không hợp lệ.',
      );
    }
    if (hasUnpairedSurrogates(draftText)) {
      throw const AnalysisException(
        AnalysisFailureKind.invalidInput,
        message: 'Văn bản chứa ký tự Unicode không hợp lệ.',
      );
    }
    final normalizedText = normalizeAnalysisText(draftText);
    final codepoints = normalizedText.runes.length;
    if (codepoints < 1 || codepoints > analysisMaxCodepoints) {
      throw const AnalysisException(
        AnalysisFailureKind.invalidInput,
        message: 'Nhập câu từ 1 đến 1000 ký tự.',
      );
    }
    if (utf8.encode(normalizedText).length > analysisMaxUtf8Bytes) {
      throw const AnalysisException(
        AnalysisFailureKind.invalidInput,
        message: 'Câu vượt quá giới hạn dung lượng 8 KiB.',
      );
    }

    final rawResult = await repository.analyze(
      requestId: normalizedId,
      normalizedText: normalizedText,
      locale: 'vi',
    );
    final catalog = await grammarRepository.load();
    final byId = <String, GrammarPoint>{
      for (final point in catalog.points) point.id.toLowerCase(): point,
    };

    final hydrated = <GrammarAnalysisMatch>[];
    for (final match in rawResult.matches) {
      final point = byId[match.grammarId.toLowerCase()];
      if (point == null) {
        throw AnalysisException(
          AnalysisFailureKind.invalidOutput,
          requestId: rawResult.requestId,
          message:
              'Kết quả trả về chứa mẫu ngữ pháp không nằm trong kho đã duyệt.',
        );
      }
      final span = match.span;
      AnalysisUtf16Span? validatedSpan;
      if (span != null) {
        validatedSpan = validateSpanOnText(
          normalizedText,
          startUtf16: span.startUtf16,
          endUtf16: span.endUtf16,
          spanText: span.text,
        );
        if (validatedSpan == null) {
          throw AnalysisException(
            AnalysisFailureKind.invalidOutput,
            requestId: rawResult.requestId,
            message:
                'Vị trí trích dẫn ngữ pháp không khớp với câu đã xác nhận.',
          );
        }
      }
      hydrated.add(
        GrammarAnalysisMatch(
          grammarId: point.id,
          point: point,
          span: validatedSpan,
        ),
      );
    }

    return GrammarAnalysisResult(
      requestId: rawResult.requestId,
      text: normalizedText,
      matches: hydrated,
      remainingQuota: rawResult.remainingQuota,
      isLiveAi: rawResult.isLiveAi,
    );
  }
}

class GetAnalysisQuota {
  const GetAnalysisQuota(this.repository);

  final GrammarAnalysisRepository repository;

  Future<AnalysisQuotaStatus> call() => repository.loadQuota();
}

/// Maintains idempotency per normalized sentence: retries reuse the same
/// request UUID; editing text assigns a new UUID to avoid 409 conflict.
class AnalysisRequestSession {
  String? _lastNormalizedText;
  String? _requestId;

  String? get currentRequestId => _requestId;

  String resolveIdForText(String rawText, String Function() nextUuid) {
    final normalized = normalizeAnalysisText(rawText);
    if (_requestId != null && _lastNormalizedText == normalized) {
      return _requestId!;
    }
    _lastNormalizedText = normalized;
    return _requestId = nextUuid().toLowerCase();
  }

  String forceNewIdForText(String rawText, String Function() nextUuid) {
    _lastNormalizedText = normalizeAnalysisText(rawText);
    return _requestId = nextUuid().toLowerCase();
  }

  void reset() {
    _lastNormalizedText = null;
    _requestId = null;
  }
}
