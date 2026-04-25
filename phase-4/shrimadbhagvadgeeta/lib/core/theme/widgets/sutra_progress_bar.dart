import 'package:flutter/material.dart';
import '../app_animations.dart';

/// The "Sutra" Progress Bar — a 2px sharp indicator with a saffron glow.
///
/// Spec:
/// - Height: 2px (razor-thin)
/// - Track: outlineVariant at 30% opacity
/// - Progress: primary color (Saffron Gold)
/// - Shape: NO rounded caps — sharp and modern (BorderRadius.zero)
/// - Animation: slow-out via [AppAnimations.slow] (500ms)
class SutraProgressBar extends StatelessWidget {
  const SutraProgressBar({
    super.key,
    required this.progress,
    this.height = 2.0,
    this.animate = true,
  });

  /// Progress from 0.0 to 1.0.
  final double progress;

  /// Bar height in pixels. Default is 2.0 per spec.
  final double height;

  /// Whether to animate progress changes with a meditative ease.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
      duration: animate ? AppAnimations.slow : Duration.zero,
      curve: AppAnimations.defaultCurve,
      builder: (context, value, _) {
        return LinearProgressIndicator(
          value: value,
          minHeight: height,
          backgroundColor: scheme.outlineVariant.withValues(alpha: 0.3),
          color: scheme.primary,
          borderRadius: BorderRadius.zero, // Sharp ends — no rounded caps
        );
      },
    );
  }
}
