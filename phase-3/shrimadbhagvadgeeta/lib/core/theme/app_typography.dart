import 'package:flutter/material.dart';

/// Sacred Editorial — Typography System
///
/// Font Assignment (strictly enforced — no exceptions):
///   NotoSerifDevanagari → Sanskrit shlok text (श्लोक)
///   NotoSerif           → English wisdom content (translations, titles, body)
///   Inter               → UI utility text (labels, nav, buttons, metadata)
///
/// All styles are compile-time constants — zero runtime cost.
/// Font files must be bundled in assets/fonts/ and declared in pubspec.yaml.
/// Run scripts/download_fonts.ps1 to set up fonts locally.

/// Font family name constants — matches the family names in pubspec.yaml.
/// Change font families here only; all TextStyles update automatically.
abstract final class AppFonts {
  static const String serif = 'NotoSerif';
  static const String devanagari = 'NotoSerifDevanagari';
  static const String inter = 'Inter';
}

abstract final class AppTypography {
  // ── Noto Serif — English Wisdom ───────────────────────────────────────────

  /// display-lg: 56px — Chapter numbers, hero verse starts.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 56,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: -1.0,
  );

  /// headline-md: 28px — Section titles, editorial headers.
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -0.5,
  );

  /// headline-sm: 24px — Sub-section titles.
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: -0.3,
  );

  /// title-lg: 20px — Card titles, prominent headings.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.0,
  );

  /// title-sm: 16px — Verse labels, compact item titles.
  static const TextStyle titleSmall = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
  );

  /// body-lg: 16px — Primary translation text. Generous 1.8 line-height.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.8, // Generous — allows meditation on each line
    letterSpacing: 0.2,
  );

  /// body-md: 14px — Secondary body content.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.15,
  );

  // ── Noto Serif Devanagari — Sanskrit ─────────────────────────────────────

  /// Sanskrit display: 28px — Primary shlok text display.
  static const TextStyle sanskritDisplay = TextStyle(
    fontFamily: AppFonts.devanagari,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.9, // Extra height for matras and vowel diacritics
    letterSpacing: 0.5,
  );

  /// Sanskrit body: 18px — Inline Sanskrit passages.
  static const TextStyle sanskritBody = TextStyle(
    fontFamily: AppFonts.devanagari,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.9,
    letterSpacing: 0.3,
  );

  /// Sanskrit small: 14px — Compact Sanskrit references.
  static const TextStyle sanskritSmall = TextStyle(
    fontFamily: AppFonts.devanagari,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.8,
    letterSpacing: 0.2,
  );

  // ── Inter — UI Utility ────────────────────────────────────────────────────

  /// label-md: 12px — Meta-data, navigation, timestamps.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.6,
  );

  /// label-lg: 14px — Button text, prominent utility labels.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
  );

  /// caption: 11px — Smallest utility text.
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ── TextTheme builder ─────────────────────────────────────────────────────

  /// Builds the complete [TextTheme] for [ThemeData].
  ///
  /// Semantic mapping:
  ///   display / headline / title / body → NotoSerif (wisdom)
  ///   label                             → Inter (utility)
  static TextTheme buildTextTheme({
    required Color primaryColor,
    required Color mutedColor,
  }) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primaryColor),
      displayMedium: const TextStyle(
        fontFamily: AppFonts.serif, fontSize: 40,
        fontWeight: FontWeight.w400, height: 1.2, letterSpacing: -0.8,
      ).copyWith(color: primaryColor),
      displaySmall: const TextStyle(
        fontFamily: AppFonts.serif, fontSize: 32,
        fontWeight: FontWeight.w400, height: 1.25, letterSpacing: -0.5,
      ).copyWith(color: primaryColor),
      headlineLarge: const TextStyle(
        fontFamily: AppFonts.serif, fontSize: 32,
        fontWeight: FontWeight.w500, height: 1.3, letterSpacing: -0.3,
      ).copyWith(color: primaryColor),
      headlineMedium: headlineMedium.copyWith(color: primaryColor),
      headlineSmall: headlineSmall.copyWith(color: primaryColor),
      titleLarge: titleLarge.copyWith(color: primaryColor),
      titleMedium: titleSmall.copyWith(fontSize: 16, color: primaryColor),
      titleSmall: titleSmall.copyWith(color: mutedColor),
      bodyLarge: bodyLarge.copyWith(color: primaryColor),
      bodyMedium: bodyMedium.copyWith(color: mutedColor),
      bodySmall: const TextStyle(
        fontFamily: AppFonts.serif, fontSize: 12,
        fontWeight: FontWeight.w400, height: 1.6, letterSpacing: 0.1,
      ).copyWith(color: mutedColor),
      labelLarge: labelLarge.copyWith(color: primaryColor),
      labelMedium: labelMedium.copyWith(color: primaryColor),
      labelSmall: caption.copyWith(color: mutedColor),
    );
  }
}

/// Semantic typography accessors from any [BuildContext].
///
/// ```dart
/// Text('श्लोक', style: context.sanskritDisplay)
/// Text('Translation', style: context.wisdomBody)
/// Text('Chapter 2', style: context.utilityLabel)
/// ```
extension TypographyContext on BuildContext {
  TextTheme get _tt => Theme.of(this).textTheme;
  ColorScheme get _cs => Theme.of(this).colorScheme;

  // Wisdom (NotoSerif)
  TextStyle get wisdomDisplay => _tt.displayLarge!;
  TextStyle get wisdomHeadline => _tt.headlineMedium!;
  TextStyle get wisdomTitle => _tt.titleLarge!;
  TextStyle get wisdomBody => _tt.bodyLarge!;
  TextStyle get wisdomBodyMuted => _tt.bodyMedium!;

  // Sanskrit (NotoSerifDevanagari — explicit font family override)
  TextStyle get sanskritDisplay =>
      AppTypography.sanskritDisplay.copyWith(color: _cs.onSurface);
  TextStyle get sanskritBody =>
      AppTypography.sanskritBody.copyWith(color: _cs.onSurface);
  TextStyle get sanskritSmall =>
      AppTypography.sanskritSmall.copyWith(color: _cs.onSurfaceVariant);

  // Utility (Inter)
  TextStyle get utilityLabel => _tt.labelMedium!;
  TextStyle get utilityLabelLarge => _tt.labelLarge!;
  TextStyle get utilityCaption => _tt.labelSmall!;
}
