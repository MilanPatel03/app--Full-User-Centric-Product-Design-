import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/editorial_header.dart';
import '../../../../core/theme/widgets/editorial_layout.dart';
import '../../../chapters/presentation/providers/chapters_state_provider.dart';
import '../../domain/entities/shlok.dart';
import '../providers/shloks_state_provider.dart';
import '../widgets/shlok_list_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShlokListScreen — All verses for a single chapter
// ─────────────────────────────────────────────────────────────────────────────

/// Displays the full verse list for a given chapter.
///
/// ## Layout
/// ```
/// [EditorialHeader]   ← chapter Sanskrit title + English name + verse count
/// [ShlokListView]     ← verse cards (data) | skeleton (loading) | error
/// [Bottom breathing]
/// ```
///
/// ## State
/// - Primary: [shloksByChapterProvider] for the verse list
/// - Secondary: [chapterDetailProvider] for the header title (optional enrichment)
///
/// Both load from Hive cache-first. The header degrades gracefully:
/// if chapter data isn't yet available it shows a Sanskrit fallback.
class ShlokListScreen extends ConsumerWidget {
  const ShlokListScreen({super.key, required this.chapterId});

  final int chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shloksAsync = ref.watch(shloksByChapterProvider(chapterId));
    final chapterAsync = ref.watch(chapterDetailProvider(chapterId));

    // Derive header content — falls back gracefully during loading
    final titleSanskrit = chapterAsync.valueOrNull?.titleSanskrit ?? '';
    final chapterTitle =
        chapterAsync.valueOrNull?.title ?? 'Chapter $chapterId';
    final verseCount = shloksAsync.valueOrNull?.length;

    return EditorialLayout(
      leading: _BackIcon(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Chapter header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: EditorialHeader(
              // "अध्याय N" = "Chapter N" in Sanskrit — always present
              eyebrow: 'अध्याय $chapterId',
              // Sanskrit chapter title if loaded, else empty (header skips it)
              titleSanskrit: titleSanskrit.isNotEmpty
                  ? titleSanskrit
                  : 'अध्याय $chapterId',
              subtitle: chapterTitle,
              footnote: verseCount != null ? '$verseCount verses' : null,
              showOmMark: false, // OM mark is exclusive to the home screen
            ),
          ),

          // ── Verse list — async state ───────────────────────────────────
          ..._buildVerseSliver(ref, shloksAsync),

          // ── Bottom breathing room ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate sliver(s) for the current async state.
  List<Widget> _buildVerseSliver(
    WidgetRef ref,
    AsyncValue<List<Shlok>> shloksAsync,
  ) {
    return shloksAsync.when(
      loading: () => [const ShlokLoadingSliver(count: 3)],
      error: (error, _) => [
        _ShlokErrorSliver(
          onRetry: () => ref.invalidate(shloksByChapterProvider(chapterId)),
        ),
      ],
      data: (shloks) => [ShlokListView(shloks: shloks)],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Back navigation icon — no AppBar, floats top-left
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

// ─────────────────────────────────────────────────────────────────────────────
// Error state — editorial calm
// ─────────────────────────────────────────────────────────────────────────────

class _ShlokErrorSliver extends StatelessWidget {
  const _ShlokErrorSliver({required this.onRetry});

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
            // Dim Sanskrit anchor word: "विराम" = pause / rest
            Text(
              'विराम',
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.10),
                fontSize: 52,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'The verses are resting.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We could not load the verses for this chapter.\nPlease try again.',
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

// ─────────────────────────────────────────────────────────────────────────────
// Retry label — fade animation on press
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
