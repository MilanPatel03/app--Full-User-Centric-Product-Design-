import 'package:flutter/material.dart';
import '../app_radius.dart';

/// Wraps a widget with a 15% opacity outline_variant border.
///
/// This is the ONLY permitted border style in the Sacred Editorial system.
/// 100% opaque lines are strictly prohibited — they "break the spiritual flow."
///
/// # When to Use
/// - Ghost buttons (secondary CTA)
/// - Accessibility: when surface-only separation is insufficient
/// - Glass container edges (subtle boundary on blur)
///
/// # Do NOT Use
/// - As a substitute for [SectionContainer] (use surface tiers instead)
/// - As list/section dividers
class GhostBorder extends StatelessWidget {
  const GhostBorder({
    super.key,
    required this.child,
    this.borderRadius,
    this.width = 1.0,
    this.padding,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double width;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? AppRadius.mdBorder;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.15),
          width: width,
        ),
      ),
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );
  }
}
