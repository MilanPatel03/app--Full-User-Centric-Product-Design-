import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../chapters/domain/entities/chapter.dart';
import '../../../chapters/presentation/providers/chapters_state_provider.dart';
import '../../domain/entities/shlok.dart';
import '../providers/shloks_state_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShlokListScreen — Chapter Index View
// ─────────────────────────────────────────────────────────────────────────────

/// Matches the "Chapter 2: Sankhya Yoga" Stitch design.
///
/// ## Layout
/// ```
/// Scaffold:
///   body: CustomScrollView
///     [App bar]       ← Back icon + "Chapter N: Title" + verse count
///     [Section title] ← "Chapter N Index"
///     [Description]   ← Chapter description text
///     [Shlok rows]    ← Compact index list (amber number + Sanskrit line)
///     [Bottom padding]
///   bottomNavigationBar: [Resume Reading bar]  ← sticky bottom CTA
/// ```
class ShlokListScreen extends ConsumerWidget {
  const ShlokListScreen({super.key, required this.chapterId});

  final int chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shloksAsync = ref.watch(shloksByChapterProvider(chapterId));
    final chapterAsync = ref.watch(chapterDetailProvider(chapterId));

    final chapterTitle =
        chapterAsync.valueOrNull?.title ?? 'Chapter $chapterId';
    final titleSanskrit = chapterAsync.valueOrNull?.titleSanskrit ?? '';
    final verseCount = shloksAsync.valueOrNull?.length;
    final description = _descriptionFor(chapterAsync.valueOrNull);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // ── Sticky Resume Reading bar ──────────────────────────────────────
      bottomNavigationBar: _ResumeReadingBar(chapterId: chapterId),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ShlokListAppBar(
              chapterId: chapterId,
              title: chapterTitle,
              titleSanskrit: titleSanskrit,
              verseCount: verseCount,
            ),
          ),

          // ── Section title ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter $chapterId Index',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 26,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      description,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.7,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Verse list — async state ───────────────────────────────────────
          ..._buildVerseSliver(ref, shloksAsync),

          // ── Bottom breathing room ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVerseSliver(
    WidgetRef ref,
    AsyncValue<List<Shlok>> shloksAsync,
  ) {
    return shloksAsync.when(
      loading: () => [const _ShlokListLoadingSliver()],
      error: (error, _) => [
        _ShlokErrorSliver(
          onRetry: () =>
              ref.invalidate(shloksByChapterProvider(chapterId)),
        ),
      ],
      data: (shloks) => [_ShlokIndexList(shloks: shloks)],
    );
  }

  /// Uses domain field if populated, else static map.
  String _descriptionFor(Chapter? chapter) {
    if (chapter == null) return '';
    if (chapter.description != null && chapter.description!.isNotEmpty) {
      return chapter.description!;
    }
    return _kChapterDescriptions[chapter.index] ?? '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar — back + chapter title + verse count
// ─────────────────────────────────────────────────────────────────────────────

class _ShlokListAppBar extends StatelessWidget {
  const _ShlokListAppBar({
    required this.chapterId,
    required this.title,
    required this.titleSanskrit,
    required this.verseCount,
  });

  final int chapterId;
  final String title;
  final String titleSanskrit;
  final int? verseCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.sm, AppSpacing.lg, 0,
        ),
        child: Row(
          children: [
            // Back icon
            _BackIcon(),
            const SizedBox(width: AppSpacing.sm),
            // Chapter title + verse count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter $chapterId: $title',
                    style: AppTypography.titleSmall.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (verseCount != null)
                    Text(
                      '$verseCount VERSES',
                      style: AppTypography.caption.copyWith(
                        color: scheme.secondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact shlok index list
// ─────────────────────────────────────────────────────────────────────────────

class _ShlokIndexList extends StatelessWidget {
  const _ShlokIndexList({required this.shloks});
  final List<Shlok> shloks;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            if (i.isOdd) return const SizedBox(height: AppSpacing.sm);
            final shlok = shloks[i ~/ 2];
            return _ShlokIndexRow(
              shlok: shlok,
              onTap: () => context.push(
                // ✓ Fixed route: /explore/chapter/N/verse/ID
                '/explore/chapter/${shlok.chapterId}/verse/${shlok.id}',
              ),
            );
          },
          childCount: shloks.isEmpty ? 0 : (shloks.length * 2) - 1,
        ),
      ),
    );
  }
}

class _ShlokIndexRow extends StatefulWidget {
  const _ShlokIndexRow({required this.shlok, required this.onTap});
  final Shlok shlok;
  final VoidCallback onTap;

