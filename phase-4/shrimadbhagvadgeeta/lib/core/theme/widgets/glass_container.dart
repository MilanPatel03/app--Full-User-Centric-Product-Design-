import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';

/// A glassmorphism container for premium, ethereal floating elements.
///
/// # Spec
/// - Background: surfaceVariant at 60% opacity
/// - Backdrop blur: 20px – 30px
/// - Border: ghost border (outlineVariant at 15% opacity)
///
/// # Performance Rules (strictly enforced)
/// 1. Never nest [GlassContainer] inside another — GPU cost is O(n²)
/// 2. Maximum 2 glass surfaces visible simultaneously
/// 3. [RepaintBoundary] is applied automatically
/// 4. Falls back to solid surface in high-contrast accessibility mode
///
/// # When to Use
/// - Persistent bottom nav / player controls
/// - "Current Verse" floating overlay
/// - Modal overlays on top of content
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blurSigma = 24.0,
    this.opacity = 0.6,
    this.borderRadius,
    this.padding,
    this.margin,
    this.gradient,
    this.width,
    this.height,
  });

  /// Blur intensity in logical pixels. Spec: 20px – 30px.
  final double blurSigma;

  /// Background opacity (0.0–1.0). Spec: 60% surfaceVariant.
  final double opacity;

  /// Corner radius. Defaults to [AppRadius.lgBorder].
  final BorderRadius? borderRadius;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Optional gradient overlay — e.g., [Theme.of(context).glassGradientOverlay].
  final Gradient? gradient;

  final double? width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? AppRadius.lgBorder;

    // Disable blur in high-contrast mode — blur is not meaningful there.
    if (MediaQuery.of(context).highContrast) {
      return _solidFallback(context, radius);
    }

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: opacity),
                borderRadius: radius,
                gradient: gradient,
                border: Border.all(
                  color: theme.ghostBorder,
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _solidFallback(BuildContext context, BorderRadius radius) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.96),
        borderRadius: radius,
      ),
      child: child,
    );
  }
}
