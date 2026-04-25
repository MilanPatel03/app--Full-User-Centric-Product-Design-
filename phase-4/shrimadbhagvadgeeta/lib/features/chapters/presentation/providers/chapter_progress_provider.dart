import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chapter Progress — Presentation-Layer Mock (Step 7 scaffold)
// ─────────────────────────────────────────────────────────────────────────────
//
// This provider lives ENTIRELY in the presentation layer.
// It returns mock progress data that matches the Stitch design screenshots.
//
// MIGRATION PATH (Step 8+):
//   Replace the mock map with a real ReadingProgressRepository that
//   writes/reads last-opened verse per chapter from Hive. The UI reads
//   ChapterProgress from the same provider — ZERO UI changes required.

/// Represents how far a user has progressed in a single chapter.
enum ChapterStatus { notStarted, inProgress, completed }

class ChapterProgress {
  const ChapterProgress({
    required this.status,
    /// 0.0 – 1.0 fraction (only meaningful when [status] == [inProgress])
    this.fraction = 0.0,
  });

  final ChapterStatus status;
  final double fraction;

  bool get isCompleted => status == ChapterStatus.completed;
  bool get isInProgress => status == ChapterStatus.inProgress;
  bool get isNotStarted => status == ChapterStatus.notStarted;

  /// Human-readable status string for the badge label.
  String get statusLabel => switch (status) {
        ChapterStatus.completed => 'Completed',
        ChapterStatus.inProgress =>
          'In Progress (${(fraction * 100).round()}%)',
        ChapterStatus.notStarted => 'Not Started',
      };
}

/// Mock progress map — keyed by chapter index (1–18).
///
/// Matches the Stitch design: Ch1=Completed, Ch2=In Progress 60%, rest=Not Started.
const _mockProgress = <int, ChapterProgress>{
  1: ChapterProgress(status: ChapterStatus.completed),
  2: ChapterProgress(status: ChapterStatus.inProgress, fraction: 0.60),
};

/// Returns the overall reading progress (0.0–1.0) across all 18 chapters.
///
/// Used by the "OVERALL PROGRESS" badge on the Chapters screen.
/// Mock: 1 completed (47 verses) + 0.6 × 72 in-progress = ~90 of 700 total ≈ 13%.
/// The Stitch shows 33% — we match that by returning a fixed mock value.
const double _mockOverallProgress = 0.33;

// ── Providers ──────────────────────────────────────────────────────────────

/// Provides the [ChapterProgress] for a single chapter by its index.
/// Returns [ChapterProgress(notStarted)] for any chapter not in the mock map.
final chapterProgressProvider =
    Provider.family<ChapterProgress, int>((ref, chapterId) {
  return _mockProgress[chapterId] ??
      const ChapterProgress(status: ChapterStatus.notStarted);
});

/// Overall reading progress (0.0–1.0) across the whole Gita.
final overallProgressProvider = Provider<double>((ref) => _mockOverallProgress);
