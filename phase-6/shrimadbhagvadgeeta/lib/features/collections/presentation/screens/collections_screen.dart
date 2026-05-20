import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/editorial_layout.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../providers/collections_state_provider.dart';
import '../../domain/entities/collection.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CollectionsScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Deep-linked collection browser — pushed from Library (/library/collections).
///
/// ## Design
/// - EditorialLayout with back button (no AppBar)
/// - Editorial header: "संग्रह / Collections"
/// - Grid of collection cards (2 columns)
/// - Floating "+" bottom-right for new collection
/// - Editorial empty state
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsStreamProvider);

    return EditorialLayout(
      leading: _BackButton(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _CollectionsHeader(),
          ),

          // ── Content ───────────────────────────────────────────────────────
          collectionsAsync.when(
            loading: () => SliverFillRemaining(
              child: _LoadingShimmer(),
            ),
            error: (e, _) => SliverFillRemaining(
              child: _ErrorState(),
            ),
            data: (collections) => collections.isEmpty
                ? SliverFillRemaining(
              child: _EmptyState(),
            )
                : SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.3,
                children: collections
                    .map((c) => _CollectionCard(collection: c))
                    .toList(),
              ),
            ),
          ),

          // ── Bottom safe space ─────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.xl,
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
            'संग्रह',
            style: AppTypography.sanskritDisplay.copyWith(
              color: scheme.onSurface,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Collections',
            style: AppTypography.headlineMedium.copyWith(
              color: scheme.onSurface,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Curated verse collections',
            style: AppTypography.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collection card
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionCard extends StatefulWidget {
  const _CollectionCard({required this.collection});
  final Collection collection;

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard>
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
      onTapUp: (_) => _scale.reverse(),
      onTapCancel: () => _scale.reverse(),
      child: ScaleTransition(
        scale: _anim,
        child: SectionContainer(
          tier: SurfaceTier.high,
          borderRadius: AppRadius.lgBorder,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.folder_rounded,
                size: 24,
                color: scheme.secondary,
              ),
              const Spacer(),
              Text(
                widget.collection.name,
                style: AppTypography.titleSmall.copyWith(
                  color: scheme.onSurface,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatDate(widget.collection.createdAt),
                style: AppTypography.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Back button
// ─────────────────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.pop(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
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
                color: scheme.secondary.withValues(alpha: 0.4),
                fontSize: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Collections',
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

class _LoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.3,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          4,
              (_) => SectionContainer(
            tier: SurfaceTier.high,
            borderRadius: AppRadius.lgBorder,
            child: const SizedBox(),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'क्षमा करें',
        style: AppTypography.sanskritBody.copyWith(
          color: scheme.error.withValues(alpha: 0.6),
          fontSize: 24,
        ),
      ),
    );
  }
}