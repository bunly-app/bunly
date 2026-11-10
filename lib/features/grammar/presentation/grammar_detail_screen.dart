import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../learning/domain/note.dart';
import '../../learning/presentation/learning_controls.dart';
import '../../learning/presentation/learning_widgets.dart';
import '../../practice/presentation/practice_screen.dart';
import '../domain/grammar_point.dart';

class GrammarDetailScreen extends ConsumerStatefulWidget {
  const GrammarDetailScreen({
    super.key,
    required this.point,
    this.sourceSentence,
  });

  final GrammarPoint point;
  final String? sourceSentence;

  @override
  ConsumerState<GrammarDetailScreen> createState() =>
      _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends ConsumerState<GrammarDetailScreen> {
  // Manual QA: M2-MANUAL-05/10 in documents/development/M2-TEST-HANDOFF.md
  // covers real Japanese IME, long notes, keyboard resize and large text.
  final content = TextEditingController();
  String? editingId;
  String? noteMessage;

  @override
  void dispose() {
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    final save = ref.watch(noteControllerProvider);
    final mutation = ref.watch(learningControllerProvider);
    final summary = ref.watch(learningSummaryProvider);
    final notes = ref.watch(notesProvider(point.id));
    final cachedQuestions =
        ref.watch(cachedQuestionsProvider).valueOrNull ?? const [];
    final hasCuratedPractice = cachedQuestions.any(
      (q) => q.grammarId == point.id,
    );
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết ngữ pháp')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            children: [
              LearningSection(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Ngữ pháp ${point.level}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      if (summary.hasValue &&
                          !summary.hasError &&
                          !summary.isLoading)
                        LearningStatusBadge(
                          status: summary.requireValue.statusOf(point.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    point.pattern,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ý NGHĨA NGỮ PHÁP',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.secondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${point.level} · ${point.meaning}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.sourceSentence != null) ...[
                LearningNotice(
                  title: 'Câu bạn đã xác nhận',
                  icon: Icons.push_pin_outlined,
                  color: colors.secondaryContainer,
                  accentColor: colors.onSecondaryContainer,
                  message: widget.sourceSentence!,
                ),
                const SizedBox(height: 16),
              ],
              LearningSection(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Công thức cấu trúc',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      point.formula,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Cách dùng',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          point.usage,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LearningSection(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_outlined,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ví dụ minh họa (${point.examples.length})',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  if (point.examples.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('Mẫu này chưa có ví dụ trong kho đã tải.'),
                    ),
                  for (final example in point.examples) ...[
                    const SizedBox(height: 12),
                    GrammarExamplePanel(example: example),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              LearningControls(grammarId: point.id),
              if (hasCuratedPractice || point.pattern == '〜たことがある') ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PracticeSetupScreen(initialGrammarId: point.id),
                    ),
                  ),
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Luyện tập mẫu này'),
                ),
              ],
              const SizedBox(height: 16),
              LearningSection(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_note_outlined,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ghi chú của bạn',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ghi chú lưu ngay trên thiết bị. Ở chế độ kết nối, hệ thống tự động đồng bộ khi có mạng.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    enabled: !save.isLoading,
                    controller: content,
                    minLines: 2,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung ghi chú',
                    ),
                  ),
                  if (save.hasError) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        save.error is FormatException
                            ? (save.error as FormatException).message
                            : 'Chưa lưu được ghi chú. Hãy thử lại.',
                        style: TextStyle(color: colors.onErrorContainer),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: save.isLoading
                        ? null
                        : () async {
                            final ok = await ref
                                .read(noteControllerProvider.notifier)
                                .save(
                                  Note(
                                    id: editingId ?? const Uuid().v4(),
                                    grammarId: point.id,
                                    content: content.text,
                                    updatedAt: DateTime.now().toUtc(),
                                  ),
                                );
                            if (ok && context.mounted) {
                              content.clear();
                              setState(() {
                                editingId = null;
                                noteMessage = 'Đã lưu trên thiết bị.';
                              });
                            }
                          },
                    child: Text(
                      save.isLoading
                          ? 'Đang lưu…'
                          : editingId == null
                          ? 'Lưu ghi chú'
                          : 'Lưu chỉnh sửa',
                    ),
                  ),
                  if (noteMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: colors.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              noteMessage!,
                              style: TextStyle(
                                color: colors.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (editingId != null) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: save.isLoading
                          ? null
                          : () => setState(() {
                              editingId = null;
                              content.clear();
                            }),
                      child: const Text('Hủy chỉnh sửa'),
                    ),
                  ],
                  const SizedBox(height: 14),
                  notes.when(
                    data: (items) => Column(
                      children: [
                        for (final note in items)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: tones.subtleBorder.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: ListTile(
                              title: Text(note.content),
                              trailing: Wrap(
                                spacing: 2,
                                children: [
                                  IconButton(
                                    tooltip: 'Sửa ghi chú',
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed:
                                        save.isLoading || mutation.isLoading
                                        ? null
                                        : () => setState(() {
                                            editingId = note.id;
                                            content.text = note.content;
                                          }),
                                  ),
                                  IconButton(
                                    tooltip: 'Xóa ghi chú',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed:
                                        save.isLoading || mutation.isLoading
                                        ? null
                                        : () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Xóa ghi chú?',
                                                ),
                                                content: const Text(
                                                  'Ghi chú sẽ bị xóa khỏi danh sách của bạn.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Hủy'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text('Xóa'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmed == true &&
                                                context.mounted) {
                                              final deleted = await ref
                                                  .read(
                                                    learningControllerProvider
                                                        .notifier,
                                                  )
                                                  .perform(
                                                    (u) =>
                                                        u.deleteNote(note.id),
                                                  );
                                              if (mounted &&
                                                  deleted &&
                                                  editingId == note.id) {
                                                setState(() {
                                                  editingId = null;
                                                  content.clear();
                                                });
                                              }
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const Text('Chưa đọc được ghi chú.'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
