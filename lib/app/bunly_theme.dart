import 'package:flutter/material.dart';

@immutable
class BunlyTones extends ThemeExtension<BunlyTones> {
  const BunlyTones({
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.subtleBorder,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.statusFreshBg,
    required this.statusFreshFg,
    required this.statusLearningBg,
    required this.statusLearningFg,
    required this.statusReviewBg,
    required this.statusReviewFg,
    required this.statusMasteredBg,
    required this.statusMasteredFg,
  });

  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color subtleBorder;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color statusFreshBg;
  final Color statusFreshFg;
  final Color statusLearningBg;
  final Color statusLearningFg;
  final Color statusReviewBg;
  final Color statusReviewFg;
  final Color statusMasteredBg;
  final Color statusMasteredFg;

  static const light = BunlyTones(
    primaryFixed: Color(0xFFA9F3C0),
    onPrimaryFixed: Color(0xFF00210F),
    primaryFixedDim: Color(0xFF8ED6A5),
    subtleBorder: Color(0xFFBFC9BF),
    skeletonBase: Color(0xFFE0E7E1),
    skeletonHighlight: Color(0xFFD6E7D8),
    statusFreshBg: Color(0xFFE1F2E4),
    statusFreshFg: Color(0xFF4F6355),
    statusLearningBg: Color(0xFFCFE5D3),
    statusLearningFg: Color(0xFF004F2B),
    statusReviewBg: Color(0xFFFFDAD6),
    statusReviewFg: Color(0xFF93000A),
    statusMasteredBg: Color(0xFFA9F3C0),
    statusMasteredFg: Color(0xFF00210F),
  );

  static const dark = BunlyTones(
    primaryFixed: Color(0xFF215236),
    onPrimaryFixed: Color(0xFFC5F8D3),
    primaryFixedDim: Color(0xFF5DA97A),
    subtleBorder: Color(0xFF394C3F),
    skeletonBase: Color(0xFF233529),
    skeletonHighlight: Color(0xFF2F4437),
    statusFreshBg: Color(0xFF223328),
    statusFreshFg: Color(0xFFAEC1B3),
    statusLearningBg: Color(0xFF1F4B32),
    statusLearningFg: Color(0xFFA9F3C0),
    statusReviewBg: Color(0xFF5E1B18),
    statusReviewFg: Color(0xFFFFDAD6),
    statusMasteredBg: Color(0xFF1F6840),
    statusMasteredFg: Color(0xFFCFFFE0),
  );

  static BunlyTones of(BuildContext context) =>
      Theme.of(context).extension<BunlyTones>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  BunlyTones copyWith({
    Color? primaryFixed,
    Color? onPrimaryFixed,
    Color? primaryFixedDim,
    Color? subtleBorder,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? statusFreshBg,
    Color? statusFreshFg,
    Color? statusLearningBg,
    Color? statusLearningFg,
    Color? statusReviewBg,
    Color? statusReviewFg,
    Color? statusMasteredBg,
    Color? statusMasteredFg,
  }) => BunlyTones(
    primaryFixed: primaryFixed ?? this.primaryFixed,
    onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
    primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
    subtleBorder: subtleBorder ?? this.subtleBorder,
    skeletonBase: skeletonBase ?? this.skeletonBase,
    skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    statusFreshBg: statusFreshBg ?? this.statusFreshBg,
    statusFreshFg: statusFreshFg ?? this.statusFreshFg,
    statusLearningBg: statusLearningBg ?? this.statusLearningBg,
    statusLearningFg: statusLearningFg ?? this.statusLearningFg,
    statusReviewBg: statusReviewBg ?? this.statusReviewBg,
    statusReviewFg: statusReviewFg ?? this.statusReviewFg,
    statusMasteredBg: statusMasteredBg ?? this.statusMasteredBg,
    statusMasteredFg: statusMasteredFg ?? this.statusMasteredFg,
  );

