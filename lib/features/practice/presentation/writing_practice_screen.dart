import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../analysis/domain/on_device_grammar_detector.dart';
import '../../grammar/domain/grammar_point.dart';
import '../../learning/presentation/learning_widgets.dart';
import '../../ocr/data/method_channel_speech_repository.dart';
import '../../ocr/domain/ocr_draft.dart';
import '../../ocr/domain/speech_draft.dart';

class WritingPracticeScreen extends StatefulWidget {
  const WritingPracticeScreen({super.key, this.voice = false});
  final bool voice;
  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  final input = TextEditingController();
  bool hint = false;
  bool confirmed = false;
  bool reference = false;
  bool listening = false;
  SpeechDraft? speechDraft;
  String? speechWarning;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void _insertToken(String token) {
    if (confirmed) return;
    final selection = input.selection;
    final start = selection.isValid ? selection.start : input.text.length;
    final end = selection.isValid ? selection.end : input.text.length;
    input.value = TextEditingValue(
      text: input.text.replaceRange(start, end, token),
      selection: TextSelection.collapsed(offset: start + token.length),
    );
    setState(() {});
  }

  Future<void> _listenJapaneseSpeech() async {
    if (confirmed || listening) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      listening = true;
      speechWarning = null;
    });
    ListenJapaneseSpeech useCase;
    try {
      useCase = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(listenJapaneseSpeechProvider);
    } catch (_) {
      useCase = ListenJapaneseSpeech(MethodChannelSpeechRepository());
    }
    try {
      final draft = await useCase(
        prompt: 'Hãy nói câu với 〜たことがある (ví dụ: 富士山に登ったことがあります)...',
      );
      if (!mounted || draft == null) return;
      setState(() {
        input.text = draft.text;
        input.selection = TextSelection.collapsed(offset: draft.text.length);
        speechDraft = draft;
      });
    } on SpeechException catch (e) {
      if (mounted) {
        setState(() => speechWarning = e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => speechWarning =
              'Chưa thể khởi động Micro nhận dạng giọng nói. Bạn vẫn có thể gõ câu tiếng Nhật bên dưới.',
        );
      }
    } finally {
      if (mounted) setState(() => listening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voice = widget.voice;
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final charCount = input.text.trim().runes.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(voice ? 'Nói một câu' : 'Dịch Việt → Nhật'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Luyện cục bộ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: LearningPage(
            storageKey: voice ? 'voice-preview' : 'translation-preview',
            children: [
              LearningNotice(
                title: voice
                    ? 'Nhận dạng giọng nói tiếng Nhật (ja-JP)'
                    : 'Góp ý AI chưa kết nối',
                icon: voice ? Icons.mic_outlined : Icons.translate,
                message: voice
                    ? 'Bấm nút Micro để nói câu tiếng Nhật trực tiếp hoặc nhập tay, sau đó đối chiếu cấu trúc 〜たことがある bằng AI trên máy.'
                    : 'Tự viết bản dịch và đối chiếu câu tham khảo. Bản này không gửi bài cho AI hoặc chấm câu tự do.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MetaBadge(
                        label: voice ? 'JLPT N4' : 'JLPT N4',
                        bg: colors.secondaryContainer,
                        fg: colors.onSecondaryContainer,
                      ),
                      _MetaBadge(
                        label: voice ? 'Ngữ pháp phản xạ' : 'Kinh nghiệm',
                        bg: colors.surfaceContainerHigh,
                        fg: colors.onSurfaceVariant,
                      ),
                      if (voice)
                        _MetaBadge(
                          label: 'Micro ja-JP',
                          bg: colors.surfaceContainer,
                          fg: colors.secondary,
                        ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Lưu tạm trong phiên',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (voice)
                _VoiceContextCard(colors: colors, tones: tones)
              else
                _TranslationContextCard(colors: colors, tones: tones),
              const SizedBox(height: 16),
              if (voice) ...[
                _VoiceRecorderCard(
                  listening: listening,
                  confirmed: confirmed,
                  draft: speechDraft,
                  warning: speechWarning,
                  onListen: _listenJapaneseSpeech,
                  onSelectAlternative: confirmed
                      ? null
                      : (alt) => setState(() {
                          input.text = alt;
                          input.selection = TextSelection.collapsed(
                            offset: alt.length,
                          );
                        }),
                  colors: colors,
                  tones: tones,
                ),
                const SizedBox(height: 14),
              ],
              LearningSection(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            voice
                                ? Icons.record_voice_over_outlined
                                : Icons.edit_note,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              voice
                                  ? 'Văn bản thay lời nói'
                                  : 'Bản dịch của bạn',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$charCount ký tự',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: input,
                    readOnly: confirmed,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 2000,
                    style: const TextStyle(fontSize: 21, height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'Nhập tiếng Nhật…',
                      filled: true,
                      fillColor: colors.surfaceContainerLow,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (!confirmed) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Chèn nhanh:',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        for (final token in ['。', 'は', 'に', 'へ', 'を'])
                          ActionChip(
                            label: Text(token),
                            onPressed: () => _insertToken(token),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: colors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              voice
                                  ? 'Câu thu âm từ Micro sẽ tự điền vào đây để bạn rà lại Kanji/Kana (hoặc gõ tay bằng IME).'
                                  : 'Nhiều cách dịch được chấp nhận nếu đúng ngữ pháp mục tiêu và ngữ cảnh.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => setState(() => hint = !hint),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hint
                                        ? 'Ẩn gợi ý cấu trúc'
                                        : 'Xem gợi ý cấu trúc',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Mẫu tham khảo: V-た + ことがある',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              hint
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (hint) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tones.subtleBorder.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        voice
                            ? 'Công thức: 富士山に + 登った (V-た) + ことがあります。'
                            : 'Động từ thể た + ことがある / ことがあります. Dùng để nói về trải nghiệm đã qua.',
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (!confirmed)
                FilledButton.icon(
                  onPressed: input.text.trim().isEmpty
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() => confirmed = true);
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Xác nhận văn bản'),
                )
              else ...[
                LearningNotice(
                  title: 'Văn bản đã được bạn xác nhận',
                  icon: Icons.verified_user_outlined,
                  color: tones.statusLearningBg,
                  accentColor: tones.statusLearningFg,
                  message:
                      'Chưa gửi đến dịch vụ bên ngoài. Câu tham khảo là nội dung sẵn có trên máy, chưa phải nhận xét AI về bài của bạn.',
                ),
                const SizedBox(height: 14),
                if (!reference)
                  FilledButton.icon(
                    onPressed: () => setState(() => reference = true),
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Đối chiếu câu tham khảo'),
                  ),
                if (reference) ...[
                  _FeedbackComparisonSection(
                    voice: voice,
                    userAnswer: input.text.trim(),
                    colors: colors,
                    tones: tones,
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: () => setState(() {
                    confirmed = false;
                    reference = false;
                  }),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Tự sửa và thử lại'),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: colors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bản nháp chỉ giữ trong màn này; rời màn sẽ mất bản nháp. Chưa lưu lịch sử hoặc sổ lỗi.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranslationContextCard extends StatelessWidget {
  const _TranslationContextCard({required this.colors, required this.tones});

  final ColorScheme colors;
  final BunlyTones tones;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LearningSection(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'CÂU TIẾNG VIỆT GỐC',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _MetaBadge(
                label: 'Mục tiêu: 〜たことがある',
                bg: colors.secondaryContainer,
                fg: colors.onSecondaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '“Tôi đã từng đi Nhật.”',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.forum_outlined, size: 16, color: colors.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngữ cảnh đàm thoại',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kể chuyện chia sẻ kỷ niệm thông thường với bạn bè, đồng nghiệp mới quen trong không gian trò chuyện tự nhiên.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primaryContainer, colors.tertiaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              color: colors.onPrimaryContainer,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Gợi nhắc: Sử dụng thể quá khứ (た) để diễn tả trải nghiệm đã qua.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _VoiceContextCard extends StatelessWidget {
  const _VoiceContextCard({required this.colors, required this.tones});

  final ColorScheme colors;
  final BunlyTones tones;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LearningSection(
        children: [
          Text(
            '〜たことがある',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '(Đã từng làm gì đó / Kinh nghiệm)',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetaBadge(
                label: 'V-た',
                bg: colors.secondaryContainer,
                fg: colors.onSecondaryContainer,
              ),
              const Text('+', style: TextStyle(fontWeight: FontWeight.w700)),
              _MetaBadge(
                label: 'ことがある',
                bg: colors.surfaceContainerHigh,
                fg: colors.onSurface,
              ),
              Text(
                '→ Diễn tả trải nghiệm quá khứ',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      LearningSection(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.surfaceContainerHigh,
                  colors.secondaryContainer.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.landscape_outlined, size: 28, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetaBadge(
                        label: 'Tình huống thực tế',
                        bg: colors.primaryContainer,
                        fg: colors.onPrimaryContainer,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chủ đề: Leo núi Phú Sĩ (富士山)',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kể rằng bạn đã từng leo núi Phú Sĩ',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Hãy vận dụng mẫu ngữ pháp mục tiêu để trả lời câu hỏi của người bạn Nhật: “Fuji-san ni nobotta koto ga arimasu ka?”',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'GỢI Ý TỪ VỰNG',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '富士山 (ふじさん) · 登る (のぼる)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Núi Phú Sĩ + Leo · Ý tưởng: “Tôi đã từng leo núi Phú Sĩ một lần.”',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

class _VoiceRecorderCard extends StatelessWidget {
  const _VoiceRecorderCard({
    required this.listening,
    required this.confirmed,
    required this.draft,
    required this.warning,
    required this.onListen,
    required this.onSelectAlternative,
    required this.colors,
    required this.tones,
  });

  final bool listening;
  final bool confirmed;
  final SpeechDraft? draft;
  final String? warning;
  final VoidCallback onListen;
  final ValueChanged<String>? onSelectAlternative;
  final ColorScheme colors;
  final BunlyTones tones;

  static const _bars = <double>[
    10,
    18,
    26,
    14,
    28,
    34,
    22,
    16,
    30,
    20,
    12,
    24,
    14,
  ];

  @override
  Widget build(BuildContext context) {
    final conf = draft?.confidence;
    final tier = draft?.confidenceTier ?? OcrConfidenceTier.unknown;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: listening || draft != null
              ? colors.primary.withValues(alpha: 0.45)
              : tones.subtleBorder.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                listening ? Icons.graphic_eq : Icons.mic_outlined,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  listening
                      ? 'Đang lắng nghe giọng nói tiếng Nhật (ja-JP)…'
                      : draft != null
                      ? 'Đã nhận dạng giọng nói tiếng Nhật (ja-JP)'
                      : 'Thu âm giọng nói tiếng Nhật qua Micro (ja-JP)',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            key: const ValueKey('practice-voice-mic-button'),
            onPressed: confirmed || listening ? null : onListen,
            icon: listening
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.mic, size: 18),
            label: Text(
              listening
                  ? 'Đang thu âm (ja-JP)…'
                  : draft == null
                  ? 'Bấm để nói tiếng Nhật (Micro)'
                  : 'Đọc lại bằng Micro',
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 46,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final height in _bars)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color:
                              (listening || draft != null
                                      ? colors.primary
                                      : tones.primaryFixedDim)
                                  .withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (warning != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                warning!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
              ),
            ),
          ],
          if (draft != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MetaBadge(
                  label: conf != null
                      ? 'Độ tin cậy: ${ocrConfidenceLabel(tier)} (${(conf * 100).round()}%)'
                      : 'Nhận dạng ja-JP',
                  bg: tones.primaryFixed,
                  fg: tones.onPrimaryFixed,
                ),
                if (draft!.latencyMs != null)
                  _MetaBadge(
                    label: '${draft!.latencyMs} ms',
                    bg: colors.surfaceContainerHigh,
                    fg: colors.onSurfaceVariant,
                  ),
              ],
            ),
            if (draft!.alternatives.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Chọn phương án Kanji/Kana khác:',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final alt in draft!.alternatives)
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(alt, style: const TextStyle(fontSize: 12)),
                      onPressed: onSelectAlternative == null
                          ? null
                          : () => onSelectAlternative!(alt),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FeedbackComparisonSection extends StatelessWidget {
  const _FeedbackComparisonSection({
    required this.voice,
    required this.userAnswer,
    required this.colors,
    required this.tones,
  });

  final bool voice;
  final String userAnswer;
  final ColorScheme colors;
  final BunlyTones tones;

  static const GrammarPoint _targetPoint = GrammarPoint(
    id: '10000000-0000-0000-0000-000000000001',
    pattern: '〜たことがある',
    level: 'N4',
    category: 'experience',
    meaning: 'Đã từng làm việc gì',
    formula: 'Động từ thể た + ことがある',
    usage: 'Diễn tả trải nghiệm trong quá khứ.',
    examples: [],
  );

  @override
  Widget build(BuildContext context) {
    final detection = voice
        ? const OnDeviceGrammarDetector().detect(userAnswer, [_targetPoint])
        : null;
    final targetMatch = detection != null && detection.matches.isNotEmpty
        ? detection.matches.first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LearningSection(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Bài làm của bạn',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _MetaBadge(
                  label: voice
                      ? (targetMatch != null
                            ? 'Khớp 〜たことがある'
                            : 'Chưa thấy 〜たことがある')
                      : 'Chưa chấm tự động',
                  bg: voice && targetMatch != null
                      ? tones.primaryFixed
                      : colors.surfaceContainer,
                  fg: voice && targetMatch != null
                      ? tones.onPrimaryFixed
                      : colors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                userAnswer,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (voice) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: targetMatch != null
                      ? tones.primaryFixed.withValues(alpha: 0.45)
                      : colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      targetMatch != null
                          ? Icons.verified_outlined
                          : Icons.info_outline,
                      size: 16,
                      color: targetMatch != null
                          ? tones.onPrimaryFixed
                          : colors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        targetMatch != null
                            ? 'AI trên máy (${detection!.latencyMs} ms): Đã nhận diện đúng cấu trúc mục tiêu 〜たことがある${targetMatch.span != null ? ' tại 「${targetMatch.span!.text}」' : ''}.'
                            : 'AI trên máy chưa thấy cụm V-た + ことがある/あります trong câu bạn vừa đọc. Hãy đối chiếu với gợi ý bên dưới.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: targetMatch != null
                              ? tones.onPrimaryFixed
                              : colors.onSurfaceVariant,
                          fontWeight: targetMatch != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        LearningSection(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Câu tham khảo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                _MetaBadge(
                  label: '3 tiêu chí mẫu',
                  bg: colors.secondaryContainer,
                  fg: colors.onSecondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _CriterionCard(
              indexLabel: '1. Truyền đạt đúng ý',
              badge: 'Tiêu chí đối chiếu',
              body: voice
                  ? 'Thể hiện rõ bạn đã từng leo núi Phú Sĩ trong quá khứ.'
                  : 'Thể hiện trải nghiệm đã từng đi Nhật ít nhất một lần, không phải thói quen lặp lại.',
              colors: colors,
            ),
            const SizedBox(height: 8),
            _CriterionCard(
              indexLabel: '2. Ngữ pháp mục tiêu',
              badge: 'V-た + ことがある',
              body: voice
                  ? 'Chia động từ 登る → 登った (thể た), sau đó ghép ことがあります.'
                  : 'Dùng thể quá khứ ngắn 行く → 行った trước ことがあります, tránh dùng thể từ điển.',
              colors: colors,
            ),
            const SizedBox(height: 8),
            _CriterionCard(
              indexLabel: '3. Độ tự nhiên',
              badge: 'Giao tiếp thân thiện',
              body:
                  'Mức lịch sự 〜ます phù hợp với ngữ cảnh trò chuyện cùng bạn bè và đồng nghiệp.',
              colors: colors,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: colors.primary, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GỢI Ý CÂU THAM KHẢO',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    voice
                        ? '富士山に登ったことがあります。'
                        : '日本に行ったことがあります。\n日本へ行ったことがあります。',
                    style: const TextStyle(
                      fontSize: 21,
                      height: 1.75,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    voice
                        ? '“Tôi đã từng leo núi Phú Sĩ.”'
                        : '“Tôi đã từng đi Nhật Bản.” · Có thể dùng trợ từ 「に」 (điểm đến) hoặc 「へ」 (phương hướng).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Có thể có cách diễn đạt khác phù hợp. Đây là mẫu tham khảo từ thiết kế, chưa đánh giá đúng/sai hoặc độ tự nhiên của câu bạn nhập.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _CriterionCard extends StatelessWidget {
  const _CriterionCard({
    required this.indexLabel,
    required this.badge,
    required this.body,
    required this.colors,
  });

  final String indexLabel;
  final String badge;
  final String body;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              indexLabel,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            _MetaBadge(
              label: badge,
              bg: colors.surfaceContainerHigh,
              fg: colors.secondary,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    ),
  );
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700),
    ),
  );
}
