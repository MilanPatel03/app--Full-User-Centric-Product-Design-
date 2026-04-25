import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/shlok.dart';
import 'shlok_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShlokListView — Sliver list of verse cards
// ─────────────────────────────────────────────────────────────────────────────

/// Renders [shloks] as a vertically-scrolling sliver, suitable for use
/// inside a [CustomScrollView.slivers] list.
///
/// Navigation: each card taps to
/// `/chapter/{shlok.chapterId}/verse/{shlok.id}`.
///
/// Spacing: [AppSpacing.md] gap between cards — generous enough to let
/// each verse breathe, narrow enough to show 2–3 cards simultaneously.
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverToBoxAdapter(child: EditorialHeader(...)),
///     ShlokListView(shloks: shloks),                 // ← this widget
///     SliverToBoxAdapter(child: SizedBox(height: AppSpacing.editorial)),
///   ],
/// )
/// ```
class ShlokListView extends StatelessWidget {
  const ShlokListView({super.key, required this.shloks});

  final List<Shlok> shloks;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            // Interleave cards and spacing separators
            if (i.isOdd) return const SizedBox(height: AppSpacing.md);
            final shlok = shloks[i ~/ 2];
            return ShlokCard(
              shlok: shlok,
              onTap: () => context.push(
                '/chapter/${shlok.chapterId}/verse/${shlok.id}',
              ),
            );
          },
          childCount: shloks.isEmpty ? 0 : (shloks.length * 2) - 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShlokLoadingSliver — 3 skeleton cards while data loads
// ─────────────────────────────────────────────────────────────────────────────

/// Renders [count] skeleton cards while [shloksByChapterProvider] is loading.
/// Skeleton shape matches [ShlokCard] exactly — no layout shift on data arrival.
class ShlokLoadingSliver extends StatelessWidget {
  const ShlokLoadingSliver({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            if (i.isOdd) return const SizedBox(height: AppSpacing.md);
            return const ShlokSkeletonCard();
          },
          childCount: (count * 2) - 1,
        ),
      ),
    );
  }
}
