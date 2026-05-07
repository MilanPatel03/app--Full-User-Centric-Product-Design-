import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_shadows.dart';

/// Applies an ambient glow-shadow to a floating element.
///
/// # Sacred Editorial Shadow Rules
/// - Blur: 40px – 60px (soft, expansive)
/// - Opacity: 6% – 10% (barely-there)
/// - Tint: warm onSurface (#E5E2E1), NOT pure black
///
/// # When to Use
/// Only for truly floating elements: modals, current-verse overlays.
/// For surface-based depth, use [SectionContainer] with a higher tier first.
class AmbientShadow extends StatelessWidget {
  const AmbientShadow({
    super.key,
    required this.child,
    this.blurRadius = AppShadows.floatingBlur,
    this.opacity = AppShadows.floatingOpacity,
    this.spreadRadius = AppShadows.floatingSpread,
    this.offset = Offset.zero,
  });

  /// For modal / bottom sheet shadows — larger blur, slightly more opaque.
  const AmbientShadow.modal({
    super.key,
    required this.child,
    this.blurRadius = AppShadows.modalBlur,
    this.opacity = AppShadows.modalOpacity,
    this.spreadRadius = AppShadows.modalSpread,
    this.offset = Offset.zero,
  });

  final Widget child;
  final double blurRadius;

  /// Shadow opacity (0.0–1.0). Applied to the warm tint color.
  final double opacity;
  final double spreadRadius;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: opacity),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
        ],
      ),
      child: child,
    );
  }
}
