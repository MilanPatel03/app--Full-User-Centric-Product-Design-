import 'package:flutter/material.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../chapters/domain/entities/chapter.dart';

/// Sacred Editorial — Chapter List Card
///
/// Displays one chapter as a manuscript-style entry. No borders, no dividers.
/// Depth is communicated through tonal surface layering only.
///
/// ## Layout
/// ```
/// ┌─────────────────────────────────────────────────┐  ← SectionContainer tier=low
/// │  01    │                  साङ्ख्ययोग             │  ← Sanskrit title (right-aligned)
/// │  [dim] │  Sankhya Yoga                          │  ← English meaning
/// │        │                          72 verses  — │  ← Verse count pill (right)
/// └─────────────────────────────────────────────────┘
/// ```
///
/// ## Interaction
/// - [onTap] fires on release (not on press)
/// - Press scale: 1.0 → 0.98 over [AppAnimations.quick] (300ms easeOut)
/// - Spring-back: 0.98 → 1.0 over [AppAnimations.quick] (300ms easeIn)
class ChapterCard extends StatefulWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
  });

  final Chapter chapter;
  final VoidCallback onTap;

  @override
  State<ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<ChapterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,        // 300ms forward (press)
      reverseDuration: AppAnimations.quick, // 300ms reverse (release)
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _press, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _press.forward();

  void _onTapUp(TapUpDetails _) {
    _press.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SectionContainer(
          tier: SurfaceTier.low,
          padding: AppEdgeInsets.card,
          borderRadius: AppRadius.mdBorder,
          child: _CardContent(chapter: widget.chapter),
        ),
      ),
    );
  }
}

// ── Card content (stateless, no tap logic) ─────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({required this.chapter});

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Chapter number — dim, decorative, left anchor ─────────────────
        SizedBox(
          width: 48,
          child: Text(
            chapter.index.toString().padLeft(2, '0'),
            style: AppTypography.displayLarge.copyWith(
              fontSize: 36,  // Slightly smaller than full display for balance
              color: scheme.onSurface.withValues(alpha: 0.15),
              height: 1.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // ── Chapter info — right-side column ──────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sanskrit title — right aligned (Devanagari reads right-to-left aesthetically)
              Text(
                chapter.titleSanskrit.isNotEmpty
                    ? chapter.titleSanskrit
                    : chapter.title,
                style: context.sanskritBody,
                textAlign: TextAlign.right,
              ),

              const SizedBox(height: AppSpacing.xs),

              // English meaning — left aligned, creates visual asymmetry
              Text(
                chapter.title,
                style: context.wisdomBodyMuted,
              ),

              const SizedBox(height: AppSpacing.md),

              // Verse count pill — right aligned
              Align(
                alignment: Alignment.centerRight,
                child: _VersePill(count: chapter.verseCount),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Verse count pill ───────────────────────────────────────────────────────

class _VersePill extends StatelessWidget {
  const _VersePill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SectionContainer(
      tier: SurfaceTier.medium,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppRadius.fullBorder,
      child: Text(
        '$count verses',
        style: context.utilityCaption.copyWith(color: scheme.secondary),
      ),
    );
  }
}
