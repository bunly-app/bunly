import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../grammar/domain/grammar_point.dart';
import '../../practice/domain/practice_engine.dart';
import '../../practice/domain/practice_storage.dart';
import '../../practice/presentation/practice_history_screen.dart';
import '../domain/personal_repository.dart';
import 'learning_widgets.dart';
import 'profile_screen.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  LearningStatus? selected;

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(learningOverviewProvider);
    final profile = ref.watch(profileProvider);
    final attemptsAsync = ref.watch(practiceAttemptsProvider);
    final reviewAsync = ref.watch(reviewStatesProvider);
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);

    final attempts =
        attemptsAsync.valueOrNull ?? const <PracticeAttemptEntry>[];
    final reviewStates = reviewAsync.valueOrNull ?? const <ReviewStateEntry>[];
    final analytics = computePracticeAnalytics(
      attempts: attempts,
      reviewStates: reviewStates,
      nowUtc: DateTime.now().toUtc(),
    );

    return overview.when(
      loading: () => _ProgressSkeleton(
        controller: widget.scrollController,
        colors: colors,
        tones: tones,
      ),
      error: (_, _) => LearningError(
        message: 'Chưa đọc được tiến độ.',
        onRetry: () {
          ref.invalidate(catalogProvider);
          ref.invalidate(learningSummaryProvider);
        },
      ),
      data: (data) {
        final masteredCount = data.withStatus(LearningStatus.mastered).length;
        final learningCount = data.withStatus(LearningStatus.learning).length;
        final reviewCount = data.withStatus(LearningStatus.review).length;
        final freshCount = data.withStatus(LearningStatus.fresh).length;
        final pointById = <String, GrammarPoint>{
          for (final p in data.points) p.id: p,
        };

        final hasAccuracyData = analytics.overall.independentAnswered > 0;
        final weekPercent = analytics.last7Days.accuracyPercent;
        final allPercent = analytics.overall.accuracyPercent;

        return LearningPage(
          storageKey: 'progress',
          controller: widget.scrollController,
          children: [
            PageHeading(
              'Tiến độ học tập',
              'Trạng thái bạn tự đánh giá, tách biệt với kết quả bài luyện.',
              trailing: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.insights, color: colors.primary),
              ),
            ),
            profile.when(
              data: (p) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        constraints.maxWidth < 320 ||
                        MediaQuery.textScalerOf(context).scale(1) > 1.35;
                    final badge = Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        p.level,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colors.onPrimaryContainer
                              : colors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                    final info = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lộ trình ${p.level}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Mục tiêu: ${p.dailyMinutes} phút/ngày',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    );
                    final action = TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ),
                      child: const Text('Đổi lộ trình'),
                    );
                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              badge,
                              const SizedBox(width: 12),
                              Expanded(child: info),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: action,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        badge,
                        const SizedBox(width: 12),
                        Expanded(child: info),
                        action,
                      ],
                    );
                  },
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            LearningSection(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Mức ghi nhớ ${profile.valueOrNull?.level ?? 'N5'}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
                        'Tự đánh giá',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Đã bắt đầu ${data.started}/${data.points.length} mẫu trong kho hiện có.',
                ),
                const SizedBox(height: 12),
                if (data.points.isNotEmpty)
                  StackedProgressBar(
                    mastered: masteredCount,
                    learning: learningCount,
                    review: reviewCount,
                    fresh: freshCount,
                    semanticsLabel: 'Số mẫu đã bắt đầu trong kho hiện có',
                  ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                        constraints.maxWidth >= 280 &&
                            MediaQuery.textScalerOf(context).scale(1) <= 1.5
                        ? 2
                        : 1;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final status in [
                          LearningStatus.mastered,
                          LearningStatus.learning,
                          LearningStatus.review,
                          LearningStatus.fresh,
                        ])
                          SizedBox(
                            width:
                                (constraints.maxWidth - 8 * (columns - 1)) /
                                columns,
                            child: _StatusTile(
                              status: status,
                              count: data.withStatus(status).length,
                              selected: selected == status,
                              onTap: () => setState(
                                () => selected = selected == status
                                    ? null
                                    : status,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '“Đã nắm” là lựa chọn của bạn, chưa phải điểm kiểm tra hay độ chính xác.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selected != null) ...[
              LearningSection(
                children: [
                  Text(
                    'Các mẫu: ${selected!.label}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (data.withStatus(selected!).isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('Chưa có mẫu ở trạng thái này.'),
                    ),
                  for (final point in data.withStatus(selected!))
                    GrammarEntry(
                      point: point,
                      status: selected!,
                      saved: data.summary.saved.contains(point.id),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            LearningSection(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Thực chiến 7 ngày qua',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
                        'Kiểm tra thực tế',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!hasAccuracyData)
                  Text(
                    'Chưa có dữ liệu để tính tỷ lệ trả lời đúng. Hãy hoàn thành câu hỏi trong bài luyện tập chuẩn để xem kết quả lần đầu và lịch SRS.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  )
                else
                  Text(
                    '7 ngày qua: ${analytics.last7Days.independentCorrect}/${analytics.last7Days.independentAnswered} câu lần đầu đúng · Tổng thể: ${analytics.overall.independentCorrect}/${analytics.overall.independentAnswered} câu đạt ($allPercent%).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 12),
                _PracticeMetricRow(
                  icon: Icons.check_circle_outline,
                  title: 'Quiz MCQ & Điền khuyết',
                  subtitle: hasAccuracyData
                      ? 'Lần đầu đúng: ${analytics.overall.independentCorrect}/${analytics.overall.independentAnswered} · Bỏ qua: ${analytics.overall.skippedCount} · Thử lại: ${analytics.overall.retryCount}'
                      : 'Chưa có lượt trả lời độc lập nào được lưu.',
                  statusText: hasAccuracyData
                      ? '${weekPercent ?? allPercent}%'
                      : 'Chưa làm',
                  colors: colors,
                ),
                const SizedBox(height: 8),
                _PracticeMetricRow(
                  icon: Icons.edit_note_outlined,
                  title: 'Viết câu & Dịch thuật',
                  subtitle: 'Nhật ký góp ý AI chưa kết nối.',
                  statusText: 'Chưa nối',
                  colors: colors,
                ),
                const SizedBox(height: 8),
                _PracticeMetricRow(
                  icon: Icons.mic_none_outlined,
                  title: 'Voice phản xạ ngữ cảnh',
                  subtitle: 'Thu âm / ASR chưa kết nối.',
                  statusText: 'Chưa nối',
                  colors: colors,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: colors.error,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Trọng điểm sai sót',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cần ưu tiên',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (analytics.weakGrammars.isNotEmpty) ...[
                  for (final stat in analytics.weakGrammars.take(3))
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pointById[stat.grammarId]?.pattern ??
                                      stat.grammarId,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Sai lần đầu ${stat.wrongIndependentCount}/${stat.totalIndependentCount} lượt${stat.reviewState != null ? ' · ${formatSrsStageLabel(stat.reviewState!.stage)}' : ''}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (stat.unresolvedWrongCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.errorContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${stat.unresolvedWrongCount} câu sai',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.onErrorContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ] else
                  Text(
                    reviewCount > 0
                        ? 'Bạn tự đánh dấu $reviewCount mẫu ở trạng thái Cần ôn. Sổ lỗi bài làm hiện chưa có lỗi sai.'
                        : 'Chưa ghi nhận lỗi sai từ bài làm trên máy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const PracticeHistoryScreen(errorsOnly: true),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.errorContainer,
                    foregroundColor: colors.onErrorContainer,
                  ),
                  icon: const Icon(Icons.rule_outlined),
                  label: Text(
                    analytics.unresolvedErrorCount > 0
                        ? 'Mở sổ lỗi cần ôn (${analytics.unresolvedErrorCount})'
                        : 'Mở sổ lỗi cần ôn',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PracticeHistoryScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('Xem lịch sử bài làm'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.status,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final LearningStatus status;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final color = learningStatusColor(context, status);
    final dotColor = switch (status) {
      LearningStatus.mastered => colors.primaryContainer,
      LearningStatus.learning => tones.primaryFixedDim,
      LearningStatus.review => colors.error,
      LearningStatus.fresh => colors.outlineVariant,
    };

    return Material(
      color: selected
          ? color.withValues(alpha: 0.16)
          : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Semantics(
          selected: selected,
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        status.label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$count mẫu',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton({
    this.controller,
    required this.colors,
    required this.tones,
  });

  final ScrollController? controller;
  final ColorScheme colors;
  final BunlyTones tones;

  @override
  Widget build(BuildContext context) => LearningPage(
    storageKey: 'progress-loading',
    controller: controller,
    children: [
      const PageHeading(
        'Tiến độ học tập',
        'Trạng thái bạn tự đánh giá, tách biệt với kết quả bài luyện.',
      ),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tones.subtleBorder.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 140, height: 20, highlighted: true),
            const SizedBox(height: 10),
            const FractionallySizedBox(
              widthFactor: 0.72,
              child: SkeletonBox(height: 14),
            ),
            const SizedBox(height: 14),
            const SkeletonBox(height: 12, borderRadius: 12),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 68, height: 14),
                        SizedBox(height: 10),
                        SkeletonBox(width: 48, height: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 68, height: 14),
                        SizedBox(height: 10),
                        SkeletonBox(width: 48, height: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _PracticeMetricRow extends StatelessWidget {
  const _PracticeMetricRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String statusText;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
