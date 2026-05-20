import 'package:hive/hive.dart';

import '../../../../core/data/hive_type_ids.dart';

/// Hive persistence model for app settings.
///
/// Field Order Contract (FIXED — never reorder):
///   [0] themeMode           int     (0=system, 1=light, 2=dark)
///   [1] fontScale           double
///   [2] showTransliteration bool
///   [3] showCommentary      bool
///
/// Fields [2] and [3] are NEW. Old records that lack them will fail to
/// read fields [2] and [3]. The adapter uses a safe fallback read pattern:
/// if the reader has already consumed all bytes, it defaults to `true` for
/// both toggles so existing users are unaffected.
class HiveSettingsModel {
  HiveSettingsModel({
    required this.themeMode,
    required this.fontScale,
    this.showTransliteration = true,
    this.showCommentary = true,
  });

  final int themeMode;
  final double fontScale;
  final bool showTransliteration;
  final bool showCommentary;
}

class HiveSettingsModelAdapter extends TypeAdapter<HiveSettingsModel> {
  @override
  final int typeId = HiveTypeIds.settings; // 6

  @override
  HiveSettingsModel read(BinaryReader reader) {
    final themeMode = reader.readInt();    // [0]
    final fontScale = reader.readDouble(); // [1]

    // Safe-read the new boolean fields. Old records written before these
    // fields existed will have no remaining bytes here. We catch the
    // RangeError and fall back to defaults so migration is seamless.
    bool showTransliteration = true;
    bool showCommentary = true;
    try {
      showTransliteration = reader.readBool(); // [2]
      showCommentary = reader.readBool();       // [3]
    } catch (_) {
      // Old record — use defaults. New values will be written on next save.
    }

    return HiveSettingsModel(
      themeMode: themeMode,
      fontScale: fontScale,
      showTransliteration: showTransliteration,
      showCommentary: showCommentary,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSettingsModel obj) {
    writer.writeInt(obj.themeMode);                  // [0]
    writer.writeDouble(obj.fontScale);               // [1]
    writer.writeBool(obj.showTransliteration);       // [2]
    writer.writeBool(obj.showCommentary);            // [3]
  }
}
