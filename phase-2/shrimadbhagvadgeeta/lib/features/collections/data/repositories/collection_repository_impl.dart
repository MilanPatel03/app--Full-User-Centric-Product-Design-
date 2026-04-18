import 'dart:convert';

import '../../../../core/errors/failures.dart';
import '../../../../core/sync/pending_sync_queue.dart';
import '../../../../core/utils/repository_calls.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_local_data_source.dart';
import '../datasources/collection_remote_data_source.dart';
import '../models/collection_hive_models.dart';

/// Concrete implementation of [CollectionRepository].
///
/// ## Sync Strategy
/// Identical pattern to [BookmarkRepositoryImpl]:
/// - Reads: Hive only (offline-safe, instant).
/// - Writes: Hive first → fire-and-forget remote sync → enqueue on failure.
/// - Hydration: [SyncService] drains queue then pulls remote → Hive on login.
///
/// ## userId nullability
/// When null (unauthenticated), all remote sync calls are skipped silently.
class CollectionRepositoryImpl
    with RepositoryCalls
    implements CollectionRepository {
  const CollectionRepositoryImpl({
    required CollectionLocalDataSource local,
    required CollectionRemoteDataSource remote,
    required String? userId,
    required PendingSyncQueue queue,
  })  : _local = local,
        _remote = remote,
        _userId = userId,
        _queue = queue;

  final CollectionLocalDataSource _local;
  final CollectionRemoteDataSource _remote;

  /// Null when unauthenticated — sync ops are skipped silently.
  final String? _userId;

  final PendingSyncQueue _queue;

  // ── Collection CRUD ───────────────────────────────────────────────────────

  @override
  Future<Result<List<Collection>>> getCollections() =>
      safeLocalRead(() async {
        final models = await _local.getAllCollections();
        return models.map(_collectionFromHive).toList();
      });

  @override
  Future<Result<Collection>> getCollectionById(String collectionId) =>
      safeLocalRead(() async {
        final model = await _local.getCollectionById(collectionId);
        if (model == null) {
          throw Exception('Collection $collectionId not found.');
        }
        return _collectionFromHive(model);
      });

  @override
  Future<Result<Collection>> createCollection(Collection collection) async {
    final result = await safeLocalRead(() async {
      await _local.saveCollection(_collectionToHive(collection));
      return collection;
    });
    if (result case Ok(:final data)) {
      _syncUpsertCollection(data);
    }
    return result;
  }

  @override
  Future<Result<Collection>> updateCollection(Collection collection) async {
    final result = await safeLocalRead(() async {
      await _local.saveCollection(_collectionToHive(collection));
      return collection;
    });
    if (result case Ok(:final data)) {
      _syncUpsertCollection(data);
    }
    return result;
  }

  @override
  Future<Result<void>> deleteCollection(String collectionId) async {
    final result = await safeLocalWrite(() async {
      // Delete all items first, then the collection itself.
      await _local.deleteAllItemsForCollection(collectionId);
      await _local.deleteCollection(collectionId);
    });
    if (result case Ok()) {
      // Remote cascade (FK ON DELETE CASCADE) handles items automatically.
      _syncDeleteCollection(collectionId);
    }
    return result;
  }

  // ── Collection Items ──────────────────────────────────────────────────────

  @override
  Future<Result<List<CollectionItem>>> getItemsForCollection(
          String collectionId) =>
      safeLocalRead(() async {
        final models = await _local.getItemsForCollection(collectionId);
        return models.map(_itemFromHive).toList();
      });

  @override
  Future<Result<CollectionItem>> addItemToCollection(
      CollectionItem item) async {
    // Enforce uniqueness: one shlok per collection.
    final duplicateCheck = await isShlokInCollection(
      collectionId: item.collectionId,
      shlokId: item.shlokId,
    );
    if (duplicateCheck case Ok(:final data) when data) {
      return Err(ValidationFailure(
        '"${item.shlokId}" is already in this collection.',
      ));
    }

    final result = await safeLocalRead(() async {
      // Determine order: place at end (max existing order + 1).
      final existing = await _local.getItemsForCollection(item.collectionId);
      final nextOrder = existing.isEmpty
          ? 0
          : existing.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;

      final positioned = HiveCollectionItemModel(
        id: item.id,
        collectionId: item.collectionId,
        shlokId: item.shlokId,
        order: nextOrder,
        addedAt: item.addedAt.millisecondsSinceEpoch,
      );
      await _local.saveItem(positioned);
      return _itemFromHive(positioned);
    });

    if (result case Ok(:final data)) {
      _syncUpsertCollectionItem(data);
    }
    return result;
  }

  @override
  Future<Result<void>> removeItemFromCollection(String itemId) async {
    // Capture collectionId inside safeLocalWrite (error-wrapped).
    String? capturedCollectionId;

    final result = await safeLocalWrite(() async {
      final hiveItem = await _local.getItemById(itemId);
      if (hiveItem == null) return;

      capturedCollectionId = hiveItem.collectionId;
      await _local.deleteItem(itemId);

      // Re-compact order values: 0, 1, 2, …, n-1.
      final remaining =
          await _local.getItemsForCollection(hiveItem.collectionId);
      for (int i = 0; i < remaining.length; i++) {
        if (remaining[i].order != i) {
          await _local.saveItem(HiveCollectionItemModel(
            id: remaining[i].id,
            collectionId: remaining[i].collectionId,
            shlokId: remaining[i].shlokId,
            order: i,
            addedAt: remaining[i].addedAt,
          ));
        }
      }
    });

    if (result case Ok() when capturedCollectionId != null) {
      final collectionId = capturedCollectionId!;
      // Sync: delete the removed item.
      _syncDeleteCollectionItem(itemId);
      // Sync: upsert remaining items with their recompacted orders.
      try {
        final remaining = await _local.getItemsForCollection(collectionId);
        for (final r in remaining) {
          _syncUpsertCollectionItem(_itemFromHive(r));
        }
      } catch (_) {
        // Non-fatal: order reconciliation missed; hydration will fix it.
      }
    }
    return result;
  }

  @override
  Future<Result<void>> reorderItems(
    String collectionId,
    List<String> orderedItemIds,
  ) async {
    final result = await safeLocalWrite(() async {
      for (int i = 0; i < orderedItemIds.length; i++) {
        final existing = await _local.getItemById(orderedItemIds[i]);
        if (existing != null && existing.collectionId == collectionId) {
          await _local.saveItem(HiveCollectionItemModel(
            id: existing.id,
            collectionId: existing.collectionId,
            shlokId: existing.shlokId,
            order: i,
            addedAt: existing.addedAt,
          ));
        }
      }
    });

    if (result case Ok()) {
      // Sync all items in the collection with their new order values.
      try {
        final all = await _local.getItemsForCollection(collectionId);
        for (final item in all) {
          _syncUpsertCollectionItem(_itemFromHive(item));
        }
      } catch (_) {
        // Non-fatal.
      }
    }
    return result;
  }

  @override
  Future<Result<bool>> isShlokInCollection({
    required String collectionId,
    required String shlokId,
  }) =>
      safeLocalRead(() async {
        final items = await _local.getItemsForCollection(collectionId);
        return items.any((i) => i.shlokId == shlokId);
      });

  // ── Real-time Streams (local only) ────────────────────────────────────────

  @override
  Stream<List<Collection>> watchCollections() async* {
    final initial = await _local.getAllCollections();
    yield initial.map(_collectionFromHive).toList();

    await for (final _ in _local.watchCollections()) {
      final updated = await _local.getAllCollections();
      yield updated.map(_collectionFromHive).toList();
    }
  }

  @override
  Stream<List<CollectionItem>> watchItemsForCollection(
      String collectionId) async* {
    final initial = await _local.getItemsForCollection(collectionId);
    yield initial.map(_itemFromHive).toList();

    await for (final _ in _local.watchItems()) {
      final updated = await _local.getItemsForCollection(collectionId);
      yield updated.map(_itemFromHive).toList();
    }
  }

  // ── Fire-and-forget sync with queue fallback ──────────────────────────────

  void _syncUpsertCollection(Collection collection) {
    final uid = _userId;
    if (uid == null) return;

    safeRemoteRead(() => _remote.upsertCollection(uid, collection))
        .then((result) {
      if (result case Err()) {
        _queue.enqueue(
          type: PendingSyncQueue.upsertCollection,
          userId: uid,
          entityId: collection.id,
          payload: json.encode({
            'id': collection.id,
            'name': collection.name,
            'created_at': collection.createdAt.millisecondsSinceEpoch,
          }),
        );
      }
    });
  }

  void _syncDeleteCollection(String collectionId) {
    final uid = _userId;
    if (uid == null) return;

    safeRemoteRead(() => _remote.deleteCollection(uid, collectionId))
        .then((result) {
      if (result case Err()) {
        _queue.enqueue(
          type: PendingSyncQueue.deleteCollection,
          userId: uid,
          entityId: collectionId,
          payload: collectionId,
        );
      }
    });
  }

  void _syncUpsertCollectionItem(CollectionItem item) {
    final uid = _userId;
    if (uid == null) return;

    safeRemoteRead(() => _remote.upsertCollectionItem(uid, item))
        .then((result) {
      if (result case Err()) {
        _queue.enqueue(
          type: PendingSyncQueue.upsertCollectionItem,
          userId: uid,
          entityId: item.id,
          payload: json.encode({
            'id': item.id,
            'collection_id': item.collectionId,
            'shlok_id': item.shlokId,
            'order': item.order,
            'added_at': item.addedAt.millisecondsSinceEpoch,
          }),
        );
      }
    });
  }

  void _syncDeleteCollectionItem(String itemId) {
    final uid = _userId;
    if (uid == null) return;

    safeRemoteRead(() => _remote.deleteCollectionItem(uid, itemId))
        .then((result) {
      if (result case Err()) {
        _queue.enqueue(
          type: PendingSyncQueue.deleteCollectionItem,
          userId: uid,
          entityId: itemId,
          payload: itemId,
        );
      }
    });
  }

  // ── Inlined Mappers ───────────────────────────────────────────────────────

  static Collection _collectionFromHive(HiveCollectionModel m) => Collection(
        id: m.id,
        name: m.name,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m.createdAt),
      );

  static HiveCollectionModel _collectionToHive(Collection c) =>
      HiveCollectionModel(
        id: c.id,
        name: c.name,
        createdAt: c.createdAt.millisecondsSinceEpoch,
      );

  static CollectionItem _itemFromHive(HiveCollectionItemModel m) =>
      CollectionItem(
        id: m.id,
        collectionId: m.collectionId,
        shlokId: m.shlokId,
        order: m.order,
        addedAt: DateTime.fromMillisecondsSinceEpoch(m.addedAt),
      );
}
