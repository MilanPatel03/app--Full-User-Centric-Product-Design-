import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_provider.dart';
import 'app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReadingStyles — Centralized Typography Scaling
// ─────────────────────────────────────────────────────────────────────────────

/// Pre-scaled reading text styles, resolved from [fontScaleProvider].
///
/// ## Design Contract
///
/// - Only **NotoSerif** and **NotoSerifDevanagari** styles are exposed here.
/// - **Inter** (utility labels, navigation, buttons, captions) is NEVER scaled.
/// - Widgets watch [readingStylesProvider] and consume styles directly.
///   They do NOT perform any `fontSize * scale` multiplication themselves.
///
/// ## Usage
///
/// ```dart
/// // In a ConsumerWidget:
/// final rs = ref.watch(readingStylesProvider);
/// Text(shlok.sanskritText, style: rs.sanskritDisplay.copyWith(color: ...));
/// ```
///
/// ## What NOT to do
///
/// ```dart
/// // ❌ Never do this — scaling is not the widget's responsibility:
/// fontSize: AppTypography.sanskritDisplay.fontSize! * fontScale,
/// ```
class ReadingStyles {
  const ReadingStyles._(this._scale);

  final double _scale;

  // ── NotoSerifDevanagari — Sanskrit ────────────────────────────────────────

  /// 28px base × scale — primary shlok display.
  TextStyle get sanskritDisplay =>
      AppTypography.scaled(AppTypography.sanskritDisplay, _scale);

  /// 18px base × scale — inline Sanskrit passages.
  TextStyle get sanskritBody =>
      AppTypography.scaled(AppTypography.sanskritBody, _scale);

  /// 14px base × scale — compact Sanskrit references and list previews.
  TextStyle get sanskritSmall =>
      AppTypography.scaled(AppTypography.sanskritSmall, _scale);

  // ── NotoSerif — English Wisdom ─────────────────────────────────────────────

  /// 56px base × scale — chapter hero displays.
  TextStyle get displayLarge =>
      AppTypography.scaled(AppTypography.displayLarge, _scale);

  /// 28px base × scale — section headlines.
  TextStyle get headlineMedium =>
      AppTypography.scaled(AppTypography.headlineMedium, _scale);

  /// 16px base × scale — primary translation body text.
  TextStyle get bodyLarge =>
      AppTypography.scaled(AppTypography.bodyLarge, _scale);

  /// 14px base × scale — secondary body text, transliteration, commentary.
  TextStyle get bodyMedium =>
      AppTypography.scaled(AppTypography.bodyMedium, _scale);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Global provider for pre-scaled reading styles.
///
/// Rebuilds only when [fontScaleProvider] changes (one of four discrete steps).
/// Widgets that watch this provider receive a fresh [ReadingStyles] instance
/// with all styles already multiplied — no math in the widget tree.
final readingStylesProvider = Provider<ReadingStyles>((ref) {
  final scale = ref.watch(fontScaleProvider);
  return ReadingStyles._(scale);
});
