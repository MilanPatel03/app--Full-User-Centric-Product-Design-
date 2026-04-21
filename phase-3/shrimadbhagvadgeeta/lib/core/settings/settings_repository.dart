import 'package:hive/hive.dart';
import 'settings_hive_model.dart';
import 'settings_state.dart';

/// Reads and writes [SettingsState] to a Hive box.
///
/// Uses a single key ('prefs') since there is only one settings record.
class SettingsRepository {
  const SettingsRepository(this._box);

  final Box<HiveSettingsModel> _box;

  static const String _key = 'prefs';

  /// Returns persisted settings, or defaults if nothing is saved yet.
  SettingsState load() {
    final model = _box.get(_key);
    if (model == null) return const SettingsState();
    return SettingsState(
      themeMode: SettingsState.intToThemeMode(model.themeMode),
      fontScale: model.fontScale,
    );
  }

  /// Persists [state] to Hive synchronously.
  Future<void> save(SettingsState state) async {
    await _box.put(
      _key,
      HiveSettingsModel(
        themeMode: SettingsState.themeModeToInt(state.themeMode),
        fontScale: state.fontScale,
      ),
    );
  }
}