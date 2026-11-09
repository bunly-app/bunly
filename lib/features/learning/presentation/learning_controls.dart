import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../domain/personal_repository.dart';
import 'learning_widgets.dart';

class LearningControls extends ConsumerWidget {
  const LearningControls({super.key, required this.grammarId});
  final String grammarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(learningSummaryProvider);
    final action = ref.watch(learningControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);

    return LearningSection(
      children: [
        Row(
          children: [
            Icon(Icons.tune_outlined, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tự đánh giá & Sổ học',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        summary.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const Text('Chưa đọc được tiến độ.'),
          data: (data) {
            final isSaved = data.saved.contains(grammarId);
            final currentStatus = data.statusOf(grammarId);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: action.isLoading
                      ? null
                      : () => ref
                            .read(learningControllerProvider.notifier)
                            .perform((u) => u.setSaved(grammarId, !isSaved)),
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(isSaved ? 'Bỏ lưu mẫu' : 'Lưu mẫu'),
                ),
                const SizedBox(height: 14),
                Text(
                  'Trạng thái học',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final status in LearningStatus.values)
                      _StatusChoicePill(
                        key: ValueKey('status-pill-${status.name}'),
                        status: status,
                        selected: currentStatus == status,
                        disabled: action.isLoading,
                        colors: colors,
                        tones: tones,
                        onTap: () => ref
                            .read(learningControllerProvider.notifier)
                            .perform((u) => u.setStatus(grammarId, status)),
                      ),
                  ],
                ),
                if (action.hasError) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Chưa lưu được thay đổi. Hãy thử lại.',
                      style: TextStyle(color: colors.onErrorContainer),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatusChoicePill extends StatelessWidget {
  const _StatusChoicePill({
    super.key,
    required this.status,
    required this.selected,
    required this.disabled,
    required this.colors,
    required this.tones,
    required this.onTap,
  });

  final LearningStatus status;
  final bool selected;
  final bool disabled;
  final ColorScheme colors;
  final BunlyTones tones;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      LearningStatus.fresh => (
        tones.statusFreshBg,
        tones.statusFreshFg,
        Icons.fiber_new_outlined,
      ),
      LearningStatus.learning => (
        tones.statusLearningBg,
        tones.statusLearningFg,
        Icons.pending_outlined,
      ),
      LearningStatus.review => (
        tones.statusReviewBg,
        tones.statusReviewFg,
        Icons.schedule,
      ),
      LearningStatus.mastered => (
        tones.statusMasteredBg,
        tones.statusMasteredFg,
        Icons.check_circle_outline,
      ),
    };

    return Semantics(
      selected: selected,
      button: true,
      enabled: !disabled,
      child: Material(
        color: selected ? bg : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? fg.withValues(alpha: 0.7)
                    : tones.subtleBorder.withValues(alpha: 0.4),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? Icons.check : icon,
                  size: 16,
                  color: selected ? fg : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    status.label,
                    style: TextStyle(
                      color: selected ? fg : colors.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
