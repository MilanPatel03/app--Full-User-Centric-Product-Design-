import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../app_typography.dart';

/// Sacred Editorial — Page Header Component
///
/// Displays the Sanskrit title + English subtitle on all content screens.
/// Intentionally generous top padding to create breathing room.
///
/// ## Layout
/// ```
/// [top padding — editorial breathing room]
/// [eyebrow]     ← small, uppercase, tracked (optional)
/// [OM mark]     ← dim Sanskrit sacred symbol (optional)
/// [titleSanskrit] ← Devanagari, large
/// [subtitle]    ← English headline
/// [footnote]    ← small utility caption (optional)
/// [bottom padding]
/// ```
///
/// Usage:
/// ```dart
/// EditorialHeader(
///   eyebrow: 'Sacred Text',
///   titleSanskrit: 'श्रीमद् भगवद्गीता',
///   subtitle: 'Bhagavad Gita',
///   footnote: '18 Chapters · 700 Verses',
/// )
/// ```
class EditorialHeader extends StatelessWidget {
  const EditorialHeader({
    super.key,
    required this.titleSanskrit,
    required this.subtitle,
    this.eyebrow,
    this.footnote,
    this.showOmMark = true,
  });

  /// Large Devanagari title. Rendered with Sanskrit display typography.
  final String titleSanskrit;

  /// English subtitle. Rendered with wisdom headline typography.
  final String subtitle;

  /// Small uppercase label above the title. Adds context/category.
  final String? eyebrow;

  /// Small caption below the subtitle. Verse counts, metadata, etc.
  final String? footnote;

  /// Whether to show the dim ॐ mark above the title.
  final bool showOmMark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,    // left  — aligns with card left edge
        AppSpacing.xxl,   // top   — editorial breathing room from status bar
        // Right is intentionally narrow — actions float here
        AppSpacing.xxl,   // right — space for the floating action row
        AppSpacing.xl,    // bottom — separates header from content
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Eyebrow ────────────────────────────────────────────────────
          if (eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              style: context.utilityCaption.copyWith(
                color: scheme.secondary,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── OM mark ───────────────────────────────────────────────────
          if (showOmMark) ...[
            Text(
              'ॐ',
              style: AppTypography.sanskritBody.copyWith(
                fontSize: 20,
                color: scheme.primary.withValues(alpha: 0.45),
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // ── Sanskrit title ─────────────────────────────────────────────
          Text(
            titleSanskrit,
            style: context.sanskritDisplay,
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── English subtitle ───────────────────────────────────────────
          Text(
            subtitle,
            style: context.wisdomHeadline,
          ),

          // ── Footnote ───────────────────────────────────────────────────
          if (footnote != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              footnote!,
              style: context.utilityCaption.copyWith(
                color: scheme.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
