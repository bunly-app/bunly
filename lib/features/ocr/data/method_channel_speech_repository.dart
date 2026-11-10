import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../domain/speech_draft.dart';

class MethodChannelSpeechRepository implements SpeechRepository {
  MethodChannelSpeechRepository({MethodChannel? channel, Uuid? uuid})
    : _channel = channel ?? const MethodChannel('app.bunly.bunly/speech'),
      _uuid = uuid ?? const Uuid();

  final MethodChannel _channel;
  final Uuid _uuid;

  @override
  Future<SpeechDraft?> listenJapanese({String? prompt}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>(
        'listenJapanese',
        <String, dynamic>{
          'locale': 'ja-JP',
          if (prompt != null) 'prompt': prompt,
        },
      );
      stopwatch.stop();
      if (raw == null || raw['status'] == 'cancelled') {
        return null;
      }
      final text = (raw['text'] as String? ?? '').trim();
      final rawAlts = raw['alternatives'];
      final alternatives = rawAlts is List
          ? rawAlts
                .whereType<String>()
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(growable: false)
          : const <String>[];
      final confidence = (raw['confidence'] as num?)?.toDouble();

      if (text.isEmpty && alternatives.isEmpty) {
        throw const SpeechException(
          SpeechFailureKind.emptySpeech,
          'Chưa nhận diện được giọng nói tiếng Nhật. Hãy thử nói lại rõ hơn.',
        );
      }

      return SpeechDraft(
        draftId: _uuid.v4(),
        text: text.isNotEmpty ? text : alternatives.first,
        rawText: text.isNotEmpty ? text : alternatives.first,
        alternatives: alternatives,
        confidence: confidence?.clamp(0.0, 1.0),
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } on SpeechException {
      rethrow;
    } on PlatformException catch (e) {
      if (e.code == 'speech_unavailable') {
        throw SpeechException(
          SpeechFailureKind.unavailable,
          e.message ??
              'Thiết bị chưa hỗ trợ hoặc chưa bật nhận diện giọng nói Google.',
        );
      }
      throw SpeechException(
        SpeechFailureKind.failed,
        e.message ?? 'Không thể nhận diện giọng nói lúc này.',
      );
    } on MissingPluginException {
      throw const SpeechException(
        SpeechFailureKind.unavailable,
        'Tính năng nhận diện giọng nói trực tiếp chỉ hỗ trợ trên thiết bị di động.',
      );
    } catch (_) {
      throw const SpeechException(
        SpeechFailureKind.failed,
        'Nhận diện giọng nói thất bại. Bạn vẫn có thể nhập tay hoặc quét ảnh.',
      );
    }
  }
}
