import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_item.dart';

/// Contract for remote collection operations (Supabase).
abstract class CollectionRemoteDataSource {
  Future<List<Collection>> getCollections(String userId);
  Future<void> upsertCollection(String userId, Collection collection);
  Future<void> deleteCollection(String userId, String collectionId);

  Future<List<CollectionItem>> getItemsForCollection(
      String userId, String collectionId);
  Future<void> upsertCollectionItem(
      String userId, CollectionItem item);
  Future<void> deleteCollectionItem(String userId, String itemId);
}

// ─────────────────────────────────────────────────────────────────────────────
// Supabase implementation
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseCollectionRemoteDataSource
    implements CollectionRemoteDataSource {
  const SupabaseCollectionRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _collectionsTable = 'collections';
  static const String _itemsTable = 'collection_items';

  // ── Collections ────────────────────────────────────────────────────────────

  @override
  Future<List<Collection>> getCollections(String userId) async {
    final rows = await _client
        .from(_collectionsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (rows as List)
        .map((row) => _collectionFromRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> upsertCollection(
      String userId, Collection collection) async {
    await _client.from(_collectionsTable).upsert(
      _collectionToRow(userId, collection),
      onConflict: 'id',
    );
  }

  @override
  Future<void> deleteCollection(String userId, String collectionId) async {
    // Cascade delete of items is handled by Supabase FK constraint.
    await _client
        .from(_collectionsTable)
        .delete()
        .eq('user_id', userId)
        .eq('id', collectionId);
  }

  // ── Collection Items ───────────────────────────────────────────────────────

  @override
  Future<List<CollectionItem>> getItemsForCollection(
      String userId, String collectionId) async {
    final rows = await _client
        .from(_itemsTable)
        .select()
        .eq('user_id', userId)
        .eq('collection_id', collectionId)
        .order('order');

    return (rows as List)
        .map((row) => _itemFromRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> upsertCollectionItem(
      String userId, CollectionItem item) async {
    await _client.from(_itemsTable).upsert(
      _itemToRow(userId, item),
      onConflict: 'id',
    );
  }

  @override
  Future<void> deleteCollectionItem(String userId, String itemId) async {
    await _client
        .from(_itemsTable)
        .delete()
        .eq('user_id', userId)
        .eq('id', itemId);
  }

  // ── Row mappers ────────────────────────────────────────────────────────────

  static Collection _collectionFromRow(Map<String, dynamic> row) => Collection(
        id: row['id'] as String,
        name: row['name'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );

  static Map<String, dynamic> _collectionToRow(
          String userId, Collection c) =>
      {
        'id': c.id,
        'user_id': userId,
        'name': c.name,
        'created_at': c.createdAt.toIso8601String(),
      };

  static CollectionItem _itemFromRow(Map<String, dynamic> row) =>
      CollectionItem(
        id: row['id'] as String,
        collectionId: row['collection_id'] as String,
        shlokId: row['shlok_id'] as String,
        order: row['order'] as int,
        addedAt: DateTime.parse(row['added_at'] as String),
      );

  static Map<String, dynamic> _itemToRow(
          String userId, CollectionItem item) =>
      {
        'id': item.id,
        'user_id': userId,
        'collection_id': item.collectionId,
        'shlok_id': item.shlokId,
        'order': item.order,
        'added_at': item.addedAt.toIso8601String(),
      };
}
