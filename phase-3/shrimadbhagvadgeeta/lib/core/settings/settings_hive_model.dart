import 'package:hive/hive.dart';
import '../../core/data/hive_type_ids.dart';

/// Hive persistence model for app settings.
///
/// Field Order Contract (FIXED — never reorder):
///   [0] themeMode   int  (0=system, 1=light, 2=dark)
///   [1] fontScale   double
class HiveSettingsModel {
  HiveSettingsModel({
    required this.themeMode,
    required this.fontScale,
  });

  final int themeMode;
  final double fontScale;
}

class HiveSettingsModelAdapter extends TypeAdapter<HiveSettingsModel> {
  @override
  final int typeId = HiveTypeIds.settings;

  @override
  HiveSettingsModel read(BinaryReader reader) {
    return HiveSettingsModel(
      themeMode: reader.readInt(),    // [0]
      fontScale: reader.readDouble(), // [1]
    );
  }

  @override
  void write(BinaryWriter writer, HiveSettingsModel obj) {
    writer.writeInt(obj.themeMode);    // [0]
    writer.writeDouble(obj.fontScale); // [1]
  }
}