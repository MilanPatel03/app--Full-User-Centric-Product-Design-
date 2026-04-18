import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/editorial_header.dart';
import '../../../../core/theme/widgets/editorial_layout.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../domain/entities/chapter.dart';
import '../providers/chapters_state_provider.dart';
import '../widgets/chapter_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChaptersScreen — Entry point of the app
// ─────────────────────────────────────────────────────────────────────────────

/// Full editorial implementation of the chapters list screen.
///
/// ## Layout Strategy (CustomScrollView)
/// ```
/// [EditorialHeader]             ← Always visible — static sacred text
/// [Chapter cards / state]       ← Async: loading | error | data
/// [Bottom breathing room]       ← Editorial white space
/// ```
///
/// ## Design Decisions
/// - NO AppBar — floating icon buttons overlay the header instead
/// - CustomScrollView for composable slivers — better than Column in scroll
/// - Each state (loading/error/data) uses SliverFillRemaining for correct centering
class ChaptersScreen extends ConsumerWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final scheme = Theme.of(context).colorScheme;

    return EditorialLayout(
      actions: [
        _ActionIcon(
          icon: Icons.search_rounded,
          tooltip: 'Search verses',
          onTap: () => context.push(AppConstants.routeSearch),
        ),
        _ActionIcon(
          icon: Icons.bookmark_border_rounded,
          tooltip: 'Bookmarks',
          onTap: () => context.push(AppConstants.routeBookmarks),
        ),
        _ActionIcon(
          icon: Icons.more_vert_rounded,
          tooltip: 'More',
          onTap: () => context.push(AppConstants.routeSettings),
        ),
      ],
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Editorial header — always present ──────────────────────────
          const SliverToBoxAdapter(
            child: EditorialHeader(
              eyebrow: 'Sacred Text',
              titleSanskrit: AppConstants.appNameSanskrit,
              subtitle: 'Bhagavad Gita',
              footnote:
                  '${AppConstants.totalChapters} Chapters'
                  ' · ${AppConstants.totalVerses} Verses',
              showOmMark: true,
            ),
          ),

          // ── Chapter list — async state ─────────────────────────────────
          ..._buildChapterSliver(
            context: context,
            ref: ref,
            chaptersAsync: chaptersAsync,
            scheme: scheme,
          ),

          // ── Bottom breathing room ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }

  /// Returns the sliver(s) for the chapter list area based on async state.
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
                // Interleave cards and spacing
                if (i.isOdd) return const SizedBox(height: AppSpacing.sm);
                final chapter = chapters[i ~/ 2];
                return ChapterCard(
                  chapter: chapter,
                  onTap: () =>
                      context.push('/chapter/${chapter.index}'),
                );
              },
              childCount: chapters.isEmpty ? 0 : (chapters.length * 2) - 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading State — Skeleton cards
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
          childCount: 9, // 5 skeleton cards × 2 (interleaved separators) - 1
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
          // Chapter number placeholder
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
                // Sanskrit title placeholder
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
                // English title placeholder
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: AppRadius.smBorder,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Verse count pill placeholder
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
// Error State — Calm, editorial
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
            // Dim Sanskrit character as visual anchor
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
              style: context.wisdomTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We were unable to load the chapters.\nPlease try again.',
              style: context.utilityCaption.copyWith(color: scheme.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Minimal retry — no button, just a tap target
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
          style: context.utilityLabel.copyWith(
            color: scheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating action icon (no AppBar — these overlay the header)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: 22,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
