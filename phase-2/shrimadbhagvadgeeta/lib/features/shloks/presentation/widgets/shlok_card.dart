import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../bookmarks/presentation/providers/bookmarks_state_provider.dart';
import '../../domain/entities/shlok.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShlokCard — Editorial verse entry
// ─────────────────────────────────────────────────────────────────────────────

/// Displays a single verse as a manuscript-style entry.
///
/// ## Visual Hierarchy (top to bottom)
/// ```
/// ┌─────────────────────────────────────────────────┐
/// │  2.47                           [bookmark icon] │  ← utilityCaption
/// │                                                 │
/// │         यदा यदा हि धर्मस्य                      │  ← Sanskrit (center)
/// │         ग्लानिर्भवति भारत।                      │
/// │                                                 │
/// │   yada yada hi dharmasya                        │  ← Transliteration (center, muted)
/// │   glanir bhavati bharata                        │
/// │                                                 │
/// │  Whenever there is a decline in righteousness,  │  ← Translation (left, body)
/// │  O descendant of Bharata...                     │
/// └─────────────────────────────────────────────────┘
/// ```
///
/// ## Interaction
/// - Tap → navigate to [ShlokDetailScreen] via GoRouter
/// - Press scale: 1.0 → 0.98 over 300ms ([AppAnimations.quick])
/// - Bookmark icon: reactive via [isBookmarkedProvider]
class ShlokCard extends ConsumerStatefulWidget {
  const ShlokCard({
    super.key,
    required this.shlok,
    required this.onTap,
  });

  final Shlok shlok;
  final VoidCallback onTap;

  @override
  ConsumerState<ShlokCard> createState() => _ShlokCardState();
}

class _ShlokCardState extends ConsumerState<ShlokCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,        // 300ms forward (press down)
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

  /// Display label — e.g., "2.47" from id "BG_2_47"
  String get _verseLabel =>
      '${widget.shlok.chapterId}.${widget.shlok.verseNumber}';

  void _onTapDown(TapDownDetails _) => _press.forward();

  void _onTapUp(TapUpDetails _) {
    _press.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final isBookmarked = ref.watch(isBookmarkedProvider(widget.shlok.id));

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SectionContainer(
          tier: SurfaceTier.low,
          padding: AppEdgeInsets.verseContainer,
          borderRadius: AppRadius.mdBorder,
          child: _ShlokCardContent(
            shlok: widget.shlok,
            verseLabel: _verseLabel,
            isBookmarked: isBookmarked,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card content — pure presentational (no tap / provider logic)
// ─────────────────────────────────────────────────────────────────────────────

class _ShlokCardContent extends StatelessWidget {
  const _ShlokCardContent({
    required this.shlok,
    required this.verseLabel,
    required this.isBookmarked,
  });

  final Shlok shlok;
  final String verseLabel;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Row: verse label + bookmark icon ────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              verseLabel,
              style: AppTypography.caption.copyWith(
                color: scheme.secondary,
                letterSpacing: 1.8,
              ),
            ),
            const Spacer(),
            Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: 18,
              color: isBookmarked
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.30),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Sanskrit text — verse hero ───────────────────────────────────
        if (shlok.sanskritText.isNotEmpty)
          Text(
            shlok.sanskritText,
            style: AppTypography.sanskritBody.copyWith(
              color: scheme.onSurface,
              fontSize: 20,
              height: 2.1, // Extra line-height breathes around Devanagari matras
            ),
            textAlign: TextAlign.center,
          ),

        // ── Transliteration — muted, italic ─────────────────────────────
        if (shlok.transliteration.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            shlok.transliteration,
            style: AppTypography.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // ── Translation — reading text ───────────────────────────────────
        if (shlok.translation.isNotEmpty)
          Text(
            shlok.translation,
            style: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurface,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton card — loading state placeholder
// ─────────────────────────────────────────────────────────────────────────────

/// Mimics [ShlokCard] layout with dim shimmer rectangles.
/// Used while [shloksByChapterProvider] is in loading state.
class ShlokSkeletonCard extends StatelessWidget {
  const ShlokSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shimmer = scheme.onSurface.withValues(alpha: 0.06);
    final shimmerDim = scheme.onSurface.withValues(alpha: 0.04);

    return SectionContainer(
      tier: SurfaceTier.low,
      padding: AppEdgeInsets.verseContainer,
      borderRadius: AppRadius.mdBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse label row
          Row(
            children: [
              Container(
                width: 28,
                height: 10,
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: AppRadius.smBorder,
                ),
              ),
              const Spacer(),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: shimmerDim,
                  borderRadius: AppRadius.smBorder,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Sanskrit text block — center
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                _Shimmer(width: 220, height: 22, color: shimmer),
                const SizedBox(height: AppSpacing.sm),
                _Shimmer(width: 190, height: 22, color: shimmer),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Transliteration — center, narrower
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                _Shimmer(width: 200, height: 14, color: shimmerDim),
                const SizedBox(height: AppSpacing.xs),
                _Shimmer(width: 160, height: 14, color: shimmerDim),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Translation — left-aligned paragraph
          _Shimmer(width: double.infinity, height: 14, color: shimmer),
          const SizedBox(height: AppSpacing.xs),
          _Shimmer(width: double.infinity, height: 14, color: shimmer),
          const SizedBox(height: AppSpacing.xs),
          _Shimmer(width: 180, height: 14, color: shimmer),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.smBorder,
        ),
      );
}
