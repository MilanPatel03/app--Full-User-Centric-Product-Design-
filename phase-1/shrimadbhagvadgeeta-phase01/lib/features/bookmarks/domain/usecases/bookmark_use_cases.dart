import 'package:equatable/equatable.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmark_repository.dart';

/// Returns all bookmarks sorted by creation date (newest first).
class GetBookmarks implements UseCase<List<Bookmark>, NoParams> {
  const GetBookmarks(this._repository);
  final BookmarkRepository _repository;

  @override
  Future<Result<List<Bookmark>>> call(NoParams params) =>
      _repository.getBookmarks();
}

// ─────────────────────────────────────────────────────────────────────────────

/// Checks whether a specific verse is bookmarked.
class IsBookmarked implements UseCase<bool, IsBookmarkedParams> {
  const IsBookmarked(this._repository);
  final BookmarkRepository _repository;

  @override
  Future<Result<bool>> call(IsBookmarkedParams params) =>
      _repository.isBookmarked(params.shlokId);
}

class IsBookmarkedParams extends Equatable {
  const IsBookmarkedParams(this.shlokId);
  final String shlokId; // "BG_X_Y" format

  @override
  List<Object?> get props => [shlokId];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Fetches the bookmark for a specific verse, if it exists.
/// Returns null (not Err) when the verse is not bookmarked.
class GetBookmarkForShlok
    implements UseCase<Bookmark?, GetBookmarkForShlokParams> {
  const GetBookmarkForShlok(this._repository);
  final BookmarkRepository _repository;

  @override
  Future<Result<Bookmark?>> call(GetBookmarkForShlokParams params) =>
      _repository.getBookmarkForShlok(params.shlokId);
}

class GetBookmarkForShlokParams extends Equatable {
  const GetBookmarkForShlokParams(this.shlokId);
  final String shlokId;

  @override
  List<Object?> get props => [shlokId];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Adds a new bookmark.
/// The caller is responsible for setting [Bookmark.id] and [Bookmark.createdAt].
class AddBookmark implements UseCase<Bookmark, AddBookmarkParams> {
  const AddBookmark(this._repository);
  final BookmarkRepository _repository;

  @override
  Future<Result<Bookmark>> call(AddBookmarkParams params) =>
      _repository.addBookmark(params.bookmark);
}

class AddBookmarkParams extends Equatable {
  const AddBookmarkParams(this.bookmark);
  final Bookmark bookmark;

  @override
  List<Object?> get props => [bookmark];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Removes a bookmark permanently.
class RemoveBookmark implements UseCase<void, RemoveBookmarkParams> {
  const RemoveBookmark(this._repository);
  final BookmarkRepository _repository;

  @override
  Future<Result<void>> call(RemoveBookmarkParams params) =>
      _repository.removeBookmark(params.bookmarkId);
}

class RemoveBookmarkParams extends Equatable {
  const RemoveBookmarkParams(this.bookmarkId);
  final String bookmarkId;

  @override
  List<Object?> get props => [bookmarkId];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Updates a bookmark's personal note. Only [Bookmark.note] is mutable.
class UpdateBookmark implements UseCase<Bookmark, UpdateBookmarkParams> {
  const UpdateBookmark(this._repository);
  final BookmarkRepository _repository;

  @override
  Future<Result<Bookmark>> call(UpdateBookmarkParams params) =>
      _repository.updateBookmark(params.bookmark);
}

class UpdateBookmarkParams extends Equatable {
  const UpdateBookmarkParams(this.bookmark);
  final Bookmark bookmark;

  @override
  List<Object?> get props => [bookmark];
}
