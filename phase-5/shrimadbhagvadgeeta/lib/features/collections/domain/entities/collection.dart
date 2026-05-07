import 'package:equatable/equatable.dart';

/// Domain entity representing a user-created collection (folder) of verses.
///
/// ## Design Decision: No `bookmarkIds`
/// [Collection] is a pure metadata entity — it knows its own identity but
/// NOT which verses it contains. Verse membership is managed by [CollectionItem].
///
/// This deliberate separation enables:
/// - A verse to belong to multiple collections without duplication
/// - Independent reordering of items within a collection
/// - Deletion of a collection without affecting bookmarks
/// - Clean, future-proof querying (e.g., "all collections containing BG_2_47")
///
/// ## Fields
/// - [id]: UUID generated locally at creation time
/// - [name]: User-defined display name
/// - [createdAt]: When the collection was created
class Collection extends Equatable {
  const Collection({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  /// UUID generated at creation time.
  final String id;

  /// User-defined name. e.g., `"Morning Meditation"`.
  final String name;

  /// When the collection was created (local device time).
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, createdAt];

  Collection copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Collection($id: $name)';
}
