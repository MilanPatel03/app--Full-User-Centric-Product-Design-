import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../collections/presentation/providers/collections_state_provider.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../domain/entities/bookmark.dart';
import '../providers/bookmarks_state_provider.dart';
import '../widgets/bookmark_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Library Screen — Tab 2
// ─────────────────────────────────────────────────────────────────────────────

/// Combined Bookmarks + Collections as a unified Library tab.
///
/// ## Design (Sacred Editorial)
/// - NO AppBar, NO back button (tab root)
/// - Editorial header: "पुस्तकालय / Your Library"
/// - Segmented pill selector: BOOKMARKS | COLLECTIONS
/// - Reactive lists from Hive streams
/// - Editorial empty states (not generic icons)
///
/// ## Tab State
/// Managed locally with [_LibraryTab] enum — no persistence needed.
class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

enum _LibraryTab { bookmarks, collections }

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  _LibraryTab _activeTab = _LibraryTab.bookmarks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);
    final collectionsAsync = ref.watch(collectionsStreamProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Library header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _LibraryHeader(),
          ),

          // ── Segment selector ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: _TabPillSelector(
                activeTab: _activeTab,
                onChanged: (tab) => setState(() => _activeTab = tab),
                bookmarkCount:
                    bookmarksAsync.valueOrNull?.length ?? 0,
                collectionCount:
                    collectionsAsync.valueOrNull?.length ?? 0,
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          if (_activeTab == _LibraryTab.bookmarks)
            ..._buildBookmarkContent(bookmarksAsync)
          else
            ..._buildCollectionContent(collectionsAsync),

          // ── Bottom breathing room ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBookmarkContent(
      AsyncValue<List<Bookmark>> bookmarksAsync) {
    return [
      bookmarksAsync.when(
        loading: () => SliverFillRemaining(
          child: _LoadingShimmer(),
        ),
        error: (e, _) => SliverFillRemaining(
          child: _ErrorState(message: e.toString()),
        ),
        data: (bookmarks) => bookmarks.isEmpty
            ? SliverFillRemaining(
                child: _BookmarksEmptyState(),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                sliver: SliverList.separated(
                  itemCount: bookmarks.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
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
      ),
    ];
  }

  List<Widget> _buildCollectionContent(
      AsyncValue<List<Collection>> collectionsAsync) {
    return [
      // Add collection button
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
          ),
          child: _NewCollectionButton(),
        ),
      ),

      collectionsAsync.when(
        loading: () => SliverFillRemaining(
          child: _LoadingShimmer(),
        ),
        error: (e, _) => SliverFillRemaining(
          child: _ErrorState(message: e.toString()),
        ),
        data: (collections) => collections.isEmpty
            ? SliverFillRemaining(
                child: _CollectionsEmptyState(),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.4,
                  children: collections
                      .map((c) => _CollectionGridCard(collection: c))
                      .toList(),
                ),
              ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Library header
// ─────────────────────────────────────────────────────────────────────────────

class _LibraryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ॐ',
              style: AppTypography.sanskritBody.copyWith(
                fontSize: 18,
                color: scheme.primary.withValues(alpha: 0.4),
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'पुस्तकालय',
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your Library',
              style: AppTypography.headlineMedium.copyWith(
                color: scheme.onSurface,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab pill selector
// ─────────────────────────────────────────────────────────────────────────────

class _TabPillSelector extends StatelessWidget {
  const _TabPillSelector({
    required this.activeTab,
    required this.onChanged,
    required this.bookmarkCount,
    required this.collectionCount,
  });

  final _LibraryTab activeTab;
  final ValueChanged<_LibraryTab> onChanged;
  final int bookmarkCount;
  final int collectionCount;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      tier: SurfaceTier.low,
      borderRadius: AppRadius.fullBorder,
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _PillOption(
            label: 'BOOKMARKS',
            count: bookmarkCount,
            isActive: activeTab == _LibraryTab.bookmarks,
            onTap: () => onChanged(_LibraryTab.bookmarks),
          ),
          _PillOption(
            label: 'COLLECTIONS',
            count: collectionCount,
            isActive: activeTab == _LibraryTab.collections,
            onTap: () => onChanged(_LibraryTab.collections),
          ),
        ],
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  const _PillOption({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppAnimations.quick,
          curve: AppAnimations.defaultCurve,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: isActive
                ? scheme.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: AppRadius.fullBorder,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: AppAnimations.quick,
                style: AppTypography.caption.copyWith(
                  color: isActive
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(label),
              ),
              if (count > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                AnimatedContainer(
                  duration: AppAnimations.quick,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? scheme.primary.withValues(alpha: 0.15)
                        : scheme.onSurfaceVariant.withValues(alpha: 0.08),
                    borderRadius: AppRadius.fullBorder,
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.caption.copyWith(
                      color: isActive
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontSize: 9,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New collection button
// ─────────────────────────────────────────────────────────────────────────────

class _NewCollectionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        // TODO: show create-collection bottom sheet
      },
      child: SectionContainer(
        tier: SurfaceTier.high,
        borderRadius: AppRadius.mdBorder,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'NEW COLLECTION',
              style: AppTypography.caption.copyWith(
                color: scheme.primary,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collection grid card
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionGridCard extends StatefulWidget {
  const _CollectionGridCard({required this.collection});
  final Collection collection;

  @override
  State<_CollectionGridCard> createState() => _CollectionGridCardState();
}

class _CollectionGridCardState extends State<_CollectionGridCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      value: 1.0,
    );
    _anim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scale, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _scale.forward(),
      onTapUp: (_) {
        _scale.reverse();
        context.push('/library/collections');
      },
      onTapCancel: () => _scale.reverse(),
      child: ScaleTransition(
        scale: _anim,
        child: SectionContainer(
          tier: SurfaceTier.high,
          borderRadius: AppRadius.lgBorder,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.folder_rounded,
                size: 20,
                color: scheme.secondary,
              ),
              const Spacer(),
              Text(
                widget.collection.name,
                style: AppTypography.titleSmall.copyWith(
                  color: scheme.onSurface,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.editorial),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'चिह्न नहीं',
              style: AppTypography.sanskritBody.copyWith(
                color: scheme.secondary.withValues(alpha: 0.5),
                fontSize: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Saved Verses',
              style: AppTypography.headlineSmall.copyWith(
                color: scheme.onSurface,
                fontSize: 20,
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
            const SizedBox(height: AppSpacing.xl),
            _EmptyStateAction(
              label: 'BEGIN READING',
              onTap: () => context.go('/explore'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.editorial),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'संग्रह',
              style: AppTypography.sanskritBody.copyWith(
                color: scheme.secondary.withValues(alpha: 0.5),
                fontSize: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Collections Yet',
              style: AppTypography.headlineSmall.copyWith(
                color: scheme.onSurface,
                fontSize: 20,
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
      ),
    );
  }
}

class _EmptyStateAction extends StatelessWidget {
  const _EmptyStateAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.12),
          borderRadius: AppRadius.fullBorder,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: scheme.primary,
            letterSpacing: 2.0,
          ),
        ),
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
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SectionContainer(
              tier: SurfaceTier.high,
              borderRadius: AppRadius.lgBorder,
              height: 88,
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.editorial),
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
      ),
    );
  }
}
