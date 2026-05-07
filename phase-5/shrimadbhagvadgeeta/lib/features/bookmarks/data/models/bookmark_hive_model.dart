import 'package:hive/hive.dart';

import '../../../../core/data/hive_type_ids.dart';

/// Hive persistence model for a bookmark.
///
/// Field Order Contract (FIXED — never reorder):
///   [0] id          String
///   [1] shlokId     String
///   [2] createdAt   int  (millisecondsSinceEpoch)
///   [3] hasNote     bool (null guard)
///   [4] note        String (only when hasNote == true)
class HiveBookmarkModel {
  HiveBookmarkModel({
    required this.id,
    required this.shlokId,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String shlokId;    // "BG_2_47"
  final int createdAt;     // millisecondsSinceEpoch — avoids DateTime serialization issues
  final String? note;
}

class HiveBookmarkModelAdapter extends TypeAdapter<HiveBookmarkModel> {
  @override
  final int typeId = HiveTypeIds.bookmark;

  @override
  HiveBookmarkModel read(BinaryReader reader) {
    return HiveBookmarkModel(
      id: reader.readString(),   // [0]
      shlokId: reader.readString(), // [1]
      createdAt: reader.readInt(),  // [2]
      note: reader.readBool()       // [3]
          ? reader.readString()     // [4]
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, HiveBookmarkModel obj) {
    writer.writeString(obj.id);      // [0]
    writer.writeString(obj.shlokId); // [1]
    writer.writeInt(obj.createdAt);  // [2]
    writer.writeBool(obj.note != null); // [3]
    if (obj.note != null) {
      writer.writeString(obj.note!); // [4]
    }
  }
}
