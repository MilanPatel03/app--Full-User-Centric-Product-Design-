import 'package:flutter/material.dart';

/// Represents a surface elevation tier in the Sacred Editorial system.
///
/// Use this instead of manually selecting surface hex colors.
/// The correct color is resolved from [ColorScheme] automatically.
enum SurfaceTier {
  /// surfaceContainerLowest — deepest, rarely used alone.
  lowest,

  /// surfaceContainerLow — structural sections, major content areas.
  low,

  /// surfaceContainer — secondary containers, nested sections.
  medium,

  /// surfaceContainerHigh — cards, verse containers, interactive items.
  high,

  /// surfaceContainerHighest — floating elements, selected / active states.
  highest,
}

/// A container that automatically resolves its background from [SurfaceTier].
///
/// This is the primary tool for implementing the "No-Line" depth system.
/// Use surface tier changes instead of borders or dividers.
///
/// ```dart
/// SectionContainer(
///   tier: SurfaceTier.high,
///   padding: AppEdgeInsets.card,
///   borderRadius: AppRadius.mdBorder,
///   child: VerseCard(),
/// )
/// ```
class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.tier,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.clipBehavior = Clip.none,
  });

  final SurfaceTier tier;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  Color _resolveColor(ColorScheme scheme) => switch (tier) {
        SurfaceTier.lowest => scheme.surfaceContainerLowest,
        SurfaceTier.low => scheme.surfaceContainerLow,
        SurfaceTier.medium => scheme.surfaceContainer,
        SurfaceTier.high => scheme.surfaceContainerHigh,
        SurfaceTier.highest => scheme.surfaceContainerHighest,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: _resolveColor(scheme),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
