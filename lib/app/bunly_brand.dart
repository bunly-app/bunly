import 'package:flutter/material.dart';

class BunlyLogoMark extends StatelessWidget {
  const BunlyLogoMark({
    super.key,
    this.size = 36,
    this.borderRadius = 10,
    this.withShadow = false,
  });

  final double size;
  final double borderRadius;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: dark ? 0.24 : 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/bunly_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          semanticLabel: 'Logo Bunly',
          errorBuilder: (_, _, _) => Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Text(
              '文',
              style: TextStyle(
                color: dark ? colors.onPrimaryContainer : colors.onPrimary,
                fontSize: size * 0.5,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BunlyBrand extends StatelessWidget {
  const BunlyBrand({super.key, this.subtitle = 'Học ngữ pháp qua câu thật'});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BunlyLogoMark(size: 68, borderRadius: 18, withShadow: true),
        const SizedBox(height: 12),
        Text(
          'ぶんぽう',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.secondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Bunly',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
