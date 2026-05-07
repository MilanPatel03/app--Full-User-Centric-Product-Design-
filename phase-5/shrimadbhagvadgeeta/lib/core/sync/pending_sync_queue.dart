import 'package:hive/hive.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hive model — persists a single pending sync operation across sessions
// ─────────────────────────────────────────────────────────────────────────────

class HivePendingSyncModel {
  const HivePendingSyncModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.payload,
    required this.createdAt,
  });

  /// Composite key: `{userId}_{type}_{entityId}`.
  /// Natural idempotency: enqueueing the same logical op overwrites the old one.
  final String id;

  /// Operation type — see [PendingSyncQueue] constants.
  final int type;

  final String userId;

  /// JSON string for upsert ops; bare entity ID for delete ops.
  final String payload;

  /// Epoch ms — used to drain in creation order.
  final int createdAt;
}

class HivePendingSyncModelAdapter extends TypeAdapter<HivePendingSyncModel> {
  @override
  final int typeId = 5;

  @override
  HivePendingSyncModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePendingSyncModel(
      id: fields[0] as String,
      type: fields[1] as int,
      userId: fields[2] as String,
      payload: fields[3] as String,
      createdAt: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HivePendingSyncModel obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.type);
    writer.writeByte(2);
    writer.write(obj.userId);
    writer.writeByte(3);
    writer.write(obj.payload);
    writer.writeByte(4);
    writer.write(obj.createdAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePendingSyncModelAdapter &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => typeId.hashCode;
}

// ─────────────────────────────────────────────────────────────────────────────
// PendingSyncQueue
// ─────────────────────────────────────────────────────────────────────────────

/// Hive-backed queue of sync operations that failed during fire-and-forget.
///
/// ## Idempotency
/// The Hive key is `{userId}_{type}_{entityId}`. Enqueueing the same logical
/// operation twice (e.g., rapid bookmark toggles) overwrites the previous
/// entry — no duplicate work during drain.
///
/// ## Drain
/// [SyncService.hydrate] calls [getPendingForUser] at app start, replays each
/// op via the live remote data sources, and removes successful ones.
/// Failed ops remain in the queue for the next session.
class PendingSyncQueue {
  const PendingSyncQueue(this._box);

  final Box<HivePendingSyncModel> _box;

  // ── Operation type constants ──────────────────────────────────────────────

  static const int upsertBookmark = 0;
  static const int deleteBookmark = 1;
  static const int upsertCollection = 2;
  static const int deleteCollection = 3;
  static const int upsertCollectionItem = 4;
  static const int deleteCollectionItem = 5;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Adds or overwrites a pending operation.
  ///
  /// [entityId]: the shlokId / collectionId / itemId — used as dedup key.
  /// [payload]: JSON for upserts, bare ID string for deletes.
  Future<void> enqueue({
    required int type,
    required String userId,
    required String entityId,
    required String payload,
  }) async {
    final key = '${userId}_${type}_$entityId';
    await _box.put(
      key,
      HivePendingSyncModel(
        id: key,
        type: type,
        userId: userId,
        payload: payload,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Returns all pending ops for [userId] in chronological order.
  List<HivePendingSyncModel> getPendingForUser(String userId) {
    return _box.values
        .where((op) => op.userId == userId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Removes a successfully replayed operation by its composite [id].
  Future<void> remove(String id) => _box.delete(id);
}
