import '../../../../core/utils/result.dart';
import '../entities/bookmark.dart';

/// Domain contract for bookmark data access.
///
/// ## Scope
/// Bookmarks are local-only — stored entirely in Hive, never synced remotely.
/// All operations are O(1) or O(n) on local data.
///
/// ## Independent from Collections
/// [BookmarkRepository] knows nothing about [Collection] or [CollectionItem].
/// - Adding a bookmark does NOT add to any collection
/// - Removing a bookmark does NOT remove from any collection
/// - Collection membership is managed exclusively by [CollectionRepository]
///
/// ## Repository Purity Rule
/// Returns ONLY [Bookmark] domain entities. Never Hive objects or raw maps.
abstract interface class BookmarkRepository {
  /// Fetch all bookmarks, sorted by [Bookmark.createdAt] descending.
  Future<Result<List<Bookmark>>> getBookmarks();

  /// Check whether a specific verse is already bookmarked.
  /// Uses [shlokId] in `"BG_X_Y"` format.
  Future<Result<bool>> isBookmarked(String shlokId);

  /// Fetch the bookmark for a specific verse, or null if not bookmarked.
  Future<Result<Bookmark?>> getBookmarkForShlok(String shlokId);

  /// Persist a new bookmark.
  /// [Bookmark.id] and [Bookmark.createdAt] must be set by the caller
  /// (use a UUID package and `DateTime.now()` in the use case or repository).
  Future<Result<Bookmark>> addBookmark(Bookmark bookmark);

  /// Permanently remove a bookmark by its [Bookmark.id].
  Future<Result<void>> removeBookmark(String bookmarkId);

  /// Update a bookmark's [Bookmark.note].
  /// Only the `note` field is mutable after creation.
  Future<Result<Bookmark>> updateBookmark(Bookmark bookmark);

  /// Real-time stream of all bookmarks.
  /// Emits a new list whenever any bookmark is added, removed, or updated.
  /// Powered by Hive's built-in change notifications.
  Stream<List<Bookmark>> watchBookmarks();
}
