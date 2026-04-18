import 'dart:convert';

import '../../../../core/sync/pending_sync_queue.dart';
import '../../../../core/utils/repository_calls.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_data_source.dart';
import '../datasources/bookmark_remote_data_source.dart';
import '../models/bookmark_hive_model.dart';

/// Concrete implementation of [BookmarkRepository].
///
/// ## Sync Strategy: Local-first with async remote mirror + retry queue
///
/// READ:  Hive only — instant, offline-safe.
/// WRITE: Write to Hive first (returns immediately to UI), then fire-and-forget
///        sync to Supabase. If sync fails, the operation is pushed into
///        [PendingSyncQueue] and replayed on the next app start via [SyncService].
///
/// HYDRATE (app start, when logged in):
///   [SyncService] drains the queue first, then pulls remote → Hive.
class BookmarkRepositoryImpl
    with RepositoryCalls
    implements BookmarkRepository {
  const BookmarkRepositoryImpl({
    required BookmarkLocalDataSource local,
    required BookmarkRemoteDataSource remote,
    required String? userId,
    required PendingSyncQueue queue,
  })  : _local = local,
        _remote = remote,
        _userId = userId,
        _queue = queue;

  final BookmarkLocalDataSource _local;
  final BookmarkRemoteDataSource _remote;

  /// Null when unauthenticated — sync ops are skipped silently.
  final String? _userId;

  final PendingSyncQueue _queue;

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

  // ── Write (local-first + async remote sync with queue fallback) ───────────
  // Rule: use safeLocalRead<T> when the callback returns T (non-void).
  //       use safeLocalWrite  when the callback is void.

  @override
  Future<Result<Bookmark>> addBookmark(Bookmark bookmark) =>
      safeLocalRead(() async {
        await _local.saveBookmark(_toHive(bookmark));
        _syncAdd(bookmark);
        return bookmark;
      });

  @override
  Future<Result<Bookmark>> updateBookmark(Bookmark bookmark) =>
      safeLocalRead(() async {
        await _local.updateBookmark(_toHive(bookmark));
        _syncAdd(bookmark); // upsert handles updates
        return bookmark;
      });

  @override
  Future<Result<void>> removeBookmark(String bookmarkId) =>
      safeLocalWrite(() async {
        await _local.deleteBookmark(bookmarkId);
        // bookmarkId == shlokId by this app's ID convention (ShlokDetailScreen)
        _syncRemove(bookmarkId);
      });

  // ── Reactive stream (local only) ──────────────────────────────────────────

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

  // ── Fire-and-forget sync with queue fallback ──────────────────────────────

  void _syncAdd(Bookmark bookmark) {
    final uid = _userId;
    if (uid == null) return;

    safeRemoteRead(() => _remote.upsertBookmark(uid, bookmark))
        .then((result) {
      if (result case Err()) {
        _queue.enqueue(
          type: PendingSyncQueue.upsertBookmark,
          userId: uid,
          entityId: bookmark.id,
          payload: json.encode({
            'id': bookmark.id,
            'shlok_id': bookmark.shlokId,
            'created_at': bookmark.createdAt.millisecondsSinceEpoch,
            if (bookmark.note != null) 'note': bookmark.note,
          }),
        );
      }
    });
  }

  void _syncRemove(String shlokId) {
    final uid = _userId;
    if (uid == null) return;

    safeRemoteRead(() => _remote.deleteBookmark(uid, shlokId))
        .then((result) {
      if (result case Err()) {
        _queue.enqueue(
          type: PendingSyncQueue.deleteBookmark,
          userId: uid,
          entityId: shlokId,
          payload: shlokId,
        );
      }
    });
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