  @override
  BunlyTones lerp(covariant ThemeExtension<BunlyTones>? other, double t) {
    if (other is! BunlyTones) return this;
    return BunlyTones(
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      primaryFixedDim: Color.lerp(primaryFixedDim, other.primaryFixedDim, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      statusFreshBg: Color.lerp(statusFreshBg, other.statusFreshBg, t)!,
      statusFreshFg: Color.lerp(statusFreshFg, other.statusFreshFg, t)!,
      statusLearningBg: Color.lerp(
        statusLearningBg,
        other.statusLearningBg,
        t,
      )!,
      statusLearningFg: Color.lerp(
        statusLearningFg,
        other.statusLearningFg,
        t,
      )!,
      statusReviewBg: Color.lerp(statusReviewBg, other.statusReviewBg, t)!,
      statusReviewFg: Color.lerp(statusReviewFg, other.statusReviewFg, t)!,
      statusMasteredBg: Color.lerp(
        statusMasteredBg,
        other.statusMasteredBg,
        t,
      )!,
      statusMasteredFg: Color.lerp(
        statusMasteredFg,
        other.statusMasteredFg,
        t,
      )!,
    );
  }
}

ThemeData bunlyTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1F6840),
    brightness: brightness,
  );
  final colors = isDark
      ? base.copyWith(
          primary: const Color(0xFF8ED6A5),
          onPrimary: const Color(0xFF00391D),
          primaryContainer: const Color(0xFF1F6840),
          onPrimaryContainer: const Color(0xFFC5F8D3),
          secondary: const Color(0xFFB6CCBB),
          onSecondary: const Color(0xFF1E3225),
          secondaryContainer: const Color(0xFF273D2F),
          onSecondaryContainer: const Color(0xFFCFE5D3),
          tertiary: const Color(0xFFB4CCBA),
          tertiaryContainer: const Color(0xFF34493C),
          onTertiaryContainer: const Color(0xFFD0E9D6),
          surface: const Color(0xFF0E1711),
          surfaceContainerLowest: const Color(0xFF132018),
          surfaceContainerLow: const Color(0xFF18261D),
          surfaceContainer: const Color(0xFF1D2D23),
          surfaceContainerHigh: const Color(0xFF25382C),
          surfaceContainerHighest: const Color(0xFF2F4437),
          onSurface: const Color(0xFFE3F1E6),
          onSurfaceVariant: const Color(0xFFAEC1B3),
          outline: const Color(0xFF798B7E),
          outlineVariant: const Color(0xFF394C3F),
          error: const Color(0xFFFFB4AB),
          onError: const Color(0xFF690005),
          errorContainer: const Color(0xFF5E1B18),
          onErrorContainer: const Color(0xFFFFDAD6),
        )
      : base.copyWith(
          primary: const Color(0xFF004F2B),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFF1F6840),
          onPrimaryContainer: const Color(0xFF9BE4B2),
          secondary: const Color(0xFF4F6355),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFCFE5D3),
          onSecondaryContainer: const Color(0xFF384B3E),
          tertiary: const Color(0xFF34493C),
          tertiaryContainer: const Color(0xFF4B6152),
          onTertiaryContainer: const Color(0xFFC2DBC8),
          surface: const Color(0xFFEDFEEF),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFE7F8E9),
          surfaceContainer: const Color(0xFFE1F2E4),
          surfaceContainerHigh: const Color(0xFFDCECDE),
          surfaceContainerHighest: const Color(0xFFD6E7D8),
          onSurface: const Color(0xFF111E16),
          onSurfaceVariant: const Color(0xFF404941),
          outline: const Color(0xFF707A71),
          outlineVariant: const Color(0xFFBFC9BF),
          error: const Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: const Color(0xFFFFDAD6),
          onErrorContainer: const Color(0xFF93000A),
        );
  final tones = isDark ? BunlyTones.dark : BunlyTones.light;

  return ThemeData(
    colorScheme: colors,
    extensions: [tones],
    useMaterial3: true,
    fontFamilyFallback: const ['Noto Sans JP', 'Noto Sans'],
    scaffoldBackgroundColor: colors.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      titleTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 70,
      backgroundColor: colors.surface,
      indicatorColor: colors.secondaryContainer,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? colors.primary
              : colors.onSurfaceVariant,
          size: 24,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? colors.primary
              : colors.onSurfaceVariant,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide.none,
      backgroundColor: colors.surfaceContainer,
      selectedColor: colors.secondaryContainer,
      labelStyle: TextStyle(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: TextStyle(
        color: colors.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.8),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
