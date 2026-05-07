import 'package:flutter/material.dart';

/// Sacred Editorial — Spacing & Layout System
///
/// Editorial Philosophy: every pixel of negative space is intentional.
/// Verses must have room to "breathe" — generous whitespace is mandatory.
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;       // Minimum card internal padding (spec)
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double editorial = 64.0; // Hero / verse breathing room
}

/// Pre-defined asymmetric EdgeInsets per the editorial layout philosophy.
///
/// The spec: do not use symmetric padding everywhere. Layout should feel
/// "placed with intention, like artifacts on a velvet surface."
abstract final class AppEdgeInsets {
  /// Standard full-width page horizontal padding.
  static const EdgeInsets page =
      EdgeInsets.symmetric(horizontal: AppSpacing.lg);

  /// Verse container: slightly left-heavy, generous vertical.
  static const EdgeInsets verseContainer =
      EdgeInsets.fromLTRB(24, 16, 32, 24);

  /// Sanskrit text: right-heavy to create editorial tension.
  static const EdgeInsets sanskrit = EdgeInsets.fromLTRB(48, 12, 24, 8);

  /// English translation: asymmetric offset against Sanskrit.
  static const EdgeInsets translation = EdgeInsets.fromLTRB(24, 8, 48, 16);

  /// Card internal padding — 24px minimum per design spec.
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.lg);

  /// Bottom sheet interior.
  static const EdgeInsets bottomSheet = EdgeInsets.fromLTRB(
    AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg,
  );

  /// Compact list tile.
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm + AppSpacing.xs,
  );
}
