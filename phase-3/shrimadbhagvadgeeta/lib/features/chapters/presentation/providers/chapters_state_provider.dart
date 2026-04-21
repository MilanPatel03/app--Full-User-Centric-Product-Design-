import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/usecases/get_chapters.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State: List of all 18 chapters
// ─────────────────────────────────────────────────────────────────────────────

/// Loads all 18 chapters. Cache-first via repository.
///
/// State lifecycle:
///   AsyncLoading → built on first watch
///   AsyncData    → cache hit or remote success
///   AsyncError   → failure (Failure subtype) is the error object
///
/// Invalidate to force a re-fetch:
///   ref.invalidate(chaptersProvider);
class ChaptersNotifier extends AsyncNotifier<List<Chapter>> {
  @override
  Future<List<Chapter>> build() async {
    final useCase = ref.read(getChaptersUseCaseProvider);
    final result = await useCase(const NoParams());
    return switch (result) {
      Ok(:final data) => data,
      Err(:final failure) => throw failure,
    };
  }
}

final chaptersProvider =
    AsyncNotifierProvider<ChaptersNotifier, List<Chapter>>(
  ChaptersNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// State: Single chapter by ID
// ─────────────────────────────────────────────────────────────────────────────

/// Loads a single chapter. Scoped to [chapterId] — each chapter gets its
/// own independently-cached provider instance.
class ChapterDetailNotifier
    extends FamilyAsyncNotifier<Chapter, int> {
  @override
  Future<Chapter> build(int chapterId) async {
    final useCase = ref.read(getChapterByIdUseCaseProvider);
    final result = await useCase(GetChapterByIdParams(chapterId));
    return switch (result) {
      Ok(:final data) => data,
      Err(:final failure) => throw failure,
    };
  }
}

final chapterDetailProvider =
    AsyncNotifierProvider.family<ChapterDetailNotifier, Chapter, int>(
  ChapterDetailNotifier.new,
);