  @override
  State<_ShlokIndexRow> createState() => _ShlokIndexRowState();
}

class _ShlokIndexRowState extends State<_ShlokIndexRow>
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
          widget.onTap();
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
              // ── Amber verse number ──────────────────────────────────
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

              // ── Sanskrit first line + transliteration ───────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sanskrit first line only (truncated)
                    Text(
                      _firstLine(widget.shlok.sanskritText),
                      style: AppTypography.sanskritSmall.copyWith(
                        color: scheme.onSurface,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Translation preview
                    Text(
                      _firstLine(widget.shlok.translation),
                      style: AppTypography.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // ── Bookmark dot ───────────────────────────────────────
              Icon(
                Icons.bookmark_border_rounded,
                size: 16,
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
    final lines = text.split('\n');
    return lines.first.trim();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resume Reading sticky bottom bar
// ─────────────────────────────────────────────────────────────────────────────

class _ResumeReadingBar extends StatelessWidget {
  const _ResumeReadingBar({required this.chapterId});
  final int chapterId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Play indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: scheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Resume label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'RESUME READING',
                      style: AppTypography.caption.copyWith(
                        color: scheme.secondary,
                        letterSpacing: 1.5,
                        fontSize: 9,
                      ),
                    ),
                    Text(
                      'Verse $chapterId.1 — Begin your study',
                      style: AppTypography.bodyMedium.copyWith(
                        color: scheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // CONTINUE amber button
              GestureDetector(
                onTap: () => context.push(
                  '/explore/chapter/$chapterId/verse/BG_${chapterId}_1',
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: AppRadius.fullBorder,
                  ),
                  child: Text(
                    'CONTINUE',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF3A1D00),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer sliver
// ─────────────────────────────────────────────────────────────────────────────

class _ShlokListLoadingSliver extends StatelessWidget {
  const _ShlokListLoadingSliver();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shimmer = scheme.onSurface.withValues(alpha: 0.06);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            if (i.isOdd) return const SizedBox(height: AppSpacing.sm);
            return SectionContainer(
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
            );
          },
          childCount: 11,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error sliver
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
              style: AppTypography.titleLarge.copyWith(color: scheme.onSurface),
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
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Try again',
                style: AppTypography.labelLarge.copyWith(
                  color: scheme.primary,
                  letterSpacing: 0.5,
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
// Back icon
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
// Static description fallback (mirrors chapter_card.dart)
// ─────────────────────────────────────────────────────────────────────────────

const _kChapterDescriptions = <int, String>{
  1: 'The Yoga of Arjuna\'s Dejection. Arjuna faces a moral dilemma on the battlefield of Kurukshetra, overwhelmed by grief at the thought of fighting his own kin.',
  2: 'The Yoga of Knowledge and the path to spiritual awakening. Krishna begins his profound discourse on the nature of the self.',
  3: 'The Yoga of Action. Krishna explains how to perform one\'s duties without attachment to the results, achieving liberation through action.',
  4: 'The Yoga of Wisdom. The history of the Gita is revealed, highlighting the importance of a spiritual teacher.',
  5: 'The Yoga of Renunciation. Krishna reconciles the paths of action and renunciation, explaining that both lead to liberation.',
  6: 'The Yoga of Meditation. The path of meditation is described, guiding the seeker to control the mind and attain the highest state.',
  7: 'Knowledge of the Absolute. Krishna reveals his divine nature and the different ways seekers approach the Supreme.',
  8: 'Attaining the Supreme. The eternal Brahman is explained, along with the two paths taken at the time of death.',
  9: 'The Royal Secret. Krishna reveals the most confidential knowledge — the path of pure devotion.',
  10: 'Divine Glories. Krishna describes his divine manifestations and reveals himself as the source of all existence.',
  11: 'The Universal Form. Arjuna is granted cosmic vision, beholding Krishna\'s universal form encompassing all of creation.',
  12: 'The Path of Devotion. The path of devotion is declared supreme, with Krishna explaining qualities of his beloved devotees.',
  13: 'The Field and the Knower. The distinction between the field and the knower of the field is elucidated.',
  14: 'The Three Modes. The three modes of material nature — goodness, passion, and ignorance — are explained.',
  15: 'The Supreme Person. The supreme secret of the Gita is revealed: Krishna as the highest person.',
  16: 'The Divine and Demoniac. The divine and demoniac natures are contrasted, showing the path to liberation.',
  17: 'The Divisions of Faith. The three divisions of faith, food, sacrifice, and austerity based on the modes of nature.',
  18: 'The Perfection of Renunciation. The final chapter synthesises all teachings with the supreme instruction.',
};
