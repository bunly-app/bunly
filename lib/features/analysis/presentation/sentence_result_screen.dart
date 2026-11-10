import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../grammar/domain/grammar_point.dart';
import '../../grammar/presentation/grammar_detail_screen.dart';
import '../../learning/domain/note.dart';
import '../../learning/presentation/learning_widgets.dart';
import '../../practice/presentation/practice_screen.dart';
import '../domain/grammar_analysis.dart';
import '../domain/sentence_preview.dart';

class SentenceResultScreen extends ConsumerStatefulWidget {
  const SentenceResultScreen({
    super.key,
    this.result,
    this.analysis,
    this.sourceIsOcr = false,
  }) : assert(result != null || analysis != null);

  final SentencePreview? result;
  final GrammarAnalysisResult? analysis;
  final bool sourceIsOcr;

  @override
  ConsumerState<SentenceResultScreen> createState() =>
      _SentenceResultScreenState();
}

class _SentenceResultScreenState extends ConsumerState<SentenceResultScreen> {
  final noteId = const Uuid().v4();
  bool saved = false;
  int selectedNoteGrammarIndex = 0;

  bool get isAiResult => widget.analysis != null;

  String get confirmedText => widget.analysis?.text ?? widget.result!.text;

  List<({GrammarPoint point, AnalysisUtf16Span? span})> get matchedEntries {
    final ai = widget.analysis;
    if (ai != null) {
      return [
        for (final match in ai.matches)
          if (match.point != null) (point: match.point!, span: match.span),
      ];
    }
    return [
      for (final point in widget.result!.matches) (point: point, span: null),
    ];
  }

  List<GrammarPoint> get matchedPoints => [
    for (final entry in matchedEntries) entry.point,
  ];

