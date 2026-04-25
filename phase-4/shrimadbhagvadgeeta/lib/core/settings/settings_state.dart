import 'package:flutter/material.dart';

/// Domain entity representing the user's persisted app preferences.
///
/// [themeMode]: system / light / dark
/// [fontScale]: multiplier for NotoSerif/NotoSerifDevanagari reading text.
///   1.0 = normal, 0.85 = small, 1.15 = large, 1.30 = extra large.
///   Inter (UI utility) is never scaled.
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.fontScale = 1.0,
  });

  final ThemeMode themeMode;

  /// Reading text scale factor. Applied to NotoSerif and NotoSerifDevanagari
  /// styles only — never to Inter utility text.
  final double fontScale;

  /// Available font scale steps shown in the UI.
  static const List<({String label, double value})> fontScaleSteps = [
    (label: 'S', value: 0.85),
    (label: 'A', value: 1.0),
    (label: 'A', value: 1.15),
    (label: 'A', value: 1.30),
  ];

  SettingsState copyWith({ThemeMode? themeMode, double? fontScale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  /// Encode ThemeMode as int for Hive storage.
  static int themeModeToInt(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 0,
    ThemeMode.light => 1,
    ThemeMode.dark => 2,
  };

  static ThemeMode intToThemeMode(int v) => switch (v) {
    0 => ThemeMode.system,
    1 => ThemeMode.light,
    _ => ThemeMode.dark,
  };
}