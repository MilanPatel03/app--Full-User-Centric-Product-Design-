import 'dart:convert';

import '../../../features/bookmarks/data/datasources/bookmark_local_data_source.dart';
import '../../../features/bookmarks/data/datasources/bookmark_remote_data_source.dart';
import '../../../features/bookmarks/data/models/bookmark_hive_model.dart';
import '../../../features/bookmarks/domain/entities/bookmark.dart';
import '../../../features/collections/data/datasources/collection_local_data_source.dart';
import '../../../features/collections/data/datasources/collection_remote_data_source.dart';
import '../../../features/collections/data/models/collection_hive_models.dart';
import '../../../features/collections/domain/entities/collection.dart';
import '../../../features/collections/domain/entities/collection_item.dart';
import 'pending_sync_queue.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SyncService — remote hydration + pending queue drain
// ─────────────────────────────────────────────────────────────────────────────

/// Hydrates local Hive caches from Supabase on app start (when logged in),
/// and drains any sync operations that failed during the previous session.
///
/// ## Execution order in [hydrate]
/// 1. Drain [PendingSyncQueue] (push locally-queued ops to remote).
/// 2. Pull remote → overwrite Hive (source of truth reconciliation).
///
/// Drain runs first so that locally-pending writes are not overwritten
/// by stale remote data during the pull phase.
class SyncService {
  const SyncService({
    required BookmarkLocalDataSource bookmarkLocal,
    required BookmarkRemoteDataSource bookmarkRemote,
    required CollectionLocalDataSource collectionLocal,
    required CollectionRemoteDataSource collectionRemote,
    required PendingSyncQueue pendingQueue,
  })  : _bookmarkLocal = bookmarkLocal,
        _bookmarkRemote = bookmarkRemote,
        _collectionLocal = collectionLocal,
        _collectionRemote = collectionRemote,
        _pendingQueue = pendingQueue;

  final BookmarkLocalDataSource _bookmarkLocal;
  final BookmarkRemoteDataSource _bookmarkRemote;
  final CollectionLocalDataSource _collectionLocal;
  final CollectionRemoteDataSource _collectionRemote;
  final PendingSyncQueue _pendingQueue;

  /// Entry point — called by [syncTriggerProvider] on login.
  Future<void> hydrate(String userId) async {
    // 1. Retry previously failed sync ops before pulling remote.
    await _drain(userId);

    // 2. Pull remote data into local cache (parallel).
    await Future.wait([
      _hydrateBookmarks(userId),
      _hydrateCollections(userId),
    ]);
  }

  // ── Step 1: Drain pending queue ──────────────────────────────────────────

  Future<void> _drain(String userId) async {
    final pending = _pendingQueue.getPendingForUser(userId);
    for (final op in pending) {
      try {
        await _executeOp(op);
        await _pendingQueue.remove(op.id);
      } catch (_) {
        // Still failing — leave in queue for the next session.
      }
    }
  }

  Future<void> _executeOp(HivePendingSyncModel op) async {
    switch (op.type) {
      case PendingSyncQueue.upsertBookmark:
        await _bookmarkRemote.upsertBookmark(
          op.userId,
          _bookmarkFromJson(json.decode(op.payload) as Map<String, dynamic>),
        );
      case PendingSyncQueue.deleteBookmark:
        // payload == shlokId
        await _bookmarkRemote.deleteBookmark(op.userId, op.payload);
      case PendingSyncQueue.upsertCollection:
        await _collectionRemote.upsertCollection(
          op.userId,
          _collectionFromJson(json.decode(op.payload) as Map<String, dynamic>),
        );
      case PendingSyncQueue.deleteCollection:
        // payload == collectionId
        await _collectionRemote.deleteCollection(op.userId, op.payload);
      case PendingSyncQueue.upsertCollectionItem:
        await _collectionRemote.upsertCollectionItem(
          op.userId,
          _collectionItemFromJson(
              json.decode(op.payload) as Map<String, dynamic>),
        );
      case PendingSyncQueue.deleteCollectionItem:
        // payload == itemId
        await _collectionRemote.deleteCollectionItem(op.userId, op.payload);
    }
  }

  // ── Step 2: Pull remote → Hive ────────────────────────────────────────────

  Future<void> _hydrateBookmarks(String userId) async {
    try {
      final remoteBookmarks = await _bookmarkRemote.getBookmarks(userId);
      await _clearBookmarks();
      for (final bookmark in remoteBookmarks) {
        await _bookmarkLocal.saveBookmark(_bookmarkToHive(bookmark));
      }
    } catch (e) {
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

  Future<void> _hydrateCollections(String userId) async {
    try {
      final remoteCollections = await _collectionRemote.getCollections(userId);
      await _clearCollections();
      for (final collection in remoteCollections) {
        await _collectionLocal.saveCollection(_collectionToHive(collection));
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

  Future<void> _clearCollections() async {
    final all = await _collectionLocal.getAllCollections();
    for (final c in all) {
      await _collectionLocal.deleteCollection(c.id);
      await _collectionLocal.deleteAllItemsForCollection(c.id);
    }
  }

  // ── Domain entity reconstructors (used during drain) ─────────────────────

  static Bookmark _bookmarkFromJson(Map<String, dynamic> d) => Bookmark(
        id: d['id'] as String,
        shlokId: d['shlok_id'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(d['created_at'] as int),
        note: d['note'] as String?,
      );

  static Collection _collectionFromJson(Map<String, dynamic> d) => Collection(
        id: d['id'] as String,
        name: d['name'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(d['created_at'] as int),
      );

  static CollectionItem _collectionItemFromJson(Map<String, dynamic> d) =>
      CollectionItem(
        id: d['id'] as String,
        collectionId: d['collection_id'] as String,
        shlokId: d['shlok_id'] as String,
        order: d['order'] as int,
        addedAt: DateTime.fromMillisecondsSinceEpoch(d['added_at'] as int),
      );

  // ── Hive mappers ──────────────────────────────────────────────────────────

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
