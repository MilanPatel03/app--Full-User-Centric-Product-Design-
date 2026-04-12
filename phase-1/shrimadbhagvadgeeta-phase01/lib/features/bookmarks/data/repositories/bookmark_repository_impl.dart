import '../../../../core/utils/repository_calls.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_data_source.dart';
import '../datasources/bookmark_remote_data_source.dart';
import '../models/bookmark_hive_model.dart';

/// Concrete implementation of [BookmarkRepository].
///
/// ## Sync Strategy: Local-first with async remote mirror
///
/// READ:  Hive only — instant, offline-safe.
/// WRITE: Write to Hive first (returns immediately to UI), then fire-and-forget
///        sync to Supabase. If sync fails, the local data is unaffected — the
///        item will sync on the next app start via [SyncService].
///
/// HYDRATE (app start, when logged in):
///   Fetch remote → overwrite Hive. Called by [SyncService], not this class.
///
/// ## userId nullability
/// When [userId] is null (user not logged in), remote sync is skipped silently.
/// This means bookmarks made while offline/unauthenticated remain local-only
/// until the user logs in AND sync runs.
class BookmarkRepositoryImpl
    with RepositoryCalls
    implements BookmarkRepository {
  const BookmarkRepositoryImpl({
    required BookmarkLocalDataSource local,
    required BookmarkRemoteDataSource remote,
    required String? userId,
  })  : _local = local,
        _remote = remote,
        _userId = userId;

  final BookmarkLocalDataSource _local;
  final BookmarkRemoteDataSource _remote;

  /// Nullable: sync is skipped when the user is not authenticated.
  final String? _userId;

  // ── Read (local only) ────────────────────────────────────────────────────

  @override
  Future<Result<List<Bookmark>>> getBookmarks() =>
      safeLocalRead(() async {
        final models = await _local.getAllBookmarks();
        return models.map(_fromHive).toList();
      });

  @override
  Future<Result<bool>> isBookmarked(String shlokId) =>
      safeLocalRead(() async {
        final model = await _local.getBookmarkByShlokId(shlokId);
        return model != null;
      });

  @override
  Future<Result<Bookmark?>> getBookmarkForShlok(String shlokId) =>
      safeLocalRead(() async {
        final model = await _local.getBookmarkByShlokId(shlokId);
        return model != null ? _fromHive(model) : null;
      });

  // ── Write (local-first + async remote sync) ──────────────────────────────

  @override
  Future<Result<Bookmark>> addBookmark(Bookmark bookmark) =>
      safeLocalRead(() async {
        // 1. Write to Hive immediately — UI updates via reactive stream
        await _local.saveBookmark(_toHive(bookmark));

        // 2. Fire-and-forget remote sync (errors logged, not propagated)
        _syncAdd(bookmark);

        return bookmark;
      });

  @override
  Future<Result<void>> removeBookmark(String bookmarkId) =>
      safeLocalWrite(() async {
        await _local.deleteBookmark(bookmarkId);
        // bookmarkId == shlokId by the app's ID convention (set in ShlokDetailScreen)
        // so we can use it directly as the remote delete key.
        _syncRemove(bookmarkId);
      });

  @override
  Future<Result<Bookmark>> updateBookmark(Bookmark bookmark) =>
      safeLocalRead(() async {
        await _local.updateBookmark(_toHive(bookmark));
        _syncAdd(bookmark); // upsert handles updates too
        return bookmark;
      });

  // ── Reactive stream (local only) ────────────────────────────────────────

  @override
  Stream<List<Bookmark>> watchBookmarks() async* {
    final initial = await _local.getAllBookmarks();
    yield initial.map(_fromHive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await for (final _ in _local.watchChanges()) {
      final updated = await _local.getAllBookmarks();
      yield updated.map(_fromHive).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  // ── Sync helpers (fire-and-forget) ──────────────────────────────────────

  void _syncAdd(Bookmark bookmark) {
    final uid = _userId;
    if (uid == null) return;
    safeRemoteRead(() => _remote.upsertBookmark(uid, bookmark));
  }

  void _syncRemove(String shlokId) {
    final uid = _userId;
    if (uid == null) return;
    safeRemoteRead(() => _remote.deleteBookmark(uid, shlokId));
  }

  // ── Mappers ───────────────────────────────────────────────────────────────

  static Bookmark _fromHive(HiveBookmarkModel m) => Bookmark(
        id: m.id,
        shlokId: m.shlokId,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m.createdAt),
        note: m.note,
      );

  static HiveBookmarkModel _toHive(Bookmark b) => HiveBookmarkModel(
        id: b.id,
        shlokId: b.shlokId,
        createdAt: b.createdAt.millisecondsSinceEpoch,
        note: b.note,
      );
}
