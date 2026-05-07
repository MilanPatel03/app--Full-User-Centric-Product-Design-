import 'package:hive/hive.dart';

import '../../../../core/network/network_exception.dart';
import '../models/shlok_hive_model.dart';

/// Interface for shlok local storage operations.
abstract interface class ShlokLocalDataSource {
  /// Returns all cached shloks for a chapter, sorted by verse number.
  /// Returns an empty list (not null) if the chapter is not cached.
  Future<List<HiveShlokModel>> getCachedShloksByChapter(int chapterId);

  /// Returns a single cached shlok by its stable ID (e.g., "BG_2_47").
  Future<HiveShlokModel?> getCachedShlokById(String shlokId);

  /// Returns ALL cached shloks (used for local search).
  Future<List<HiveShlokModel>> getAllCachedShloks();

  /// Caches a list of shloks. Uses shlok [id] as the Hive box key.
  Future<void> cacheShloks(List<HiveShlokModel> shloks);

  /// Removes all cached shloks for a given chapter.
  Future<void> clearChapterCache(int chapterId);
}

/// Hive-backed implementation of [ShlokLocalDataSource].
///
/// All ~700 shloks share a single box, keyed by stable ID ("BG_2_47").
/// Chapter filtering is O(n) over cached shloks — acceptable for n ≤ 700.
class ShlokLocalDataSourceImpl implements ShlokLocalDataSource {
  const ShlokLocalDataSourceImpl(this._box);

  final Box<HiveShlokModel> _box;

  @override
  Future<List<HiveShlokModel>> getCachedShloksByChapter(int chapterId) async {
    try {
      final results = _box.values
          .where((s) => s.chapterId == chapterId)
          .toList()
        ..sort((a, b) => a.verseNumber.compareTo(b.verseNumber));
      return results;
    } on Exception catch (e) {
      throw CacheException('Failed to read shloks for chapter $chapterId: $e');
    }
  }

  @override
  Future<HiveShlokModel?> getCachedShlokById(String shlokId) async {
    try {
      return _box.get(shlokId);
    } on Exception catch (e) {
      throw CacheException('Failed to read shlok $shlokId: $e');
    }
  }

  @override
  Future<List<HiveShlokModel>> getAllCachedShloks() async {
    try {
      return _box.values.toList();
    } on Exception catch (e) {
      throw CacheException('Failed to read all shloks: $e');
    }
  }

  @override
  Future<void> cacheShloks(List<HiveShlokModel> shloks) async {
    try {
      final map = {for (final s in shloks) s.id: s};
      await _box.putAll(map);
    } on Exception catch (e) {
      throw CacheException('Failed to cache shloks: $e');
    }
  }

  @override
  Future<void> clearChapterCache(int chapterId) async {
    try {
      final keysToDelete = _box.values
          .where((s) => s.chapterId == chapterId)
          .map((s) => s.id)
          .toList();
      await _box.deleteAll(keysToDelete);
    } on Exception catch (e) {
      throw CacheException('Failed to clear chapter $chapterId cache: $e');
    }
  }
}
