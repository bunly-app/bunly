import 'ocr_draft.dart';

class SpeechDraft {
  SpeechDraft({
    required this.draftId,
    required this.text,
    String? rawText,
    List<String> alternatives = const [],
    this.confidence,
    this.latencyMs,
  }) : rawText = rawText ?? text,
       alternatives = List.unmodifiable(alternatives);

  final String draftId;
  final String text;
  final String rawText;
  final List<String> alternatives;
  final double? confidence;
  final int? latencyMs;

  OcrConfidenceTier get confidenceTier => classifyOcrConfidence(confidence);
}

enum SpeechFailureKind { emptySpeech, unavailable, failed }

class SpeechException implements Exception {
  const SpeechException(this.kind, [this.message]);

  final SpeechFailureKind kind;
  final String? message;

  @override
  String toString() =>
      'SpeechException($kind${message == null ? '' : ', $message'})';
}

abstract interface class SpeechRepository {
  Future<SpeechDraft?> listenJapanese({String? prompt});
}

class ListenJapaneseSpeech {
  const ListenJapaneseSpeech(
    this.repository, {
    this.appendSentencePeriod = true,
  });

  final SpeechRepository repository;
  final bool appendSentencePeriod;

  Future<SpeechDraft?> call({String? prompt}) async {
    final draft = await repository.listenJapanese(prompt: prompt);
    if (draft == null) return null;

    var normalized = JapaneseOcrPostProcessor.normalizeLine(draft.text);
    if (normalized.isEmpty) {
      throw const SpeechException(
        SpeechFailureKind.emptySpeech,
        'Chưa nghe rõ câu tiếng Nhật. Hãy đọc gần micro hơn hoặc thử lại.',
      );
    }
    if (appendSentencePeriod &&
        !normalized.endsWith('。') &&
        !normalized.endsWith('？') &&
        !normalized.endsWith('！')) {
      normalized = '$normalized。';
    }

    final cleanAlternatives = <String>[];
    final seen = <String>{normalized};
    for (final alt in draft.alternatives) {
      var cleanAlt = JapaneseOcrPostProcessor.normalizeLine(alt);
      if (cleanAlt.isEmpty) continue;
      if (appendSentencePeriod &&
          !cleanAlt.endsWith('。') &&
          !cleanAlt.endsWith('？') &&
          !cleanAlt.endsWith('！')) {
        cleanAlt = '$cleanAlt。';
      }
      if (seen.add(cleanAlt)) {
        cleanAlternatives.add(cleanAlt);
      }
    }

    return SpeechDraft(
      draftId: draft.draftId,
      text: normalized,
      rawText: draft.rawText,
      alternatives: cleanAlternatives,
      confidence: draft.confidence,
      latencyMs: draft.latencyMs,
    );
  }
}
