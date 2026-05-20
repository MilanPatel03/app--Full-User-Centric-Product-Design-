import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../chapters/domain/entities/chapter.dart';
import '../providers/chapter_progress_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChapterCard
// ─────────────────────────────────────────────────────────────────────────────

/// Sacred Editorial — Chapter List Card.
///
/// Matches the "The 18 Chapters" Stitch design:
///   - Left accent line (2px saffron) for active/in-progress chapters
///   - Chapter number (large, dim)
///   - Sanskrit title + English yogic subtitle + verse count
///   - Status badge (Completed / In Progress / Not Started)
///   - Description text from [Chapter.description] or static fallback
///   - Press scale: 1.0 → 0.98 over 300ms easeOutCubic
class ChapterCard extends ConsumerStatefulWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
  });

  final Chapter chapter;
  final VoidCallback onTap;

  @override
  ConsumerState<ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends ConsumerState<ChapterCard>
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

  void _onTapDown(TapDownDetails _) => _press.forward();

  void _onTapUp(TapUpDetails _) {
    _press.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final progress =
        ref.watch(chapterProgressProvider(widget.chapter.index));

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SectionContainer(
          tier: SurfaceTier.low,
          borderRadius: AppRadius.mdBorder,
          child: ClipRRect(
            borderRadius: AppRadius.mdBorder,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Left accent line — only for active chapters ──────
                  AnimatedContainer(
                    duration: AppAnimations.quick,
                    width: progress.isNotStarted ? 0 : 2.5,
                    color: progress.isCompleted
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                  // ── Card content ──────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: _CardContent(
                        chapter: widget.chapter,
                        progress: progress,
                      ),
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
// Card content
// ─────────────────────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.chapter,
    required this.progress,
  });

  final Chapter chapter;
  final ChapterProgress progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final description =
        chapter.description ?? _kChapterDescriptions[chapter.index] ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Chapter number — large, dim ────────────────────────────────
        SizedBox(
          width: 48,
          child: Text(
            chapter.index.toString().padLeft(2, '0'),
            style: AppTypography.displayLarge.copyWith(
              fontSize: 36,
              color: scheme.onSurface.withValues(alpha: 0.15),
              height: 1.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // ── Chapter info column ────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Sanskrit title + Status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sanskrit + English title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (chapter.titleSanskrit.isNotEmpty)
                          Text(
                            chapter.titleSanskrit.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: scheme.secondary,
                              letterSpacing: 1.5,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Status badge
                  _StatusBadge(
                    progress: progress,
                    verseCount: chapter.verseCount,
                  ),
                ],
              ),

              // Description — uses domain field or static fallback
              if (description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                    fontSize: 13,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.progress,
    required this.verseCount,
  });

  final ChapterProgress progress;
  final int verseCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (badgeText, badgeColor) = switch (progress.status) {
      ChapterStatus.completed => ('Completed', scheme.secondary),
      ChapterStatus.inProgress => (
          'In Progress\n(${(progress.fraction * 100).round()}%)',
          scheme.primary,
        ),
      ChapterStatus.notStarted => ('Not Started', scheme.onSurfaceVariant),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          badgeText,
          style: AppTypography.caption.copyWith(
            color: badgeColor,
            letterSpacing: 0.5,
            height: 1.4,
          ),
          textAlign: TextAlign.end,
        ),
        const SizedBox(height: 2),
        Text(
          '$verseCount Verses',
          style: AppTypography.caption.copyWith(
            color: scheme.secondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static description fallback map (presentation layer only)
// ─────────────────────────────────────────────────────────────────────────────
//
// Used when Chapter.description is null in the data layer.
// Lives purely in the presentation layer — domain is untouched.

const _kChapterDescriptions = <int, String>{
  1: 'Arjuna faces a moral dilemma on the battlefield of Kurukshetra, '
      'overwhelmed by grief at the thought of fighting his own kin.',
  2: 'Krishna begins his teachings, explaining the eternal nature of the soul '
      'and the necessity of fulfilling one\'s duty.',
  3: 'Krishna explains how to perform one\'s duties without attachment to the '
      'results, achieving liberation through action.',
  4: 'The history of the Gita is revealed, highlighting the importance of a '
      'spiritual teacher and the nature of sacrifice.',
  5: 'Krishna reconciles the paths of action and renunciation, explaining '
      'that both lead to liberation when performed with detachment.',
  6: 'The path of meditation is described, guiding the seeker to control '
      'the mind and attain the highest state of consciousness.',
  7: 'Krishna reveals his divine nature and the different ways seekers '
      'approach the Supreme through devotion and knowledge.',
  8: 'The eternal Brahman is explained, along with the two paths taken '
      'at the time of death and the cycle of birth and rebirth.',
  9: 'Krishna reveals the most confidential knowledge — the path of pure '
      'devotion as the most direct route to liberation.',
  10: 'Krishna describes his divine manifestations, revealing himself as '
      'the source of all existence throughout the universe.',
  11: 'Arjuna is granted cosmic vision, beholding Krishna\'s universal form '
      'encompassing all of creation simultaneously.',
  12: 'The path of devotion is declared supreme, with Krishna explaining '
      'the qualities of his most beloved devotees.',
  13: 'The distinction between the field (body) and the knower of the field '
      '(soul) is elucidated, revealing the nature of true knowledge.',
  14: 'The three modes of material nature — goodness, passion, and ignorance '
      '— are explained as the basis of all conditioned existence.',
  15: 'The supreme secret of the Gita is revealed: Krishna as the highest '
      'person, beyond both the perishable and imperishable.',
  16: 'The divine and demoniac natures are contrasted, showing the path '
      'to liberation versus bondage in material existence.',
  17: 'The three divisions of faith, food, sacrifice, and austerity based '
      'on the modes of nature are described by Krishna.',
  18: 'The final chapter synthesises all teachings, concluding with the '
      'supreme instruction: surrender fully to Krishna.',
};
