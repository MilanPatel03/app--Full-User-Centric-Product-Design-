import '../../../features/bookmarks/data/datasources/bookmark_local_data_source.dart';
import '../../../features/bookmarks/data/datasources/bookmark_remote_data_source.dart';
import '../../../features/bookmarks/data/models/bookmark_hive_model.dart';
import '../../../features/bookmarks/domain/entities/bookmark.dart';
import '../../../features/collections/data/datasources/collection_local_data_source.dart';
import '../../../features/collections/data/datasources/collection_remote_data_source.dart';
import '../../../features/collections/data/models/collection_hive_models.dart';
import '../../../features/collections/domain/entities/collection.dart';
import '../../../features/collections/domain/entities/collection_item.dart';

/// Hydrates local Hive caches from Supabase on app start (when logged in).
///
/// ## When to call
/// Call [hydrate] once, right after confirming the user is authenticated,
/// before rendering any screen that depends on bookmarks or collections.
/// Typically invoked from [AuthStateNotifier.build] or main.dart.
///
/// ## Strategy
/// Remote data is treated as the source of truth for sync purposes.
/// Remote → overwrite Hive. Local changes will have already been synced
/// on the previous session (fire-and-forget on every write).
///
/// ## Error Handling
/// Sync errors are non-fatal — the app continues with cached local data.
/// Errors are swallowed and printed; they do NOT bubble up to the UI.
class SyncService {
  const SyncService({
    required BookmarkLocalDataSource bookmarkLocal,
    required BookmarkRemoteDataSource bookmarkRemote,
    required CollectionLocalDataSource collectionLocal,
    required CollectionRemoteDataSource collectionRemote,
  })  : _bookmarkLocal = bookmarkLocal,
        _bookmarkRemote = bookmarkRemote,
        _collectionLocal = collectionLocal,
        _collectionRemote = collectionRemote;

  final BookmarkLocalDataSource _bookmarkLocal;
  final BookmarkRemoteDataSource _bookmarkRemote;
  final CollectionLocalDataSource _collectionLocal;
  final CollectionRemoteDataSource _collectionRemote;

  /// Fetches remote bookmarks and collections then overwrites Hive.
  ///
  /// Safe to call concurrently for both data types.
  Future<void> hydrate(String userId) async {
    await Future.wait([
      _hydrateBookmarks(userId),
      _hydrateCollections(userId),
    ]);
  }

  // ── Bookmark hydration ───────────────────────────────────────────────────

  Future<void> _hydrateBookmarks(String userId) async {
    try {
      final remoteBookmarks = await _bookmarkRemote.getBookmarks(userId);

      // Clear local, then write all remote bookmarks
      // This ensures deletions made on another device are reflected locally.
      await _clearBookmarks();
      for (final bookmark in remoteBookmarks) {
        await _bookmarkLocal.saveBookmark(_bookmarkToHive(bookmark));
      }
    } catch (e) {
      // Non-fatal — log and continue with cached data
      // ignore: avoid_print
      print('[SyncService] Bookmark hydration failed: $e');
    }
  }

  Future<void> _clearBookmarks() async {
    final all = await _bookmarkLocal.getAllBookmarks();
    for (final b in all) {
      await _bookmarkLocal.deleteBookmark(b.id);
    }
  }

  Future<void> _clearCollections() async {
    final collections = await _collectionLocal.getAllCollections();
    for (final c in collections) {
      await _collectionLocal.deleteCollection(c.id);
    }
  }

  // ── Collection hydration ─────────────────────────────────────────────────

  Future<void> _hydrateCollections(String userId) async {
    try {
      final remoteCollections = await _collectionRemote.getCollections(userId);

      // 🔴 CLEAR LOCAL FIRST (IMPORTANT — same as bookmarks)
      await _clearCollections();

      // Save collections
      for (final collection in remoteCollections) {
        await _collectionLocal.saveCollection(_collectionToHive(collection));

        // For each collection, fetch and save its items
        final items = await _collectionRemote.getItemsForCollection(
            userId, collection.id);
        for (final item in items) {
          await _collectionLocal.saveItem(_itemToHive(item));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[SyncService] Collection hydration failed: $e');
    }
  }

  // ── Mappers ───────────────────────────────────────────────────────────────

  static HiveBookmarkModel _bookmarkToHive(Bookmark b) => HiveBookmarkModel(
        id: b.id,
        shlokId: b.shlokId,
        createdAt: b.createdAt.millisecondsSinceEpoch,
        note: b.note,
      );

  static HiveCollectionModel _collectionToHive(Collection c) =>
      HiveCollectionModel(
        id: c.id,
        name: c.name,
        createdAt: c.createdAt.millisecondsSinceEpoch,
      );

  static HiveCollectionItemModel _itemToHive(CollectionItem item) =>
      HiveCollectionItemModel(
        id: item.id,
        collectionId: item.collectionId,
        shlokId: item.shlokId,
        order: item.order,
        addedAt: item.addedAt.millisecondsSinceEpoch,
      );
}
