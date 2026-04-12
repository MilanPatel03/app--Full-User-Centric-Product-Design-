import '../../../../core/errors/failures.dart';
import '../../../../core/utils/repository_calls.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_local_data_source.dart';
import '../models/collection_hive_models.dart';

/// Concrete implementation of [CollectionRepository].
///
/// Local-only — no remote source involved.
/// Both [Collection] and [CollectionItem] are managed here
/// as a single aggregate.
class CollectionRepositoryImpl
    with RepositoryCalls
    implements CollectionRepository {
  const CollectionRepositoryImpl(this._local);

  final CollectionLocalDataSource _local;

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
  Future<Result<Collection>> createCollection(Collection collection) =>
      safeLocalRead(() async {
        await _local.saveCollection(_collectionToHive(collection));
        return collection;
      });

  @override
  Future<Result<Collection>> updateCollection(Collection collection) =>
      safeLocalRead(() async {
        await _local.saveCollection(_collectionToHive(collection));
        return collection;
      });

  @override
  Future<Result<void>> deleteCollection(String collectionId) =>
      safeLocalWrite(() async {
        // Delete all items belonging to this collection first
        await _local.deleteAllItemsForCollection(collectionId);
        await _local.deleteCollection(collectionId);
      });

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
    // Enforce uniqueness: one shlok per collection
    final duplicateCheck = await isShlokInCollection(
      collectionId: item.collectionId,
      shlokId: item.shlokId,
    );
    if (duplicateCheck case Ok(:final data) when data) {
      return Err(ValidationFailure(
        '"${item.shlokId}" is already in this collection.',
      ));
    }

    return safeLocalRead(() async {
      // Determine order: place at end (max existing order + 1)
      final existing =
          await _local.getItemsForCollection(item.collectionId);
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
  }

  @override
  Future<Result<void>> removeItemFromCollection(String itemId) =>
      safeLocalWrite(() async {
        final item = await _local.getItemById(itemId);
        if (item == null) return;

        final collectionId = item.collectionId;
        await _local.deleteItem(itemId);

        // Re-compact order values: 0, 1, 2, ..., n-1
        final remaining =
            await _local.getItemsForCollection(collectionId);
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

  @override
  Future<Result<void>> reorderItems(
    String collectionId,
    List<String> orderedItemIds,
  ) =>
      safeLocalWrite(() async {
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

  @override
  Future<Result<bool>> isShlokInCollection({
    required String collectionId,
    required String shlokId,
  }) =>
      safeLocalRead(() async {
        final items = await _local.getItemsForCollection(collectionId);
        return items.any((i) => i.shlokId == shlokId);
      });

  // ── Real-time Streams ─────────────────────────────────────────────────────

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
