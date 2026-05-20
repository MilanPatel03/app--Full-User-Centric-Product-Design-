import 'package:hive/hive.dart';
import '../../core/data/hive_type_ids.dart';

/// Hive persistence model for app settings.
///
/// ## Field Order Contract (FIXED — never reorder, only append)
///
///   [0] themeMode            int     (0=system, 1=light, 2=dark)
///   [1] fontScale            double
///   [2] showTransliteration  bool    (default: true — added in Step 8)
///   [3] showCommentary       bool    (default: true — added in Step 8)
///
/// ## Backward-Compatibility Rule
///
/// Fields [2] and [3] are NEW. Old Hive records written before Step 8 will
/// not contain these bytes. The adapter's `read()` method uses
/// `reader.remainingLength > 0` to safely fall back to `true` for any
/// field not present in an existing persisted record.
///
/// DO NOT reorder existing fields. DO NOT remove fields. Only append new
/// fields at the end and guard them with `remainingLength > 0`.
class HiveSettingsModel {
  HiveSettingsModel({
    required this.themeMode,
    required this.fontScale,
    required this.showTransliteration,
    required this.showCommentary,
  });

  final int themeMode;
  final double fontScale;
  final bool showTransliteration;
  final bool showCommentary;
}

class HiveSettingsModelAdapter extends TypeAdapter<HiveSettingsModel> {
  @override
  final int typeId = HiveTypeIds.settings;

  @override
  HiveSettingsModel read(BinaryReader reader) {
    // Fields [0] and [1] always exist in every record.
    final themeMode = reader.readInt();    // [0]
    final fontScale = reader.readDouble(); // [1]

    // Fields [2] and [3] were added in Step 8.
    // Existing records won't have these bytes — fall back to true (default on).
    final showTransliteration =
        reader.availableBytes > 0 ? reader.readBool() : true; // [2]
    final showCommentary =
        reader.availableBytes > 0 ? reader.readBool() : true; // [3]

    return HiveSettingsModel(
      themeMode: themeMode,
      fontScale: fontScale,
      showTransliteration: showTransliteration,
      showCommentary: showCommentary,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSettingsModel obj) {
    writer.writeInt(obj.themeMode);              // [0]
    writer.writeDouble(obj.fontScale);           // [1]
    writer.writeBool(obj.showTransliteration);   // [2]
    writer.writeBool(obj.showCommentary);        // [3]
  }
}