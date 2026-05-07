import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../app_spacing.dart';
import '../app_radius.dart';
import '../app_animations.dart';

/// The three button variants in the Sacred Editorial design system.
enum SacredButtonVariant { primary, ghost, tertiary }

/// Sacred Button — three variants per spec. All share:
/// - [AppTypography.labelLarge] (Inter 14px/600) for text
/// - [AppRadius.md] (12px) roundedness
/// - [AppAnimations.quick] (200ms) for press feedback
/// - Subtle 0.97x scale-down on press
///
/// ```dart
/// SacredButton.primary(label: 'Begin Reading', onTap: () {})
/// SacredButton.ghost(label: 'View Chapters', onTap: () {})
/// SacredButton.tertiary(label: 'Skip', onTap: () {})
/// ```
class SacredButton extends StatefulWidget {
  const SacredButton.primary({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.trailing,
    this.isFullWidth = false,
    this.isLoading = false,
  }) : variant = SacredButtonVariant.primary;

  const SacredButton.ghost({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.trailing,
    this.isFullWidth = false,
    this.isLoading = false,
  }) : variant = SacredButtonVariant.ghost;

  const SacredButton.tertiary({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.trailing,
    this.isFullWidth = false,
    this.isLoading = false,
  }) : variant = SacredButtonVariant.tertiary;

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool isFullWidth;
  final bool isLoading;
  final SacredButtonVariant variant;

  @override
  State<SacredButton> createState() => _SacredButtonState();
}

class _SacredButtonState extends State<SacredButton> {
  bool _pressed = false;
  bool get _disabled => widget.onTap == null || widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (!_disabled) setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (!_disabled) setState(() => _pressed = false);
  }

  void _onTapCancel() {
    if (!_disabled) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    Widget content = switch (widget.variant) {
      SacredButtonVariant.primary => _buildPrimary(),
      SacredButtonVariant.ghost => _buildGhost(scheme, theme),
      SacredButtonVariant.tertiary => _buildTertiary(scheme),
    };

    if (widget.isFullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return AnimatedOpacity(
      opacity: _disabled ? 0.5 : 1.0,
      duration: AppAnimations.quick,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppAnimations.quick,
        curve: AppAnimations.defaultCurve,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _disabled ? null : widget.onTap,
          child: content,
        ),
      ),
    );
  }

  Widget _buildPrimary() {
    return AnimatedContainer(
      duration: AppAnimations.standard,
      curve: AppAnimations.defaultCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _pressed
            ? AppColors.primaryContainer.withValues(alpha: 0.85)
            : AppColors.primaryContainer,
        borderRadius: AppRadius.mdBorder,
      ),
      child: _content(AppColors.onPrimaryContainer),
    );
  }

  Widget _buildGhost(ColorScheme scheme, ThemeData theme) {
    return AnimatedContainer(
      duration: AppAnimations.standard,
      curve: AppAnimations.defaultCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _pressed
            ? AppColors.surfaceBright.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: theme.ghostBorder),
      ),
      child: _content(scheme.onSurface),
    );
  }

  Widget _buildTertiary(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.6 : 1.0,
        duration: AppAnimations.quick,
        child: _content(scheme.secondary),
      ),
    );
  }

  Widget _content(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          widget.label,
          style: AppTypography.labelLarge.copyWith(color: textColor),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: AppSpacing.xs),
          widget.trailing!,
        ],
      ],
    );
  }
}
