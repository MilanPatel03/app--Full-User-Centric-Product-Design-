import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/bookmark.dart';

/// Contract for remote bookmark operations (Supabase).
abstract class BookmarkRemoteDataSource {
  /// Fetches all bookmarks for the given user from Supabase.
  Future<List<Bookmark>> getBookmarks(String userId);

  /// Upserts (insert or update) a bookmark for the given user.
  Future<void> upsertBookmark(String userId, Bookmark bookmark);

  /// Deletes a bookmark by its [shlokId] for the given user.
  Future<void> deleteBookmark(String userId, String shlokId);
}

// ─────────────────────────────────────────────────────────────────────────────
// Supabase implementation
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseBookmarkRemoteDataSource implements BookmarkRemoteDataSource {
  const SupabaseBookmarkRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _table = 'bookmarks';

  @override
  Future<List<Bookmark>> getBookmarks(String userId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> upsertBookmark(String userId, Bookmark bookmark) async {
    await _client.from(_table).upsert(
      _toRow(userId, bookmark),
      onConflict: 'id',
    );
  }

  @override
  Future<void> deleteBookmark(String userId, String shlokId) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('shlok_id', shlokId);
  }

  // ── Row mappers ────────────────────────────────────────────────────────────

  static Bookmark _fromRow(Map<String, dynamic> row) => Bookmark(
        id: row['id'] as String,
        shlokId: row['shlok_id'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        note: row['note'] as String?,
      );

  static Map<String, dynamic> _toRow(String userId, Bookmark b) => {
        'id': b.id,
        'user_id': userId,
        'shlok_id': b.shlokId,
        'created_at': b.createdAt.toIso8601String(),
        if (b.note != null) 'note': b.note,
      };
}
