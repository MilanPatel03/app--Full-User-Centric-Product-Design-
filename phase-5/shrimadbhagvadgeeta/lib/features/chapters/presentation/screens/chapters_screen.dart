import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../domain/entities/chapter.dart';
import '../providers/chapter_progress_provider.dart';
import '../providers/chapters_state_provider.dart';
import '../widgets/chapter_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChaptersScreen — Explore Tab (Tab 1)
// ─────────────────────────────────────────────────────────────────────────────

/// Sacred Editorial chapters list — matches the "The 18 Chapters" Stitch design.
///
/// ## Layout (CustomScrollView slivers)
/// ```
/// [App bar]            ← Hamburger + "The Sacred Editorial" + search
/// [Editorial header]   ← "The 18 Chapters" H1 + subtitle + progress badge
/// [Chapter cards]      ← Async: loading | error | data (with status badges)
/// [Bottom padding]
/// ```
class ChaptersScreen extends ConsumerWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final overallProgress = ref.watch(overallProgressProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _ExploreAppBar()),

          // ── Editorial header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ExploreHeader(overallProgress: overallProgress),
          ),

          // ── Chapter list — async state ───────────────────────────────────
          ..._buildChapterSliver(
            context: context,
            ref: ref,
            chaptersAsync: chaptersAsync,
            scheme: scheme,
          ),

          // ── Bottom breathing room ────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChapterSliver({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<List<Chapter>> chaptersAsync,
    required ColorScheme scheme,
  }) {
    return chaptersAsync.when(
      loading: () => [const _ChaptersLoadingSliver()],
      error: (error, _) => [
        _ChaptersErrorSliver(
          onRetry: () => ref.invalidate(chaptersProvider),
        ),
      ],
      data: (chapters) => [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                if (i.isOdd) return const SizedBox(height: AppSpacing.sm);
                final chapter = chapters[i ~/ 2];
                return ChapterCard(
                  chapter: chapter,
                  // ✓ Fixed route: must use /explore/chapter/N (shell-relative)
                  onTap: () =>
                      context.push('/explore/chapter/${chapter.index}'),
                );
              },
              childCount:
                  chapters.isEmpty ? 0 : (chapters.length * 2) - 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Explore App Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ExploreAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.md, 0,
        ),
        child: Row(
          children: [
            Icon(Icons.menu_rounded, size: 22, color: scheme.primary),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Bhagavad Gita',
              style: AppTypography.titleLarge.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push(AppConstants.routeSearch),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editorial header with overall progress badge
// ─────────────────────────────────────────────────────────────────────────────

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.overallProgress});
  final double overallProgress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // H1 + progress badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The 18\nChapters',
                      style: AppTypography.headlineMedium.copyWith(
                        color: scheme.onSurface,
                        fontSize: 36,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Select a Yoga to begin\nyour journey',
                      style: AppTypography.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Overall progress badge
              _OverallProgressBadge(progress: overallProgress),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverallProgressBadge extends StatelessWidget {
  const _OverallProgressBadge({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = (progress * 100).round();

    return SectionContainer(
      tier: SurfaceTier.low,
      borderRadius: AppRadius.mdBorder,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'OVERALL PROGRESS',
            style: AppTypography.caption.copyWith(
              color: scheme.secondary,
              letterSpacing: 1.2,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Thin progress bar
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: AppRadius.fullBorder,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor:
                    scheme.onSurface.withValues(alpha: 0.08),
                valueColor:
                    AlwaysStoppedAnimation<Color>(scheme.primary),
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$pct%',
            style: AppTypography.labelLarge.copyWith(
              color: scheme.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _ChaptersLoadingSliver extends StatelessWidget {
  const _ChaptersLoadingSliver();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            if (i.isOdd) return const SizedBox(height: AppSpacing.sm);
            return const _SkeletonCard();
          },
          childCount: 9,
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shimmer = scheme.onSurface.withValues(alpha: 0.06);

    return SectionContainer(
      tier: SurfaceTier.low,
      padding: AppEdgeInsets.card,
      borderRadius: AppRadius.mdBorder,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: shimmer,
              borderRadius: AppRadius.smBorder,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 160,
                    height: 18,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: AppRadius.smBorder,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 64,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: AppRadius.fullBorder,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ChaptersErrorSliver extends StatelessWidget {
  const _ChaptersErrorSliver({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: AppEdgeInsets.page,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'विघ्न',
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.12),
                fontSize: 48,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Something feels off.',
              style: AppTypography.titleLarge.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We were unable to load the chapters.\nPlease try again.',
              style: AppTypography.caption.copyWith(
                color: scheme.secondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            _RetryLabel(onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _RetryLabel extends StatefulWidget {
  const _RetryLabel({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_RetryLabel> createState() => _RetryLabelState();
}

class _RetryLabelState extends State<_RetryLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _fade.animateTo(0.5),
      onTapUp: (_) => _fade.animateTo(1.0),
      onTapCancel: () => _fade.animateTo(1.0),
      child: FadeTransition(
        opacity: _fade,
        child: Text(
          'Try again',
          style: AppTypography.labelLarge.copyWith(
            color: scheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
