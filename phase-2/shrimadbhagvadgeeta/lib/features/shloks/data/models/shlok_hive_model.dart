import 'package:hive/hive.dart';

import '../../../../core/data/hive_type_ids.dart';

/// Hive persistence model for a verse (shlok).
///
/// Mirrors the domain [Shlok] field names exactly — one less mapping to
/// reason about when reading from cache.
///
/// ## Field Order Contract (FIXED — never reorder)
///   [0] id              String
///   [1] chapterId       int
///   [2] verseNumber     int
///   [3] sanskritText    String
///   [4] transliteration String
///   [5] translation     String
///   [6] hasCommentary   bool    (null guard)
///   [7] commentary      String  (only when hasCommentary == true)
class HiveShlokModel {
  HiveShlokModel({
    required this.id,
    required this.chapterId,
    required this.verseNumber,
    required this.sanskritText,
    required this.transliteration,
    required this.translation,
    this.commentary,
  });

  final String id;           // "BG_2_47"
  final int chapterId;       // 2
  final int verseNumber;     // 47
  final String sanskritText;
  final String transliteration;
  final String translation;
  final String? commentary;
}

class HiveShlokModelAdapter extends TypeAdapter<HiveShlokModel> {
  @override
  final int typeId = HiveTypeIds.shlok;

  @override
  HiveShlokModel read(BinaryReader reader) {
    return HiveShlokModel(
      id: reader.readString(),              // [0]
      chapterId: reader.readInt(),          // [1]
      verseNumber: reader.readInt(),        // [2]
      sanskritText: reader.readString(),    // [3]
      transliteration: reader.readString(), // [4]
      translation: reader.readString(),     // [5]
      commentary: reader.readBool()         // [6]
          ? reader.readString()             // [7]
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, HiveShlokModel obj) {
    writer.writeString(obj.id);              // [0]
    writer.writeInt(obj.chapterId);          // [1]
    writer.writeInt(obj.verseNumber);        // [2]
    writer.writeString(obj.sanskritText);    // [3]
    writer.writeString(obj.transliteration); // [4]
    writer.writeString(obj.translation);     // [5]
    writer.writeBool(obj.commentary != null); // [6]
    if (obj.commentary != null) {
      writer.writeString(obj.commentary!);   // [7]
    }
  }
}
