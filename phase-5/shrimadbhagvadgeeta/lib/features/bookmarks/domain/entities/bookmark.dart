import 'package:equatable/equatable.dart';

/// Domain entity representing a user's bookmark on a verse.
///
/// ## Design Decision: No `collectionId`
/// A [Bookmark] is a standalone user action — liking/saving a verse.
/// It has NO knowledge of which collection it might belong to.
///
/// Collection membership is modelled separately via [CollectionItem],
/// which holds the `shlokId` → `collectionId` relationship.
/// This allows:
/// - A shlok to be in multiple collections without duplicating bookmarks
/// - Bookmarks to exist independently of any collection
/// - Collections to be reorganised without affecting bookmarks
///
/// ## Fields
/// - [id]: UUID generated locally at creation time
/// - [shlokId]: References the bookmarked verse (e.g., `"BG_2_47"`)
/// - [createdAt]: Local device timestamp — never server time
/// - [note]: Optional personal note — mutable after creation
class Bookmark extends Equatable {
  const Bookmark({
    required this.id,
    required this.shlokId,
    required this.createdAt,
    this.note,
  });

  /// UUID generated at creation time.
  final String id;

  /// The bookmarked verse ID (e.g., `"BG_2_47"`).
  final String shlokId;

  /// When the bookmark was created (local device time).
  final DateTime createdAt;

  /// Optional personal note. Mutable — user can edit after creation.
  final String? note;

  bool get hasNote => note != null && note!.isNotEmpty;

  @override
  List<Object?> get props => [id, shlokId, createdAt, note];

  Bookmark copyWith({
    String? id,
    String? shlokId,
    DateTime? createdAt,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      shlokId: shlokId ?? this.shlokId,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  @override
  String toString() => 'Bookmark($shlokId, hasNote: $hasNote)';
}
