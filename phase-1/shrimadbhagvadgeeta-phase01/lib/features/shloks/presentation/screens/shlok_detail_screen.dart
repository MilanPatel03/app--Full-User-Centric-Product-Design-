import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
// ShlokDetailScreen — Immersive single-verse experience
// ─────────────────────────────────────────────────────────────────────────────

/// Full editorial reading view for a single verse.
///
/// ## Design North Star
/// "Reading a sacred verse in isolation — focused, calm, immersive."
///
/// ## Layout (CustomScrollView)
/// ```
/// [_VerseHeader]        ← chapter + verse reference label
/// [_VerseSanskriSection]← Sanskrit hero in elevated surface
/// [_VerseTranslation]   ← transliteration (italic, muted) + translation
/// [_CommentarySection]  ← only if shlok.hasCommentary
/// [Bottom breathing]
/// ```
///
/// ## No AppBar — floating overlays:
/// - Top-left: animated back icon (FadeTransition on press)
/// - Top-right: reactive bookmark toggle (AnimatedSwitcher)
class ShlokDetailScreen extends ConsumerWidget {
  const ShlokDetailScreen({super.key, required this.shlokId});

  final String shlokId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shlokAsync = ref.watch(shlokDetailProvider(shlokId));

    return shlokAsync.when(
      // ── Loading ──────────────────────────────────────────────────────────
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

      // ── Error ─────────────────────────────────────────────────────────────
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

      // ── Data ──────────────────────────────────────────────────────────────
      data: (shlok) => EditorialLayout(
        leading: _BackAction(),
        actions: [_BookmarkToggle(shlok: shlok)],
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Verse reference header
            SliverToBoxAdapter(child: _VerseHeader(shlok: shlok)),

            // Sanskrit + transliteration
            SliverToBoxAdapter(child: _VerseSanskritSection(shlok: shlok)),

            // Translation
            SliverToBoxAdapter(child: _VerseTranslation(shlok: shlok)),

            // Commentary — rendered only when available
            if (shlok.hasCommentary)
              SliverToBoxAdapter(
                child: _CommentarySection(commentary: shlok.commentary!),
              ),

            // Bottom breathing room — meditative exit space
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
// Back action — floats top-left via EditorialLayout
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

// ─────────────────────────────────────────────────────────────────────────────
// Bookmark toggle — floats top-right via EditorialLayout
// ─────────────────────────────────────────────────────────────────────────────

/// Reactively watches [isBookmarkedProvider] and toggles on tap.
///
/// Uses [AnimatedSwitcher] + [ValueKey] for a smooth icon crossfade (fade +
/// scale) when the bookmark state changes — 300ms, editorial pace.
///
/// No UUID package needed — [shlok.id] serves as the bookmark's stable ID
/// since each verse can only have one bookmark.
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
              Bookmark(
                id: shlok.id,
                shlokId: shlok.id,
                createdAt: DateTime.now(),
              ),
            );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: AnimatedSwitcher(
          duration: AppAnimations.quick,
          // Crossfade + subtle scale for the icon swap
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Icon(
            // ValueKey drives AnimatedSwitcher to rebuild on state change
            key: ValueKey(isBookmarked),
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
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
// Section: Verse header — chapter + verse label
// ─────────────────────────────────────────────────────────────────────────────

/// Minimal verse reference at the top of the screen.
/// Keeps the editorial focus on the verse content below.
class _VerseHeader extends StatelessWidget {
  const _VerseHeader({required this.shlok});

  final Shlok shlok;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,    // left — aligns with verse content
        AppSpacing.xxl,   // top — breathing room from status bar / back icon
        AppSpacing.xxl,   // right — space for floating bookmark action
        AppSpacing.xl,    // bottom — separates from Sanskrit section
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHAPTER ${shlok.chapterId}',
            style: AppTypography.caption.copyWith(
              color: scheme.secondary,
              letterSpacing: 2.5,
            ),
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
// Section: Sanskrit text — the verse hero
// ─────────────────────────────────────────────────────────────────────────────

/// Sanskrit text inside a [SurfaceTier.high] container — the highest tonal
/// surface — giving the verse a soft visual "altar" to rest upon.
///
/// Transliteration flows directly below without a container, keeping it
/// subordinate: supportive, not competing.
class _VerseSanskritSection extends StatelessWidget {
  const _VerseSanskritSection({required this.shlok});

  final Shlok shlok;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sanskrit text — elevated "altar" surface
          SectionContainer(
            tier: SurfaceTier.high,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,  // 32px — generous horizontal breathing
              vertical: AppSpacing.xxl,   // 48px — generous vertical breathing
            ),
            borderRadius: AppRadius.lgBorder,
            child: Text(
              shlok.sanskritText,
              // Larger than card: this is the centrepiece of the whole screen
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface,
                height: 2.3, // Extra line-height for Devanagari matras and vowel diacritics
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Transliteration — italic, muted, floats below with no container
          if (shlok.transliteration.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              shlok.transliteration,
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
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
// Section: Translation — reading text
// ─────────────────────────────────────────────────────────────────────────────

/// Translation section with a tracked uppercase section label.
/// Left-aligned — translations read left-to-right in English, so
/// centering would slow reading speed and break editorial rhythm.
class _VerseTranslation extends StatelessWidget {
  const _VerseTranslation({required this.shlok});

  final Shlok shlok;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,    // left
        AppSpacing.editorial, // top — generous space after Sanskrit block
        AppSpacing.lg,    // right
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text(
            'TRANSLATION',
            style: AppTypography.caption.copyWith(
              color: scheme.secondary,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Translation body — primary reading text
          Text(
            shlok.translation,
            style: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurface,
              height: 1.9, // Generous — each sentence deserves contemplation
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section: Commentary — conditional, softly separated
// ─────────────────────────────────────────────────────────────────────────────

/// Rendered only when [Shlok.hasCommentary] is true.
///
/// A dim "· · ·" mark separates commentary from translation —
/// editorial convention for a section break (no hard border).
/// Commentary text is slightly dimmer than translation: it is the
/// explanation, not the primary sacred text.
class _CommentarySection extends StatelessWidget {
  const _CommentarySection({required this.commentary});

  final String commentary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl, // top — clear separation from translation
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dim section break — NOT a line, just a spaced mark
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

          // Section label
          Text(
            'COMMENTARY',
            style: AppTypography.caption.copyWith(
              color: scheme.secondary,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Commentary — slightly dimmer, same bodyLarge for readability
          Text(
            commentary,
            style: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.82),
              height: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading state — structural skeleton matching final layout
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton mirrors the exact structure of the loaded state —
/// no layout shift occurs when data arrives.
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
          // Header skeleton — matches _VerseHeader
          const SizedBox(height: AppSpacing.xxl),
          _Shimmer(width: 80, height: 10, color: lo),
          const SizedBox(height: AppSpacing.xs),
          _Shimmer(width: 130, height: 22, color: hi),
          const SizedBox(height: AppSpacing.xl),

          // Sanskrit container skeleton — matches _VerseSanskritSection
          SectionContainer(
            tier: SurfaceTier.high,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            borderRadius: AppRadius.lgBorder,
            child: Column(
              children: [
                _Shimmer(width: 220, height: 26, color: hi),
                const SizedBox(height: AppSpacing.md),
                _Shimmer(width: 200, height: 26, color: hi),
                const SizedBox(height: AppSpacing.md),
                _Shimmer(width: 180, height: 26, color: hi),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Transliteration skeleton
          Center(child: _Shimmer(width: 210, height: 14, color: lo)),
          const SizedBox(height: AppSpacing.xs),
          Center(child: _Shimmer(width: 170, height: 14, color: lo)),
          const SizedBox(height: AppSpacing.editorial),

          // "TRANSLATION" label skeleton
          _Shimmer(width: 80, height: 10, color: lo),
          const SizedBox(height: AppSpacing.md),

          // Translation paragraph skeleton — 3 lines
          _Shimmer(width: double.infinity, height: 16, color: hi),
          const SizedBox(height: AppSpacing.xs),
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

// ─────────────────────────────────────────────────────────────────────────────
// Error state — editorial calm with retry
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
            // Sanskrit anchor word: "योग" — Yoga, the unifying principle
            Text(
              'योग',
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.10),
                fontSize: 60,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Verse unavailable.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We could not load this verse.\nPlease go back and try again.',
              style: AppTypography.caption.copyWith(
                color: scheme.secondary,
                height: 1.8,
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

// ─────────────────────────────────────────────────────────────────────────────
// Retry label — fade on press, no button chrome
// ─────────────────────────────────────────────────────────────────────────────

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
      onTapDown: (_) => _fade.animateTo(0.4),
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
