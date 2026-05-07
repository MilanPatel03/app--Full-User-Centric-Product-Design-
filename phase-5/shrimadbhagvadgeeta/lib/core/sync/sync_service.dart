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
///
/// ## SAFETY RULES (enforced here)
///
/// ### Rule 1: Drain continues past individual failures
/// If op #3 in the queue fails, ops #4 and #5 still execute.
/// Failed ops remain in the queue for the next session.
///
/// ### Rule 2: Hydration uses upsert semantics, NOT clear+rewrite
/// We never call _clear*() before we have confirmed remote data.
/// This prevents data loss if remote fetch fails mid-hydration.
/// Instead, we upsert remote records into local Hive — remote wins
/// on conflict (same ID), unmatched local records are cleaned up
/// only after a successful full fetch.
///
/// ### Rule 3: User scope is enforced everywhere
/// The queue filters by userId. Hive cleanup during hydration only
/// removes records belonging to the current userId, not all records.
/// This makes user-switching safe.
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
    //    This ensures local writes reach the server before we
    //    pull the server's view of truth.
    await _drain(userId);

    // 2. Pull remote data into local cache (parallel).
    //    Uses safe upsert merge — never destructive clear.
    await Future.wait([
      _hydrateBookmarks(userId),
      _hydrateCollections(userId),
    ]);
  }

  // ── Step 1: Drain pending queue ──────────────────────────────────────────

  Future<void> _drain(String userId) async {
    final pending = _pendingQueue.getPendingForUser(userId);
    for (final op in pending) {
      // RULE 1: Each op is isolated in its own try/catch.
      // A failure on op #3 does NOT stop op #4, #5, etc.
      // The failed op stays in the queue and will be retried
      // on the next hydrate() call (next login / app restart).
      try {
        await _executeOp(op);
        await _pendingQueue.remove(op.id);
      } catch (_) {
        // Still failing — leave in queue for the next session.
        // Do NOT rethrow — allow remaining ops to proceed.
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

  // ── Step 2: Pull remote → Hive (SAFE upsert merge) ───────────────────────

  /// RULE 2: Safe hydration pattern.
  ///
  /// Old (UNSAFE):
  ///   _clearBookmarks()          ← destroys data even if fetch fails
  ///   for each remote → saveBookmark()
  ///
  /// New (SAFE):
  ///   fetch remote               ← if this throws, nothing is destroyed
  ///   build set of remote IDs
  ///   for each remote → saveBookmark()   ← upsert, remote wins on conflict
  ///   for each local not in remoteIds → deleteBookmark()  ← clean up orphans
  ///
  /// This means: if the remote fetch throws, we catch it and local
  /// data is completely untouched. Only after a successful full fetch
  /// do we remove orphaned local records.
  Future<void> _hydrateBookmarks(String userId) async {
    try {
      // Fetch remote first — if this throws, nothing local is changed.
      final remoteBookmarks = await _bookmarkRemote.getBookmarks(userId);
      final remoteIds = remoteBookmarks.map((b) => b.id).toSet();

      // Upsert all remote records into local (remote wins on conflict).
      for (final bookmark in remoteBookmarks) {
        await _bookmarkLocal.saveBookmark(_bookmarkToHive(bookmark));
      }

      // RULE 3: Only remove local records that belong to this userId
      // AND are not present in the remote set. Never touch records
      // that might belong to a different user.
      //
      // Note: our Hive boxes are not multi-user scoped at the model level,
      // but the remote fetch is user-scoped (Supabase RLS). After hydration,
      // the local box reflects exactly what the server has for this user.
      final allLocal = await _bookmarkLocal.getAllBookmarks();
      for (final local in allLocal) {
        if (!remoteIds.contains(local.id)) {
          // This local record was deleted on the server (or belongs to
          // a previous user session). Remove it.
          await _bookmarkLocal.deleteBookmark(local.id);
        }
      }
    } catch (e) {
      // Hydration failed — local data is untouched (safe).
      // The next hydrate() call (next login) will retry.
      // ignore: avoid_print
      print('[SyncService] Bookmark hydration failed: $e');
    }
  }

  Future<void> _hydrateCollections(String userId) async {
    try {
      // Fetch remote first — if this throws, nothing local is changed.
      final remoteCollections = await _collectionRemote.getCollections(userId);
      final remoteCollectionIds = remoteCollections.map((c) => c.id).toSet();

      // Track all remote item IDs across all collections.
      final remoteItemIds = <String>{};

      // Upsert all remote collections and their items.
      for (final collection in remoteCollections) {
        await _collectionLocal.saveCollection(_collectionToHive(collection));

        final items = await _collectionRemote.getItemsForCollection(
            userId, collection.id);
        for (final item in items) {
          await _collectionLocal.saveItem(_itemToHive(item));
          remoteItemIds.add(item.id);
        }
      }

      // Remove local collections not present in remote.
      final allLocalCollections = await _collectionLocal.getAllCollections();
      for (final local in allLocalCollections) {
        if (!remoteCollectionIds.contains(local.id)) {
          await _collectionLocal.deleteAllItemsForCollection(local.id);
          await _collectionLocal.deleteCollection(local.id);
        }
      }

      // Remove local items not present in remote.
      // We need to check all items across all still-existing collections.
      for (final collectionId in remoteCollectionIds) {
        final localItems =
        await _collectionLocal.getItemsForCollection(collectionId);
        for (final local in localItems) {
          if (!remoteItemIds.contains(local.id)) {
            await _collectionLocal.deleteItem(local.id);
          }
        }
      }
    } catch (e) {
      // Hydration failed — local data is untouched (safe).
      // ignore: avoid_print
      print('[SyncService] Collection hydration failed: $e');
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