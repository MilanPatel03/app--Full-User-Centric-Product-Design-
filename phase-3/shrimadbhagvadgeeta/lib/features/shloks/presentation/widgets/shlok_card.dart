import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/settings_provider.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../bookmarks/presentation/providers/bookmarks_state_provider.dart';
import '../../domain/entities/shlok.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShlokCard
// ─────────────────────────────────────────────────────────────────────────────

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
      duration: AppAnimations.quick,
      reverseDuration: AppAnimations.quick,
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
    final fontScale = ref.watch(fontScaleProvider);

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
            fontScale: fontScale,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card content — fontScale applied to reading text only
// ─────────────────────────────────────────────────────────────────────────────

class _ShlokCardContent extends StatelessWidget {
  const _ShlokCardContent({
    required this.shlok,
    required this.verseLabel,
    required this.isBookmarked,
    required this.fontScale,
  });

  final Shlok shlok;
  final String verseLabel;
  final bool isBookmarked;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Verse label + bookmark ──────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Inter caption — never scales
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

        // ── Sanskrit — NotoSerifDevanagari, scales ──────────────────────────
        if (shlok.sanskritText.isNotEmpty)
          Text(
            shlok.sanskritText,
            style: AppTypography.sanskritBody.copyWith(
              color: scheme.onSurface,
              fontSize: 20 * fontScale,
              height: 2.1,
            ),
            textAlign: TextAlign.center,
          ),

        // ── Transliteration — NotoSerif italic, scales ──────────────────────
        if (shlok.transliteration.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            shlok.transliteration,
            style: AppTypography.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              fontSize: 14 * fontScale,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // ── Translation — NotoSerif body, scales ────────────────────────────
        if (shlok.translation.isNotEmpty)
          Text(
            shlok.translation,
            style: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurface,
              fontSize: 16 * fontScale,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton card
// ─────────────────────────────────────────────────────────────────────────────

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
          Row(children: [
            _Shimmer(width: 28, height: 10, color: shimmer),
            const Spacer(),
            _Shimmer(width: 18, height: 18, color: shimmerDim),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.center,
            child: Column(children: [
              _Shimmer(width: 220, height: 22, color: shimmer),
              const SizedBox(height: AppSpacing.sm),
              _Shimmer(width: 190, height: 22, color: shimmer),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.center,
            child: Column(children: [
              _Shimmer(width: 200, height: 14, color: shimmerDim),
              const SizedBox(height: AppSpacing.xs),
              _Shimmer(width: 160, height: 14, color: shimmerDim),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
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
  const _Shimmer({required this.width, required this.height, required this.color});
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
        color: color, borderRadius: AppRadius.smBorder),
  );
}