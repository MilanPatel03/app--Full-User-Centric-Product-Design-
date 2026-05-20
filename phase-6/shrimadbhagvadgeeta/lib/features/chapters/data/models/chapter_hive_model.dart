import 'package:hive/hive.dart';

import '../../../../core/data/hive_type_ids.dart';

/// Hive persistence model for a chapter.
///
/// This is the data layer's on-disk representation — NOT the domain [Chapter].
/// Always convert via [ChapterMapper.fromHive] before passing to domain layer.
///
/// ## Field Order Contract
/// The [HiveChapterModelAdapter] reads/writes fields in a fixed order.
/// This order MUST NEVER change — doing so corrupts stored data.
/// To add new fields: append them at the END of both read() and write().
class HiveChapterModel {
  HiveChapterModel({
    required this.id,
    required this.index,
    required this.title,
    required this.titleSanskrit,
    required this.verseCount,
    this.description,
  });

  final String id;           // "BG_1"
  final int index;           // 1–18
  final String title;
  final String titleSanskrit;
  final int verseCount;
  final String? description;
}

/// Hand-written Hive TypeAdapter — avoids build_runner for persistence models.
///
/// Field read/write sequence (FIXED — never reorder):
///   [0] id            String
///   [1] index         int
///   [2] title         String
///   [3] titleSanskrit String
///   [4] verseCount    int
///   [5] hasDesc       bool    (null guard for optional description)
///   [6] description   String  (only written/read when hasDesc == true)
class HiveChapterModelAdapter extends TypeAdapter<HiveChapterModel> {
  @override
  final int typeId = HiveTypeIds.chapter;

  @override
  HiveChapterModel read(BinaryReader reader) {
    return HiveChapterModel(
      id: reader.readString(),            // [0]
      index: reader.readInt(),            // [1]
      title: reader.readString(),         // [2]
      titleSanskrit: reader.readString(), // [3]
      verseCount: reader.readInt(),       // [4]
      description: reader.readBool()      // [5]
          ? reader.readString()           // [6]
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, HiveChapterModel obj) {
    writer.writeString(obj.id);            // [0]
    writer.writeInt(obj.index);            // [1]
    writer.writeString(obj.title);         // [2]
    writer.writeString(obj.titleSanskrit); // [3]
    writer.writeInt(obj.verseCount);       // [4]
    writer.writeBool(obj.description != null); // [5]
    if (obj.description != null) {
      writer.writeString(obj.description!);    // [6]
    }
  }
}
