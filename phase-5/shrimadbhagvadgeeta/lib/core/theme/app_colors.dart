import 'package:flutter/material.dart';

/// Sacred Editorial Design System — Color System
///
/// Surface Hierarchy (dark-first, never pure black):
///
///   surface             #131313  ← Main canvas
///   surfaceContainerLowest  #141414
///   surfaceContainerLow     #1C1B1B  ← Structural sections
///   surfaceContainer        #201F1F
///   surfaceContainerHigh    #2B2A2A  ← Cards, verse containers
///   surfaceContainerHighest #353534  ← Floating / interactive
///
/// No-Line Rule: depth via surface tiers, NEVER borders.
abstract final class AppColors {
  // Primary — Saffron Gold
  static const Color primary = Color(0xFFFFC08D);
  static const Color primaryContainer = Color(0xFFFF9933);
  static const Color onPrimary = Color(0xFF3A1D00);
  static const Color onPrimaryContainer = Color(0xFF693800);

  // Secondary — Muted Sage (#8B9A7B)
  static const Color secondary = Color(0xFF8B9A7B);
  static const Color secondaryContainer = Color(0xFF3D4A33);
  static const Color onSecondary = Color(0xFF1A2212);
  static const Color onSecondaryContainer = Color(0xFFBDCBAC);

  // Tertiary — Warm Tan
  static const Color tertiary = Color(0xFFA89070);
  static const Color tertiaryContainer = Color(0xFF3D2D1A);
  static const Color onTertiary = Color(0xFF1A1000);
  static const Color onTertiaryContainer = Color(0xFFD4B896);

  // Error
  static const Color error = Color(0xFFCF6679);
  static const Color onError = Color(0xFF370B1E);
  static const Color errorContainer = Color(0xFF8C1D34);
  static const Color onErrorContainer = Color(0xFFFFDAD9);

  // Dark Surfaces
  static const Color surface = Color(0xFF131313);
  static const Color surfaceVariant = Color(0xFF1E1E1E);
  static const Color surfaceContainerLowest = Color(0xFF141414);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2B2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color surfaceBright = Color(0xFF3D3C3C);
  static const Color inverseSurface = Color(0xFFE5E2E1);

  // Light Surfaces — warm off-whites
  static const Color surfaceLight = Color(0xFFFAF7F2);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF0EDE8);
  static const Color surfaceContainerLight = Color(0xFFEAE6E1);
  static const Color surfaceContainerHighLight = Color(0xFFE8E4DF);
  static const Color surfaceContainerHighestLight = Color(0xFFE0DBD5);

  // On-Surface Text
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFA89B92);
  static const Color onSurfaceLight = Color(0xFF1A1714);
  static const Color onSurfaceVariantLight = Color(0xFF4A4540);

  // Outlines
  static const Color outline = Color(0xFF4A4540);
  static const Color outlineVariant = Color(0xFF2E2C2A);

  static const Color scrim = Color(0xFF000000);
}

/// Exposes Sacred Editorial design tokens beyond standard [ColorScheme].
/// Access via [Theme.of(context).glassBackground] anywhere in the tree.
extension SacredThemeColors on ThemeData {
  /// Glass overlay: surfaceVariant at 60% opacity.
  Color get glassBackground =>
      AppColors.surfaceVariant.withValues(alpha: 0.6);

  /// Ghost border: outlineVariant at 15% — the ONLY permitted border style.
  Color get ghostBorder =>
      colorScheme.outlineVariant.withValues(alpha: 0.15);

  /// Hero CTA gradient: Saffron Gold → Deep Saffron.
  LinearGradient get primaryGradient => const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryContainer],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Glass card active-state overlay gradient.
  LinearGradient get glassGradientOverlay => LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primaryContainer.withValues(alpha: 0.06),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Ambient shadow base tint — warm onSurface tone, NOT pure black.
  /// Apply opacity via .withValues(alpha: shadowOpacity) per-use.
  Color get ambientShadowTint => AppColors.onSurface;
}

/// Dark [ColorScheme] for the Sacred Editorial design system.
ColorScheme buildDarkColorScheme() => const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.surface,
      inversePrimary: AppColors.primaryContainer,
      shadow: Color(0xFF000000),
    );

/// Light [ColorScheme] — same hue family, inverted luminance.
ColorScheme buildLightColorScheme() => const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryContainer,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFD5E4C3),
      onSecondaryContainer: AppColors.onSecondary,
      tertiary: AppColors.tertiary,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFDDC6A8),
      onTertiaryContainer: AppColors.onTertiary,
      error: AppColors.error,
      onError: Color(0xFFFFFFFF),
      errorContainer: AppColors.onErrorContainer,
      onErrorContainer: AppColors.errorContainer,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      surfaceContainerLowest: AppColors.surfaceContainerLowestLight,
      surfaceContainerLow: AppColors.surfaceContainerLowLight,
      surfaceContainer: AppColors.surfaceContainerLight,
      surfaceContainerHigh: AppColors.surfaceContainerHighLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
      outline: Color(0xFF857B73),
      outlineVariant: Color(0xFFCCC4BC),
      scrim: AppColors.scrim,
      inverseSurface: Color(0xFF2E2C2A),
      onInverseSurface: AppColors.surfaceLight,
      inversePrimary: AppColors.primary,
      shadow: Color(0xFF000000),
    );
