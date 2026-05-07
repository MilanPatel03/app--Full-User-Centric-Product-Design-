import 'package:hive/hive.dart';

import '../../../../core/network/network_exception.dart';
import '../models/collection_hive_models.dart';

/// Interface for collection and collection-item local storage.
abstract interface class CollectionLocalDataSource {
  // Collections
  Future<List<HiveCollectionModel>> getAllCollections();
  Future<HiveCollectionModel?> getCollectionById(String id);
  Future<void> saveCollection(HiveCollectionModel collection);
  Future<void> deleteCollection(String collectionId);

  // Collection Items
  Future<List<HiveCollectionItemModel>> getItemsForCollection(
      String collectionId);
  Future<HiveCollectionItemModel?> getItemById(String itemId);
  Future<void> saveItem(HiveCollectionItemModel item);
  Future<void> deleteItem(String itemId);
  Future<void> deleteAllItemsForCollection(String collectionId);

  // Streams
  Stream<BoxEvent> watchCollections();
  Stream<BoxEvent> watchItems();
}

/// Hive-backed implementation.
/// Collections and items use separate Hive boxes.
class CollectionLocalDataSourceImpl implements CollectionLocalDataSource {
  const CollectionLocalDataSourceImpl({
    required Box<HiveCollectionModel> collectionBox,
    required Box<HiveCollectionItemModel> itemBox,
  })  : _colBox = collectionBox,
        _itemBox = itemBox;

  final Box<HiveCollectionModel> _colBox;
  final Box<HiveCollectionItemModel> _itemBox;

  // ── Collections ───────────────────────────────────────────────────────────

  @override
  Future<List<HiveCollectionModel>> getAllCollections() async {
    try {
      return _colBox.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } on Exception catch (e) {
      throw CacheException('Failed to read collections: $e');
    }
  }

  @override
  Future<HiveCollectionModel?> getCollectionById(String id) async {
    try {
      return _colBox.get(id);
    } on Exception catch (e) {
      throw CacheException('Failed to read collection $id: $e');
    }
  }

  @override
  Future<void> saveCollection(HiveCollectionModel collection) async {
    try {
      await _colBox.put(collection.id, collection);
    } on Exception catch (e) {
      throw CacheException('Failed to save collection: $e');
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _colBox.delete(collectionId);
    } on Exception catch (e) {
      throw CacheException('Failed to delete collection $collectionId: $e');
    }
  }

  // ── Collection Items ──────────────────────────────────────────────────────

  @override
  Future<List<HiveCollectionItemModel>> getItemsForCollection(
      String collectionId) async {
    try {
      return _itemBox.values
          .where((i) => i.collectionId == collectionId)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } on Exception catch (e) {
      throw CacheException(
          'Failed to read items for collection $collectionId: $e');
    }
  }

  @override
  Future<HiveCollectionItemModel?> getItemById(String itemId) async {
    try {
      return _itemBox.get(itemId);
    } on Exception catch (e) {
      throw CacheException('Failed to read item $itemId: $e');
    }
  }

  @override
  Future<void> saveItem(HiveCollectionItemModel item) async {
    try {
      await _itemBox.put(item.id, item);
    } on Exception catch (e) {
      throw CacheException('Failed to save collection item: $e');
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      await _itemBox.delete(itemId);
    } on Exception catch (e) {
      throw CacheException('Failed to delete item $itemId: $e');
    }
  }

  @override
  Future<void> deleteAllItemsForCollection(String collectionId) async {
    try {
      final keys = _itemBox.values
          .where((i) => i.collectionId == collectionId)
          .map((i) => i.id)
          .toList();
      await _itemBox.deleteAll(keys);
    } on Exception catch (e) {
      throw CacheException(
          'Failed to delete items for collection $collectionId: $e');
    }
  }

  // ── Streams ────────────────────────────────────────────────────────────────

  @override
  Stream<BoxEvent> watchCollections() => _colBox.watch();

  @override
  Stream<BoxEvent> watchItems() => _itemBox.watch();
}
