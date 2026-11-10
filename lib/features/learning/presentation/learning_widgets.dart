import 'package:flutter/material.dart';

import '../../../app/bunly_theme.dart';
import '../../grammar/domain/grammar_point.dart';
import '../../grammar/presentation/grammar_detail_screen.dart';
import '../domain/personal_repository.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({
    super.key,
    required this.storageKey,
    required this.children,
    this.controller,
  });

  final String storageKey;
  final List<Widget> children;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => ListView(
    controller: controller,
    key: PageStorageKey(storageKey),
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
    children: children,
  );
}

class LearningSection extends StatelessWidget {
  const LearningSection({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderColor,
    this.borderWidth = 1,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final sideColor = borderColor ?? tones.subtleBorder.withValues(alpha: 0.35);
    return Card(
      color: color ?? colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: sideColor, width: borderWidth),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class LearningListPage extends StatelessWidget {
  const LearningListPage({
    super.key,
    required this.storageKey,
    required this.header,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.footer,
  });

  final String storageKey;
  final List<Widget> header;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    controller: controller,
    key: PageStorageKey(storageKey),
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: header,
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, footer == null ? 32 : 12),
        sliver: SliverList.builder(
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      ),
      if (footer != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
          sliver: SliverToBoxAdapter(child: footer),
        ),
    ],
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.description, {super.key, this.trailing});

  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.highlighted = false,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final tones = BunlyTones.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: highlighted ? tones.skeletonHighlight : tones.skeletonBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class StackedProgressBar extends StatelessWidget {
  const StackedProgressBar({
    super.key,
    required this.mastered,
    required this.learning,
    required this.review,
    required this.fresh,
    this.height = 12,
    this.semanticsLabel,
  });

  final int mastered;
  final int learning;
  final int review;
  final int fresh;
  final double height;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final total = mastered + learning + review + fresh;
    if (total <= 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(height),
        ),
      );
    }
    final segments = <(int, Color)>[
      (mastered, colors.primaryContainer),
      (learning, tones.primaryFixedDim),
      (review, colors.error),
      (fresh, colors.surfaceContainerHighest),
    ].where((entry) => entry.$1 > 0).toList();

    return Semantics(
      label: semanticsLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              for (final segment in segments)
                Expanded(
                  flex: segment.$1,
                  child: ColoredBox(
                    color: segment.$2,
                    child: SizedBox(height: height),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GrammarEntry extends StatelessWidget {
  const GrammarEntry({
    super.key,
    required this.point,
    required this.status,
    this.saved = false,
  });

  final GrammarPoint point;
  final LearningStatus status;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      title: Text(
        '${point.level} · ${point.pattern}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              point.meaning,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            LearningStatusBadge(status: status),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (saved)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.bookmark, size: 18, color: colors.primary),
            ),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
      onTap: () => openGrammar(context, point),
    );
  }
}

Color learningStatusColor(BuildContext context, LearningStatus status) =>
    switch (status) {
      LearningStatus.review => Theme.of(context).colorScheme.error,
      LearningStatus.mastered => Theme.of(context).colorScheme.primary,
      LearningStatus.learning => Theme.of(context).colorScheme.primaryContainer,
      LearningStatus.fresh => Theme.of(context).colorScheme.secondary,
    };

class LearningStatusBadge extends StatelessWidget {
  const LearningStatusBadge({super.key, required this.status});
  final LearningStatus status;

  @override
  Widget build(BuildContext context) {
    final tones = BunlyTones.of(context);
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              status.label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GrammarExamplePanel extends StatelessWidget {
  const GrammarExamplePanel({super.key, required this.example});
  final GrammarExample example;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.translate_outlined, size: 15, color: colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Câu ví dụ trong kho',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            example.japanese,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colors.primary, width: 2.5),
              ),
            ),
            child: Text(
              example.vietnamese,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class LearningNotice extends StatelessWidget {
  const LearningNotice({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
    this.accentColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color? color;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = accentColor ?? colors.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: colors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void openGrammar(BuildContext context, GrammarPoint point) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => GrammarDetailScreen(point: point)),
  );
}

class LearningError extends StatelessWidget {
  const LearningError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LearningPage(
      storageKey: 'learning-error',
      children: [
        LearningSection(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: colors.error),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ],
    );
  }
}
