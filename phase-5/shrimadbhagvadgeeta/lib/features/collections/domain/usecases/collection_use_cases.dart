import 'package:equatable/equatable.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/collection.dart';
import '../entities/collection_item.dart';
import '../repositories/collection_repository.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Collection Use Cases
// ═════════════════════════════════════════════════════════════════════════════

/// Returns all collections sorted by creation date.
class GetCollections implements UseCase<List<Collection>, NoParams> {
  const GetCollections(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<List<Collection>>> call(NoParams params) =>
      _repository.getCollections();
}

// ─────────────────────────────────────────────────────────────────────────────

/// Creates a new collection.
/// [Collection.id] and [Collection.createdAt] must be set by the caller.
class CreateCollection implements UseCase<Collection, CreateCollectionParams> {
  const CreateCollection(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<Collection>> call(CreateCollectionParams params) =>
      _repository.createCollection(params.collection);
}

class CreateCollectionParams extends Equatable {
  const CreateCollectionParams(this.collection);
  final Collection collection;

  @override
  List<Object?> get props => [collection];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Renames a collection. Only [Collection.name] is mutable after creation.
class UpdateCollection implements UseCase<Collection, UpdateCollectionParams> {
  const UpdateCollection(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<Collection>> call(UpdateCollectionParams params) =>
      _repository.updateCollection(params.collection);
}

class UpdateCollectionParams extends Equatable {
  const UpdateCollectionParams(this.collection);
  final Collection collection;

  @override
  List<Object?> get props => [collection];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Permanently deletes a collection and all its [CollectionItem]s.
class DeleteCollection implements UseCase<void, DeleteCollectionParams> {
  const DeleteCollection(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<void>> call(DeleteCollectionParams params) =>
      _repository.deleteCollection(params.collectionId);
}

class DeleteCollectionParams extends Equatable {
  const DeleteCollectionParams(this.collectionId);
  final String collectionId;

  @override
  List<Object?> get props => [collectionId];
}

// ═════════════════════════════════════════════════════════════════════════════
// CollectionItem Use Cases
// ═════════════════════════════════════════════════════════════════════════════

/// Fetches all items in a collection, sorted by [CollectionItem.order].
class GetItemsForCollection
    implements UseCase<List<CollectionItem>, GetItemsForCollectionParams> {
  const GetItemsForCollection(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<List<CollectionItem>>> call(
          GetItemsForCollectionParams params) =>
      _repository.getItemsForCollection(params.collectionId);
}

class GetItemsForCollectionParams extends Equatable {
  const GetItemsForCollectionParams(this.collectionId);
  final String collectionId;

  @override
  List<Object?> get props => [collectionId];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Adds a shlok to a collection.
/// Returns [ValidationFailure] if the shlok is already in that collection.
class AddItemToCollection
    implements UseCase<CollectionItem, AddItemToCollectionParams> {
  const AddItemToCollection(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<CollectionItem>> call(AddItemToCollectionParams params) =>
      _repository.addItemToCollection(params.item);
}

class AddItemToCollectionParams extends Equatable {
  const AddItemToCollectionParams(this.item);
  final CollectionItem item;

  @override
  List<Object?> get props => [item];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Removes a shlok from a collection by [CollectionItem.id].
class RemoveItemFromCollection
    implements UseCase<void, RemoveItemFromCollectionParams> {
  const RemoveItemFromCollection(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<void>> call(RemoveItemFromCollectionParams params) =>
      _repository.removeItemFromCollection(params.itemId);
}

class RemoveItemFromCollectionParams extends Equatable {
  const RemoveItemFromCollectionParams(this.itemId);
  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Reorders the shloks within a collection.
///
/// [orderedItemIds]: [CollectionItem.id]s in the desired display order.
/// Index 0 = first item, index n = last item.
class ReorderCollectionItems
    implements UseCase<void, ReorderCollectionItemsParams> {
  const ReorderCollectionItems(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<void>> call(ReorderCollectionItemsParams params) =>
      _repository.reorderItems(params.collectionId, params.orderedItemIds);
}

class ReorderCollectionItemsParams extends Equatable {
  const ReorderCollectionItemsParams({
    required this.collectionId,
    required this.orderedItemIds,
  });

  final String collectionId;
  final List<String> orderedItemIds;

  @override
  List<Object?> get props => [collectionId, orderedItemIds];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Checks if a shlok is already present in a specific collection.
class IsShlokInCollection
    implements UseCase<bool, IsShlokInCollectionParams> {
  const IsShlokInCollection(this._repository);
  final CollectionRepository _repository;

  @override
  Future<Result<bool>> call(IsShlokInCollectionParams params) =>
      _repository.isShlokInCollection(
        collectionId: params.collectionId,
        shlokId: params.shlokId,
      );
}

class IsShlokInCollectionParams extends Equatable {
  const IsShlokInCollectionParams({
    required this.collectionId,
    required this.shlokId,
  });

  final String collectionId;
  final String shlokId;

  @override
  List<Object?> get props => [collectionId, shlokId];
}
