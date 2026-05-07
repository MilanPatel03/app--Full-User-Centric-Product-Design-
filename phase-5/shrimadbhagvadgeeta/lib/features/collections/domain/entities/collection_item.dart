import 'package:equatable/equatable.dart';

/// Domain entity representing a verse's membership in a [Collection].
///
/// ## Role in the System
/// [CollectionItem] is the join entity between [Collection] and [Shlok].
/// It models the many-to-many relationship: a shlok can be in multiple
/// collections, and one collection holds many shloks.
///
/// ## Design Decisions
///
/// ### Why not `bookmarkId`?
/// Collection items reference `shlokId` directly — not a bookmark ID.
/// This means:
/// - A verse can be added to a collection regardless of bookmark status
/// - Deleting a bookmark does not cascade-delete collection items
/// - Both systems (bookmarks and collections) are independently useful
///
/// ### Why `order`?
/// Explicit integer ordering (0-indexed) supports:
/// - Manual drag-and-drop reordering
/// - Stable ordering across app restarts
/// - Future import/export of ordered playlists
///
/// ### Why `addedAt`?
/// Separate from [Collection.createdAt] — allows sorting by "recently added"
/// within a collection, independent of collection creation time.
///
/// ## Constraints
/// - [collectionId] and [shlokId] together must be unique (one shlok
///   appears at most once per collection — enforced in the repository)
/// - [order] values within a collection must be contiguous after reorder
///   operations (0, 1, 2, ... n-1)
class CollectionItem extends Equatable {
  const CollectionItem({
    required this.id,
    required this.collectionId,
    required this.shlokId,
    required this.order,
    required this.addedAt,
  });

  /// UUID generated at creation time.
  final String id;

  /// The collection this item belongs to.
  final String collectionId;

  /// The verse referenced by this item (e.g., `"BG_2_47"`).
  final String shlokId;

  /// Display position within the collection (0-indexed).
  /// Lower values appear first. Must be unique per collection.
  final int order;

  /// When this verse was added to the collection.
  final DateTime addedAt;

  @override
  List<Object?> get props => [id, collectionId, shlokId, order, addedAt];

  CollectionItem copyWith({
    String? id,
    String? collectionId,
    String? shlokId,
    int? order,
    DateTime? addedAt,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      shlokId: shlokId ?? this.shlokId,
      order: order ?? this.order,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() =>
      'CollectionItem(collection: $collectionId, shlok: $shlokId, order: $order)';
}
