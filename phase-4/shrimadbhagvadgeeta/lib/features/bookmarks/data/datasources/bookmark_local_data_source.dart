import 'package:hive/hive.dart';

import '../../../../core/network/network_exception.dart';
import '../models/bookmark_hive_model.dart';

/// Interface for bookmark local storage operations.
abstract interface class BookmarkLocalDataSource {
  /// Returns all bookmarks sorted newest-first.
  Future<List<HiveBookmarkModel>> getAllBookmarks();

  /// Returns null if the shlok is not bookmarked.
  Future<HiveBookmarkModel?> getBookmarkByShlokId(String shlokId);

  /// Persists a new bookmark.
  Future<void> saveBookmark(HiveBookmarkModel bookmark);

  /// Removes a bookmark by its UUID.
  Future<void> deleteBookmark(String bookmarkId);

  /// Updates the note on an existing bookmark.
  Future<void> updateBookmark(HiveBookmarkModel bookmark);

  /// Exposes Hive's change stream for reactive updates.
  Stream<BoxEvent> watchChanges();
}

/// Hive-backed implementation. All bookmarks in a single box keyed by [id].
class BookmarkLocalDataSourceImpl implements BookmarkLocalDataSource {
  const BookmarkLocalDataSourceImpl(this._box);

  final Box<HiveBookmarkModel> _box;

  @override
  Future<List<HiveBookmarkModel>> getAllBookmarks() async {
    try {
      return _box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on Exception catch (e) {
      throw CacheException('Failed to read bookmarks: $e');
    }
  }

  @override
  Future<HiveBookmarkModel?> getBookmarkByShlokId(String shlokId) async {
    try {
      return _box.values
          .where((b) => b.shlokId == shlokId)
          .firstOrNull;
    } on Exception catch (e) {
      throw CacheException('Failed to read bookmark for shlok $shlokId: $e');
    }
  }

  @override
  Future<void> saveBookmark(HiveBookmarkModel bookmark) async {
    try {
      await _box.put(bookmark.id, bookmark);
    } on Exception catch (e) {
      throw CacheException('Failed to save bookmark: $e');
    }
  }

  @override
  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _box.delete(bookmarkId);
    } on Exception catch (e) {
      throw CacheException('Failed to delete bookmark $bookmarkId: $e');
    }
  }

  @override
  Future<void> updateBookmark(HiveBookmarkModel bookmark) async {
    try {
      await _box.put(bookmark.id, bookmark);
    } on Exception catch (e) {
      throw CacheException('Failed to update bookmark: $e');
    }
  }

  @override
  Stream<BoxEvent> watchChanges() => _box.watch();
}