  Future<void> saveSentence() async {
    if (saved || matchedPoints.isEmpty) return;
    final idx = selectedNoteGrammarIndex.clamp(0, matchedPoints.length - 1);
    final point = matchedPoints[idx];
    final ok = await ref
        .read(noteControllerProvider.notifier)
        .save(
          Note(
            id: noteId,
            grammarId: point.id,
            content: confirmedText,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    if (mounted && ok) setState(() => saved = true);
  }

  List<InlineSpan> _buildHighlightedTextSpans(
    String text,
    ColorScheme colors,
    BunlyTones tones,
  ) {
    final ai = widget.analysis;
    if (ai == null) return [TextSpan(text: text)];

    final spans = <AnalysisUtf16Span>[];
    for (final entry in matchedEntries) {
      final span = entry.span;
      if (span == null) continue;
      final validated = validateSpanOnText(
        text,
        startUtf16: span.startUtf16,
        endUtf16: span.endUtf16,
        spanText: span.text,
      );
      if (validated != null) {
        spans.add(validated);
      }
    }
    if (spans.isEmpty) return [TextSpan(text: text)];

    spans.sort((a, b) {
      final startCmp = a.startUtf16.compareTo(b.startUtf16);
      if (startCmp != 0) return startCmp;
      return b.endUtf16.compareTo(a.endUtf16);
    });

    final result = <InlineSpan>[];
    var cursor = 0;
    for (final span in spans) {
      if (span.startUtf16 < cursor) continue;
      if (span.startUtf16 > cursor) {
        result.add(TextSpan(text: text.substring(cursor, span.startUtf16)));
      }
      result.add(
        TextSpan(
          text: text.substring(span.startUtf16, span.endUtf16),
          style: TextStyle(
            backgroundColor: tones.primaryFixed,
            color: tones.onPrimaryFixed,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
            decorationColor: colors.primary,
          ),
        ),
      );
      cursor = span.endUtf16;
    }
    if (cursor < text.length) {
      result.add(TextSpan(text: text.substring(cursor)));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(noteControllerProvider);
    final learningMutation = ref.watch(learningControllerProvider);
    final summary = ref.watch(learningSummaryProvider);
    final savedIds = summary.valueOrNull?.saved ?? const <String>{};
    final entries = matchedEntries;
    final points = [for (final entry in entries) entry.point];
    final ai = widget.analysis;
    final text = confirmedText;
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);

    final aiBadgeText = ai != null
        ? (ai.remainingQuota != null
              ? 'Phân tích AI · Còn ${ai.remainingQuota} lượt'
              : 'Phân tích AI')
        : widget.sourceIsOcr
        ? 'OCR trên máy · Chưa qua AI'
        : 'Chưa qua AI/OCR';

    final sourceText = ai != null
        ? (widget.sourceIsOcr
              ? 'Nguồn: OCR trên máy + văn bản bạn đã sửa và xác nhận gửi AI.'
              : 'Nguồn: văn bản bạn đã nhập/sửa và xác nhận gửi AI.')
        : (widget.sourceIsOcr
              ? 'Nguồn: OCR trên thiết bị (đối chiếu cục bộ, chưa gửi AI).'
              : 'Nguồn: nhập tay / dán câu. Chưa qua OCR hoặc mô hình AI.');

    return Scaffold(
      appBar: AppBar(title: const Text('Ngữ pháp trong câu')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: LearningPage(
            storageKey: 'sentence-result',
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Sửa câu'),
                ),
              ),
              const SizedBox(height: 10),
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
                            Icons.article_outlined,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'CÂU BẠN ĐÃ XÁC NHẬN',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: colors.secondary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAiResult
                              ? tones.primaryFixed
                              : colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          aiBadgeText,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isAiResult
                                    ? tones.onPrimaryFixed
                                    : colors.secondary,
                                fontWeight: isAiResult
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        bottom: BorderSide(color: colors.primary, width: 2.5),
                      ),
                    ),
                    child: SelectableText.rich(
                      TextSpan(
                        children: _buildHighlightedTextSpans(
                          text,
                          colors,
                          tones,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.7,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        widget.sourceIsOcr
                            ? Icons.document_scanner_outlined
                            : Icons.edit_outlined,
                        size: 16,
                        color: colors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sourceText,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colors.secondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (ai != null)
                LearningNotice(
                  title: points.isNotEmpty
                      ? 'Kết quả nhận diện ngữ pháp AI'
                      : 'AI chưa khớp mẫu trong kho hiện có',
                  icon: Icons.auto_awesome,
                  message: points.isNotEmpty
                      ? 'Hệ thống đã ánh xạ các điểm ngữ pháp xuất hiện trong câu về đúng cấu trúc chuẩn của Bunly.'
                      : 'Câu có thể dùng mẫu chưa nằm trong tập được duyệt hiện tại. Bạn có thể sửa câu hoặc tìm thủ công trong Kho ngữ pháp.',
                )
              else
                const LearningNotice(
                  title: 'Kết quả đối chiếu cục bộ',
                  message:
                      'Chỉ hiển thị mẫu có câu ví dụ trùng hoàn toàn với câu bạn nhập. Đây chưa phải phân tích ngữ pháp bằng AI.',
                ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Mẫu ngữ pháp trong kho',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${points.length} mẫu',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (points.isEmpty)
                LearningSection(
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_off_outlined,
                          size: 26,
                          color: colors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isAiResult
                          ? 'Chưa nhận diện được mẫu nào trong kho Bunly.'
                          : 'Chưa có ví dụ trùng trong kho hiện tại.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Điều này không có nghĩa câu sai hoặc không chứa ngữ pháp. Bạn có thể sửa câu, chọn câu ví dụ, hoặc quay lại Tra cứu để tìm thủ công.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('Tìm thủ công trong Kho ngữ pháp'),
                    ),
                  ],
                )
              else ...[
                for (var i = 0; i < entries.length; i++) ...[
                  Builder(
                    builder: (context) {
                      final entry = entries[i];
                      final point = entry.point;
                      final validatedSpan = entry.span == null
                          ? null
                          : validateSpanOnText(
                              text,
                              startUtf16: entry.span!.startUtf16,
                              endUtf16: entry.span!.endUtf16,
                              spanText: entry.span!.text,
                            );
                      final isPointSaved = savedIds.contains(point.id);
                      return LearningSection(
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${point.level} · ${point.pattern}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colors.primary,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: tones.primaryFixed,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  point.level,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: tones.onPrimaryFixed,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            point.meaning,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (validatedSpan != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: tones.primaryFixed.withValues(
                                  alpha: 0.35,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Đoạn khớp trong câu: 「${validatedSpan.text}」',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: tones.onPrimaryFixed,
                                    ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CÔNG THỨC MẪU',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colors.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    point.formula,
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => GrammarDetailScreen(
                                      point: point,
                                      sourceSentence: text,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.menu_book),
                                label: const Text('Xem chi tiết mẫu và ví dụ'),
                              ),
                              if (summary.hasValue && !summary.hasError)
                                FilledButton.tonalIcon(
                                  onPressed: learningMutation.isLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              learningControllerProvider
                                                  .notifier,
                                            )
                                            .perform(
                                              (u) => u.setSaved(
                                                point.id,
                                                !isPointSaved,
                                              ),
                                            ),
                                  icon: Icon(
                                    isPointSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                  ),
                                  label: Text(
                                    isPointSaved ? 'Đã lưu mẫu' : 'Lưu mẫu',
                                  ),
                                ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PracticeSetupScreen(
                                      initialGrammarId: point.id,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.fitness_center),
                                label: const Text('Luyện tập mẫu này'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                if (points.length > 1) ...[
                  Text(
                    'Chọn mẫu để gắn ghi chú câu này:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (var i = 0; i < points.length; i++)
                        ChoiceChip(
                          label: Text(points[i].pattern),
                          selected: selectedNoteGrammarIndex == i,
                          onSelected: saved
                              ? null
                              : (_) => setState(
                                  () => selectedNoteGrammarIndex = i,
                                ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (action.hasError)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Chưa lưu được câu. Hãy thử lại.',
                      style: TextStyle(color: colors.onErrorContainer),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: saved || action.isLoading ? null : saveSentence,
                  icon: Icon(
                    saved ? Icons.check_circle : Icons.bookmark_add_outlined,
                  ),
                  label: Text(
                    saved
                        ? 'Đã lưu câu làm ghi chú trên thiết bị'
                        : 'Lưu câu làm ghi chú',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ghi chú gắn với mẫu ${points[selectedNoteGrammarIndex.clamp(0, points.length - 1)].pattern}. Xem lại trong Sổ học → Ghi chú.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
