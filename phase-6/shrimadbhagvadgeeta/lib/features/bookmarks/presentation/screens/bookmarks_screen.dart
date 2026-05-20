import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collections_state_provider.dart';
import '../../domain/entities/bookmark.dart';
import '../providers/bookmarks_state_provider.dart';
import '../widgets/bookmark_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Library Screen — Tab 2
// ─────────────────────────────────────────────────────────────────────────────

/// Sacred Editorial Library — matches the "My Library" Stitch design.
///
/// ## Layout (vertical scroll)
/// ```
/// [Header]              ← "PERSONAL ARCHIVES" + "My Library" + "+ New Collection"
/// [Collections]         ← Full-width cards with icon, name, count, avatar stack
/// [Divider — bookmark icon]
/// [Curated Journeys]    ← Static section labels (tap → snackbar "Coming soon")
/// ```
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final collectionsAsync = ref.watch(collectionsStreamProvider);
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Library header ─────────────────────────────────────────────────
          SliverToBoxAdapter(child: _LibraryHeader()),

          // ── My Collections label ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md,
              ),
              child: _SectionLabel('MY COLLECTIONS'),
            ),
          ),

          // ── Collections list ───────────────────────────────────────────────
          _buildCollectionSliver(context, ref, collectionsAsync),

          // ── Saved Verses (Bookmarks) label ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md,
              ),
              child: _SectionLabel('SAVED VERSES'),
            ),
          ),

          // ── Bookmarks list ─────────────────────────────────────────────────
          _buildBookmarkSliver(context, ref, bookmarksAsync),

          // ── Ornamental divider ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Icon(
                  Icons.bookmark_border_rounded,
                  size: 20,
                  color: scheme.onSurface.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),

          // ── Curated Journeys heading ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg,
              ),
              child: Text(
                'Curated Journeys',
                style: AppTypography.headlineSmall.copyWith(
                  color: scheme.onSurface,
                  fontStyle: FontStyle.italic,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // ── Curated journey items ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _CuratedJourneys(),
          ),

          // ── Bottom breathing room ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionSliver(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Collection>> collectionsAsync,
  ) {
    return collectionsAsync.when(
      loading: () => SliverToBoxAdapter(child: _LoadingShimmer()),
      error: (e, _) => SliverToBoxAdapter(
        child: _ErrorState(message: e.toString()),
      ),
      data: (collections) => collections.isEmpty
          ? SliverToBoxAdapter(child: _CollectionsEmptyState())
          : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i.isOdd)
                      return const SizedBox(height: AppSpacing.md);
                    final col = collections[i ~/ 2];
                    return _CollectionFullCard(collection: col);
                  },
                  childCount: collections.isEmpty
                      ? 0
                      : (collections.length * 2) - 1,
                ),
              ),
            ),
    );
  }

  Widget _buildBookmarkSliver(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Bookmark>> bookmarksAsync,
  ) {
    return bookmarksAsync.when(
      loading: () => SliverToBoxAdapter(child: _LoadingShimmer()),
      error: (e, _) => SliverToBoxAdapter(
        child: _ErrorState(message: e.toString()),
      ),
      data: (bookmarks) => bookmarks.isEmpty
          ? SliverToBoxAdapter(child: _BookmarksEmptyState())
          : SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList.separated(
                itemCount: bookmarks.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (ctx, index) {
                  final bookmark = bookmarks[index];
                  final shlokParts = bookmark.shlokId.split('_');
                  final chapterId = shlokParts.length >= 2
                      ? int.tryParse(shlokParts[1]) ?? 1
                      : 1;
                  return BookmarkCard(
                    bookmark: bookmark,
                    onTap: () => context.push(
                      '/explore/chapter/$chapterId/verse/${bookmark.shlokId}',
                    ),
                    onRemove: () => ref
                        .read(bookmarkActionsProvider.notifier)
                        .toggleBookmark(bookmark),
                  );
                },
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Library header — "PERSONAL ARCHIVES" / "My Library" / "+ New Collection"
// ─────────────────────────────────────────────────────────────────────────────

class _LibraryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left: eyebrow + large title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERSONAL ARCHIVES',
                    style: AppTypography.caption.copyWith(
                      color: scheme.secondary,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'My\nLibrary',
                    style: AppTypography.headlineMedium.copyWith(
                      color: scheme.onSurface,
                      fontSize: 36,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            // Right: + New Collection amber button
            _NewCollectionButton(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// + New Collection button
// ─────────────────────────────────────────────────────────────────────────────

class _NewCollectionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        // TODO: show create-collection bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Create collection — coming soon.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            backgroundColor: scheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              size: 14,
              color: AppColors.onPrimary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'New Collection',
              style: AppTypography.caption.copyWith(
                color: AppColors.onPrimary,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collection full-width card
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionFullCard extends StatefulWidget {
  const _CollectionFullCard({required this.collection});
  final Collection collection;

  @override
  State<_CollectionFullCard> createState() => _CollectionFullCardState();
}

class _CollectionFullCardState extends State<_CollectionFullCard>
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

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) {
          _press.reverse();
          context.push('/library/collections');
        },
        onTapCancel: () => _press.reverse(),
        child: SectionContainer(
          tier: SurfaceTier.low,
          borderRadius: AppRadius.lgBorder,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon in tinted square ──────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.smBorder,
                ),
                child: Icon(
                  Icons.collections_bookmark_rounded,
                  size: 20,
                  color: scheme.secondary,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Collection name ────────────────────────────────────
              Text(
                widget.collection.name,
                style: AppTypography.titleSmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Verse count ────────────────────────────────────────
              Text(
                'VERSES SAVED',
                style: AppTypography.caption.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Avatar stack placeholder ───────────────────────────
              // Item count requires a separate CollectionItem query.
              // Shown as placeholder (0) until wired in a future step.
              _AvatarStack(count: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative avatar stack — shows placeholder circles + overflow count.
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shown = count.clamp(0, 3);
    final overflow = (count - shown).clamp(0, 99);

    if (count == 0) {
      return Text(
        'No verses saved yet.',
        style: AppTypography.caption.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    return Row(
      children: [
        // Stacked placeholder circles
        SizedBox(
          height: 24,
          width: (shown * 18.0) + 8,
          child: Stack(
            children: List.generate(shown, (i) {
              return Positioned(
                left: i * 18.0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerHighest,
                    border: Border.all(
                      color: scheme.surface,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.auto_stories_outlined,
                    size: 10,
                    color: scheme.secondary,
                  ),
                ),
              );
            }),
          ),
        ),
        if (overflow > 0) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '+$overflow',
            style: AppTypography.caption.copyWith(
              color: scheme.secondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Curated Journeys — static, non-functional (Coming Soon)
// ─────────────────────────────────────────────────────────────────────────────

class _CuratedJourneys extends StatelessWidget {
  static const _journeys = [
    'PATH OF ACTION',
    'SUPREME DEVOTION',
    'ETERNAL WISDOM',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _journeys
          .map((j) => _JourneyRow(label: j))
          .toList(),
    );
  }
}

class _JourneyRow extends StatefulWidget {
  const _JourneyRow({required this.label});
  final String label;

  @override
  State<_JourneyRow> createState() => _JourneyRowState();
}

class _JourneyRowState extends State<_JourneyRow>
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

  void _onTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coming soon',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.fullBorder,
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _fade.animateTo(0.4),
      onTapUp: (_) {
        _fade.animateTo(1.0);
        _onTap();
      },
      onTapCancel: () => _fade.animateTo(1.0),
      behavior: HitTestBehavior.opaque,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTypography.caption.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 3.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty states
// ─────────────────────────────────────────────────────────────────────────────

class _BookmarksEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'चिह्न नहीं',
            style: AppTypography.sanskritBody.copyWith(
              color: scheme.secondary.withValues(alpha: 0.5),
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Saved Verses',
            style: AppTypography.headlineSmall.copyWith(
              color: scheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap the bookmark icon while reading\na verse to save it here.',
            style: AppTypography.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () => context.go('/explore'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.fullBorder,
              ),
              child: Text(
                'BEGIN READING',
                style: AppTypography.caption.copyWith(
                  color: scheme.primary,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'संग्रह',
            style: AppTypography.sanskritBody.copyWith(
              color: scheme.secondary.withValues(alpha: 0.5),
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Collections Yet',
            style: AppTypography.headlineSmall.copyWith(
              color: scheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create a collection to curate\nverses along a theme.',
            style: AppTypography.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SectionContainer(
              tier: SurfaceTier.low,
              borderRadius: AppRadius.lgBorder,
              height: 120,
              child: const SizedBox(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'क्षमा करें',
            style: AppTypography.sanskritBody.copyWith(
              color: scheme.error.withValues(alpha: 0.6),
              fontSize: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Something went wrong.',
            style: AppTypography.titleSmall.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: AppTypography.caption.copyWith(
        color: scheme.secondary,
        letterSpacing: 2.5,
      ),
    );
  }
}