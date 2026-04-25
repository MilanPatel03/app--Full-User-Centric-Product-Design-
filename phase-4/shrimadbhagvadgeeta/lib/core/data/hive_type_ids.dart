/// Centralised Hive type ID registry.
///
/// ALL Hive TypeAdapter typeId values must be declared here.
/// This prevents accidental ID collisions across features.
///
/// Rules:
///   - IDs are stable — never change a registered ID
///   - IDs are unique — never reuse a deleted ID
///   - New models append to the end of this list
///   - Register adapters in main.dart using these constants
abstract final class HiveTypeIds {
  static const int chapter        = 0;
  static const int shlok          = 1;
  static const int bookmark       = 2;
  static const int collection     = 3;
  static const int collectionItem = 4;
  // 5 is used by HivePendingSyncModelAdapter (declared inline in pending_sync_queue.dart)
  static const int settings       = 6;
}