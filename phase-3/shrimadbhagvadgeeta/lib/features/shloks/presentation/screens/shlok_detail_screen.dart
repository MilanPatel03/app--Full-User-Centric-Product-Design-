import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/settings/settings_provider.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/editorial_layout.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/presentation/providers/bookmarks_state_provider.dart';
import '../../domain/entities/shlok.dart';
import '../providers/shloks_state_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShlokDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

class ShlokDetailScreen extends ConsumerWidget {
  const ShlokDetailScreen({super.key, required this.shlokId});

  final String shlokId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shlokAsync = ref.watch(shlokDetailProvider(shlokId));
    // Font scale — only affects NotoSerif / NotoSerifDevanagari reading text.
    final fontScale = ref.watch(fontScaleProvider);

    return shlokAsync.when(
      loading: () => EditorialLayout(
        leading: _BackAction(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _DetailLoadingBody()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.editorial),
            ),
          ],
        ),
      ),
      error: (error, _) => EditorialLayout(
        leading: _BackAction(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _DetailErrorSliver(
              onRetry: () => ref.invalidate(shlokDetailProvider(shlokId)),
            ),
          ],
        ),
      ),
      data: (shlok) => EditorialLayout(
        leading: _BackAction(),
        actions: [_BookmarkToggle(shlok: shlok)],
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _VerseHeader(shlok: shlok)),
            SliverToBoxAdapter(
              child: _VerseSanskritSection(shlok: shlok, fontScale: fontScale),
            ),
            SliverToBoxAdapter(
              child: _VerseTranslation(shlok: shlok, fontScale: fontScale),
            ),
            if (shlok.hasCommentary)
              SliverToBoxAdapter(
                child: _CommentarySection(
                  commentary: shlok.commentary!,
                  fontScale: fontScale,
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.editorial),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Back action
// ─────────────────────────────────────────────────────────────────────────────

class _BackAction extends StatefulWidget {
  @override
  State<_BackAction> createState() => _BackActionState();
}

class _BackActionState extends State<_BackAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
        vsync: this, duration: AppAnimations.quick, value: 1.0);
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
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: scheme.onSurface.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bookmark toggle
// ─────────────────────────────────────────────────────────────────────────────

class _BookmarkToggle extends ConsumerWidget {
  const _BookmarkToggle({required this.shlok});
  final Shlok shlok;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(isBookmarkedProvider(shlok.id));
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        ref.read(bookmarkActionsProvider.notifier).toggleBookmark(
          Bookmark(id: shlok.id, shlokId: shlok.id, createdAt: DateTime.now()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: AnimatedSwitcher(
          duration: AppAnimations.quick,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: anim, child: child),
          ),
          child: Icon(
            key: ValueKey(isBookmarked),
            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            size: 22,
            color: isBookmarked
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verse header
// ─────────────────────────────────────────────────────────────────────────────

class _VerseHeader extends StatelessWidget {
  const _VerseHeader({required this.shlok});
  final Shlok shlok;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHAPTER ${shlok.chapterId}',
            style: AppTypography.caption.copyWith(
                color: scheme.secondary, letterSpacing: 2.5),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Verse ${shlok.chapterId}.${shlok.verseNumber}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sanskrit section — fontScale applied
// ─────────────────────────────────────────────────────────────────────────────

class _VerseSanskritSection extends StatelessWidget {
  const _VerseSanskritSection({
    required this.shlok,
    required this.fontScale,
  });

  final Shlok shlok;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionContainer(
            tier: SurfaceTier.high,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            borderRadius: AppRadius.lgBorder,
            child: Text(
              shlok.sanskritText,
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface,
                // fontScale applied — base 28px × scale
                fontSize: 28 * fontScale,
                height: 2.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (shlok.transliteration.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              shlok.transliteration,
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                // Transliteration is NotoSerif — scales with reading text
                fontSize: 14 * fontScale,
                height: 1.9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Translation — fontScale applied
// ─────────────────────────────────────────────────────────────────────────────

class _VerseTranslation extends StatelessWidget {
  const _VerseTranslation({required this.shlok, required this.fontScale});
  final Shlok shlok;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.editorial, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRANSLATION',
            // Inter — never scales
            style: AppTypography.caption
                .copyWith(color: scheme.secondary, letterSpacing: 2.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            shlok.translation,
            style: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurface,
              // NotoSerif body — scales
              fontSize: 16 * fontScale,
              height: 1.9,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Commentary — fontScale applied
// ─────────────────────────────────────────────────────────────────────────────

class _CommentarySection extends StatelessWidget {
  const _CommentarySection({
    required this.commentary,
    required this.fontScale,
  });
  final String commentary;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '· · ·',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.18),
                fontSize: 10,
                letterSpacing: 8,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'COMMENTARY',
            style: AppTypography.caption
                .copyWith(color: scheme.secondary, letterSpacing: 2.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            commentary,
            style: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.82),
              // NotoSerif body — scales
              fontSize: 16 * fontScale,
              height: 2.0,
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

class _DetailLoadingBody extends StatelessWidget {
  const _DetailLoadingBody();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hi = scheme.onSurface.withValues(alpha: 0.08);
    final lo = scheme.onSurface.withValues(alpha: 0.04);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          _Shimmer(width: 80, height: 10, color: lo),
          const SizedBox(height: AppSpacing.xs),
          _Shimmer(width: 130, height: 22, color: hi),
          const SizedBox(height: AppSpacing.xl),
          SectionContainer(
            tier: SurfaceTier.high,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
            borderRadius: AppRadius.lgBorder,
            child: Column(children: [
              _Shimmer(width: 220, height: 26, color: hi),
              const SizedBox(height: AppSpacing.md),
              _Shimmer(width: 200, height: 26, color: hi),
              const SizedBox(height: AppSpacing.md),
              _Shimmer(width: 180, height: 26, color: hi),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(child: _Shimmer(width: 210, height: 14, color: lo)),
          const SizedBox(height: AppSpacing.xs),
          Center(child: _Shimmer(width: 170, height: 14, color: lo)),
          const SizedBox(height: AppSpacing.editorial),
          _Shimmer(width: 80, height: 10, color: lo),
          const SizedBox(height: AppSpacing.md),
          _Shimmer(width: double.infinity, height: 16, color: hi),
          const SizedBox(height: AppSpacing.xs),
          _Shimmer(width: double.infinity, height: 16, color: hi),
          const SizedBox(height: AppSpacing.xs),
          _Shimmer(width: 180, height: 16, color: hi),
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

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _DetailErrorSliver extends StatelessWidget {
  const _DetailErrorSliver({required this.onRetry});
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
              'योग',
              style: AppTypography.sanskritDisplay.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.10),
                  fontSize: 60,
                  height: 1.0),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Verse unavailable.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We could not load this verse.\nPlease go back and try again.',
              style: AppTypography.caption
                  .copyWith(color: scheme.secondary, height: 1.8),
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
        vsync: this, duration: AppAnimations.quick, value: 1.0);
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