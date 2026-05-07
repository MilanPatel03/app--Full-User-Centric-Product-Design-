import 'package:hive/hive.dart';

import '../models/chapter_hive_model.dart';
import '../../../../core/network/network_exception.dart';

/// Interface for chapter local storage operations.
///
/// Returns raw [HiveChapterModel] objects — conversion to domain [Chapter]
/// happens in the repository, NOT here.
abstract interface class ChapterLocalDataSource {
  /// Returns all cached chapters, or null if the cache is empty.
  Future<List<HiveChapterModel>?> getCachedChapters();

  /// Returns a specific chapter by its stable ID (e.g., "BG_2"), or null.
  Future<HiveChapterModel?> getCachedChapterById(String chapterId);

  /// Persists a list of chapters. Uses chapter [id] as the Hive box key.
  Future<void> cacheChapters(List<HiveChapterModel> chapters);

  /// Clears all cached chapters. Called before a forced refresh.
  Future<void> clearCache();
}

/// Hive-backed implementation of [ChapterLocalDataSource].
///
/// The Hive box must be opened before this class is instantiated.
/// Open it in main.dart using [AppConstants.boxChapters] as the box name.
class ChapterLocalDataSourceImpl implements ChapterLocalDataSource {
  const ChapterLocalDataSourceImpl(this._box);

  final Box<HiveChapterModel> _box;

  @override
  Future<List<HiveChapterModel>?> getCachedChapters() async {
    try {
      final values = _box.values.toList();
      if (values.isEmpty) return null;
      // Sort by chapter index for consistent ordering
      return values..sort((a, b) => a.index.compareTo(b.index));
    } on Exception catch (e) {
      throw CacheException('Failed to read chapters from cache: $e');
    }
  }

  @override
  Future<HiveChapterModel?> getCachedChapterById(String chapterId) async {
    try {
      return _box.get(chapterId);
    } on Exception catch (e) {
      throw CacheException('Failed to read chapter $chapterId from cache: $e');
    }
  }

  @override
  Future<void> cacheChapters(List<HiveChapterModel> chapters) async {
    try {
      // Use chapter id as the box key for O(1) keyed lookup
      final map = {for (final c in chapters) c.id: c};
      await _box.putAll(map);
    } on Exception catch (e) {
      throw CacheException('Failed to cache chapters: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _box.clear();
    } on Exception catch (e) {
      throw CacheException('Failed to clear chapter cache: $e');
    }
  }
}
