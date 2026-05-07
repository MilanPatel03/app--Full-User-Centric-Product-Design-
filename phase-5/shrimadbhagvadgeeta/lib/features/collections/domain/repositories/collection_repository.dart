import '../../../../core/utils/result.dart';
import '../entities/collection.dart';
import '../entities/collection_item.dart';

/// Domain contract for collection and collection-item data access.
///
/// ## Two-Entity Model
/// This repository manages both [Collection] (folder metadata) and
/// [CollectionItem] (verse membership). They are kept in a single
/// repository because they represent one aggregate root — a collection
/// is meaningless without its items, and items cannot exist without
/// their parent collection.
///
/// ## Uniqueness Constraint
/// The combination of `(collectionId, shlokId)` must be unique.
/// A shlok appears at most once per collection.
/// The implementation must enforce this and return [ValidationFailure]
/// if a duplicate add is attempted.
///
/// ## Ordering Contract
/// After any [reorderItems] call, item [CollectionItem.order] values
/// must be contiguous: 0, 1, 2, ... (n-1).
/// The implementation is responsible for maintaining this invariant.
///
/// ## Repository Purity Rule
/// Returns ONLY [Collection] and [CollectionItem] domain entities.
/// Never Hive objects, DTOs, or API models.
abstract interface class CollectionRepository {
  // ── Collection CRUD ──────────────────────────────────────────────────────

  /// Fetch all collections, sorted by [Collection.createdAt] ascending.
  Future<Result<List<Collection>>> getCollections();

  /// Fetch a single collection by its ID.
  Future<Result<Collection>> getCollectionById(String collectionId);

  /// Create a new collection.
  /// [Collection.id] and [Collection.createdAt] must be set by the caller.
  Future<Result<Collection>> createCollection(Collection collection);

  /// Rename a collection.
  /// Only [Collection.name] is mutable after creation.
  Future<Result<Collection>> updateCollection(Collection collection);

  /// Permanently delete a collection AND all its [CollectionItem]s.
  /// Does NOT affect bookmarks.
  Future<Result<void>> deleteCollection(String collectionId);

  // ── Collection Items ──────────────────────────────────────────────────────

  /// Fetch all items in a collection, sorted by [CollectionItem.order] ascending.
  Future<Result<List<CollectionItem>>> getItemsForCollection(
      String collectionId);

  /// Add a shlok to a collection.
  /// New items are appended at the end (highest [CollectionItem.order] + 1).
  /// Returns [ValidationFailure] if the shlok is already in the collection.
  Future<Result<CollectionItem>> addItemToCollection(CollectionItem item);

  /// Remove a shlok from a collection by the [CollectionItem.id].
  /// The implementation must re-compact order values after removal.
  Future<Result<void>> removeItemFromCollection(String itemId);

  /// Reorder items within a collection.
  ///
  /// [orderedItemIds]: item IDs in the desired display order.
  /// index 0 = first displayed, index n = last displayed.
  /// The implementation assigns `order = index` for each item.
  Future<Result<void>> reorderItems(
    String collectionId,
    List<String> orderedItemIds,
  );

  /// Check if a shlok is already in a specific collection.
  Future<Result<bool>> isShlokInCollection({
    required String collectionId,
    required String shlokId,
  });

  // ── Real-time Streams ────────────────────────────────────────────────────

  /// Real-time stream of all collections.
  Stream<List<Collection>> watchCollections();

  /// Real-time stream of items in a specific collection.
  /// Emits when items are added, removed, or reordered.
  Stream<List<CollectionItem>> watchItemsForCollection(String collectionId);
}
