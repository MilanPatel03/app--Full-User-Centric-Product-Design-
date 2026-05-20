import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/shlok.dart';
import '../../domain/usecases/get_shloks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State: All verses for a chapter
// ─────────────────────────────────────────────────────────────────────────────

/// Loads all verses for a chapter. Scoped by [chapterId].
/// First access triggers prefetchChapter for offline readiness.
class ShloksNotifier extends FamilyAsyncNotifier<List<Shlok>, int> {
  @override
  Future<List<Shlok>> build(int chapterId) async {
    final useCase = ref.read(getShloksByChapterUseCaseProvider);
    final result = await useCase(GetShloksByChapterParams(chapterId));
    return switch (result) {
      Ok(:final data) => data,
      Err(:final failure) => throw Exception(
        '${failure.runtimeType}: ${failure.message}',
      ),
    };
  }
}

final shloksByChapterProvider =
    AsyncNotifierProvider.family<ShloksNotifier, List<Shlok>, int>(
  ShloksNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// State: Single verse by stable ID
// ─────────────────────────────────────────────────────────────────────────────

/// Loads a single verse by its stable ID (e.g., "BG_2_47").
/// Scoped to [shlokId].
class ShlokDetailNotifier extends FamilyAsyncNotifier<Shlok, String> {
  @override
  Future<Shlok> build(String shlokId) async {
    final useCase = ref.read(getShlokByIdUseCaseProvider);
    final result = await useCase(GetShlokByIdParams(shlokId));
    return switch (result) {
      Ok(:final data) => data,
      Err(:final failure) => throw Exception(
        '${failure.runtimeType}: ${failure.message}',
      ),
    };
  }
}

final shlokDetailProvider =
    AsyncNotifierProvider.family<ShlokDetailNotifier, Shlok, String>(
  ShlokDetailNotifier.new,
);
