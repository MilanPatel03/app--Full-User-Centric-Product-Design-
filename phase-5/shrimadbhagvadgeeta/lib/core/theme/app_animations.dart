import 'package:flutter/material.dart';

/// Sacred Editorial — Animation Constants
///
/// Meditative Pace Rule: ALL transitions must be slow-out (≥ 300ms).
/// This is the strict minimum — no exceptions. High-velocity animations
/// destroy the sacred atmosphere and are architecturally prohibited.
///
/// The 300ms floor is enforced here at the constant level.
/// Any attempt to animate faster requires explicit justification.
abstract final class AppAnimations {
  // ── Durations ──────────────────────────────────────────────────────────────

  /// Minimum permitted duration — press feedback, quick state changes.
  /// 300ms enforces the meditative pace even for micro-interactions.
  static const Duration quick = Duration(milliseconds: 300);

  /// Standard UI transition — page elements, card reveals.
  static const Duration standard = Duration(milliseconds: 350);

  /// Slower transitions — section entries, tab changes.
  static const Duration slow = Duration(milliseconds: 500);

  /// Meditative — hero transitions, verse changes, chapter openings.
  static const Duration meditative = Duration(milliseconds: 700);

  // ── Curves ────────────────────────────────────────────────────────────────

  /// Default: decelerates to rest (slow-out). Used for all transitions.
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Gentle entrance for content elements entering the screen.
  static const Curve entranceCurve = Curves.easeOutQuart;

  /// Fade transitions — for opacity-based reveals.
  static const Curve fadeCurve = Curves.easeInOut;

  /// Spring-back — for dismissible or elastic elements.
  static const Curve springCurve = Curves.elasticOut;
}
