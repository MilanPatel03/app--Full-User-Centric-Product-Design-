import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/reading_styles.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../domain/entities/shlok.dart';
import '../providers/search_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SearchScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Editorial search experience — no Material AppBar chrome.
///
/// ## States
/// - Idle (< 2 chars): Sanskrit prompt + editorial invite
/// - Searching: shimmer row skeleton
/// - No results: Sanskrit word + editorial prose
/// - Error: Sanskrit word + editorial message + retry
/// - Results: SliverList of verse rows
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Manual editorial search bar (no Material AppBar) ───────────
            _SearchBar(
              controller: _controller,
              hasQuery: searchState.hasQuery,
              onChanged: (q) =>
                  ref.read(searchProvider.notifier).onQueryChanged(q),
              onClear: () {
                _controller.clear();
                ref.read(searchProvider.notifier).clearSearch();
              },
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: _buildBody(context, searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchState state) {
    if (!state.hasQuery) {
      return const _IdleState();
    }
    if (state.isSearching) {
      return const _SearchingState();
    }
    if (state.hasError) {
      return _ErrorState(
        onRetry: () => ref
            .read(searchProvider.notifier)
            .onQueryChanged(state.query),
      );
    }
    if (!state.hasResults) {
      return _NoResultsState(query: state.query);
    }
    return _ResultsList(results: state.results);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editorial search bar — replaces Material AppBar entirely
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Back button — same pattern as ShlokListScreen
          _BackIcon(),
          const SizedBox(width: AppSpacing.sm),
          // Text field — editorial styling
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurface,
              ),
              cursorColor: scheme.primary,
              cursorWidth: 1.5,
              decoration: InputDecoration(
                hintText: 'Search verses, translations…',
                hintStyle: AppTypography.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          // Clear icon — visible only when there's a query
          AnimatedOpacity(
            duration: AppAnimations.quick,
            opacity: hasQuery ? 1.0 : 0.0,
            child: GestureDetector(
              onTap: hasQuery ? onClear : null,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Idle state — prompt to type
// ─────────────────────────────────────────────────────────────────────────────

class _IdleState extends StatelessWidget {
  const _IdleState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: AppEdgeInsets.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'खोज',
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.10),
                fontSize: 60,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Search the Gita',
              style: AppTypography.headlineSmall.copyWith(
                color: scheme.onSurface,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Type a word, verse number, or phrase\nto search across all 700 verses.',
              style: AppTypography.caption.copyWith(
                color: scheme.secondary,
                height: 1.8,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Searching — shimmer skeleton, no CircularProgressIndicator
// ─────────────────────────────────────────────────────────────────────────────

class _SearchingState extends StatelessWidget {
  const _SearchingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shimmer = scheme.onSurface.withValues(alpha: 0.06);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: List.generate(
          6,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SectionContainer(
              tier: SurfaceTier.low,
              borderRadius: AppRadius.mdBorder,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: shimmer,
                            borderRadius: AppRadius.smBorder,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 160,
                          height: 12,
                          decoration: BoxDecoration(
                            color: shimmer.withValues(alpha: 0.04),
                            borderRadius: AppRadius.smBorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No results
// ─────────────────────────────────────────────────────────────────────────────

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: AppEdgeInsets.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'शांति',
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.10),
                fontSize: 60,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No verses found',
              style: AppTypography.headlineSmall.copyWith(
                color: scheme.onSurface,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'The Gita holds 700 verses.\nTry a different word or phrase.',
              style: AppTypography.caption.copyWith(
                color: scheme.secondary,
                height: 1.8,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: AppEdgeInsets.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'विराम',
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.10),
                fontSize: 60,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Search paused.',
              style: AppTypography.headlineSmall.copyWith(
                color: scheme.onSurface,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We could not complete the search.\nCheck your connection and try again.',
              style: AppTypography.caption.copyWith(
                color: scheme.secondary,
                height: 1.8,
                letterSpacing: 0.3,
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
    _fade =
        AnimationController(vsync: this, duration: AppAnimations.quick, value: 1.0);
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
      onTapDown: (_) => _fade.animateTo(0.4),
      onTapUp: (_) => _fade.animateTo(1.0),
      onTapCancel: () => _fade.animateTo(1.0),
      child: FadeTransition(
        opacity: _fade,
        child: Text(
          'Try again',
          style: AppTypography.labelLarge
              .copyWith(color: scheme.primary, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results list — verse rows
// ─────────────────────────────────────────────────────────────────────────────

class _ResultsList extends ConsumerWidget {
  const _ResultsList({required this.results});
  final List<Shlok> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rs = ref.watch(readingStylesProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Result count caption
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm,
            ),
            child: Text(
              '${results.length} VERSES FOUND',
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 2.5,
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList.separated(
            itemCount: results.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (ctx, i) =>
                _SearchResultRow(shlok: results[i], rs: rs),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.editorial),
        ),
      ],
    );
  }
}

class _SearchResultRow extends StatefulWidget {
  const _SearchResultRow({required this.shlok, required this.rs});
  final Shlok shlok;
  final ReadingStyles rs;

  @override
  State<_SearchResultRow> createState() => _SearchResultRowState();
}

class _SearchResultRowState extends State<_SearchResultRow>
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final verseLabel =
        '${widget.shlok.chapterId}.${widget.shlok.verseNumber}';

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) {
          _press.reverse();
          context.push(
            '/explore/chapter/${widget.shlok.chapterId}/verse/${widget.shlok.id}',
          );
        },
        onTapCancel: () => _press.reverse(),
        child: SectionContainer(
          tier: SurfaceTier.low,
          borderRadius: AppRadius.mdBorder,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Amber verse number — Inter, never scaled
              SizedBox(
                width: 40,
                child: Text(
                  verseLabel,
                  style: AppTypography.headlineSmall.copyWith(
                    color: scheme.primary,
                    fontSize: 18,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Sanskrit line + translation preview — scaled via ReadingStyles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _firstLine(widget.shlok.sanskritText),
                      style: widget.rs.sanskritSmall.copyWith(
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _firstLine(widget.shlok.translation),
                      style: widget.rs.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: scheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _firstLine(String text) {
    if (text.isEmpty) return '';
    return text.split('\n').first.trim();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Back icon — matches ShlokListScreen pattern exactly
// ─────────────────────────────────────────────────────────────────────────────

class _BackIcon extends StatefulWidget {
  @override
  State<_BackIcon> createState() => _BackIconState();
}

class _BackIconState extends State<_BackIcon>
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
      onTap: () => context.pop(),
      onTapDown: (_) => _fade.animateTo(0.4),
      onTapUp: (_) => _fade.animateTo(1.0),
      onTapCancel: () => _fade.animateTo(1.0),
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
