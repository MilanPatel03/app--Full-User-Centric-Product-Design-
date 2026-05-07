import 'package:hive/hive.dart';

import '../../../../core/data/hive_type_ids.dart';

/// Hive persistence model for a [Collection].
///
/// Field Order Contract (FIXED):
///   [0] id          String
///   [1] name        String
///   [2] createdAt   int  (millisecondsSinceEpoch)
class HiveCollectionModel {
  HiveCollectionModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int createdAt;  // millisecondsSinceEpoch
}

class HiveCollectionModelAdapter extends TypeAdapter<HiveCollectionModel> {
  @override
  final int typeId = HiveTypeIds.collection;

  @override
  HiveCollectionModel read(BinaryReader reader) {
    return HiveCollectionModel(
      id: reader.readString(),    // [0]
      name: reader.readString(),  // [1]
      createdAt: reader.readInt(), // [2]
    );
  }

  @override
  void write(BinaryWriter writer, HiveCollectionModel obj) {
    writer.writeString(obj.id);      // [0]
    writer.writeString(obj.name);    // [1]
    writer.writeInt(obj.createdAt);  // [2]
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Hive persistence model for a [CollectionItem].
///
/// Field Order Contract (FIXED):
///   [0] id            String
///   [1] collectionId  String
///   [2] shlokId       String
///   [3] order         int
///   [4] addedAt       int  (millisecondsSinceEpoch)
class HiveCollectionItemModel {
  HiveCollectionItemModel({
    required this.id,
    required this.collectionId,
    required this.shlokId,
    required this.order,
    required this.addedAt,
  });

  final String id;
  final String collectionId;
  final String shlokId;    // "BG_2_47"
  final int order;
  final int addedAt;       // millisecondsSinceEpoch
}

class HiveCollectionItemModelAdapter
    extends TypeAdapter<HiveCollectionItemModel> {
  @override
  final int typeId = HiveTypeIds.collectionItem;

  @override
  HiveCollectionItemModel read(BinaryReader reader) {
    return HiveCollectionItemModel(
      id: reader.readString(),           // [0]
      collectionId: reader.readString(), // [1]
      shlokId: reader.readString(),      // [2]
      order: reader.readInt(),           // [3]
      addedAt: reader.readInt(),         // [4]
    );
  }

  @override
  void write(BinaryWriter writer, HiveCollectionItemModel obj) {
    writer.writeString(obj.id);           // [0]
    writer.writeString(obj.collectionId); // [1]
    writer.writeString(obj.shlokId);      // [2]
    writer.writeInt(obj.order);           // [3]
    writer.writeInt(obj.addedAt);         // [4]
  }
}
