import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_repository.dart';
import 'settings_state.dart';

/// Notifier that owns [SettingsState] and persists changes to Hive.
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setShowTransliteration(bool value) async {
    state = state.copyWith(showTransliteration: value);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setShowCommentary(bool value) async {
    state = state.copyWith(showCommentary: value);
    await ref.read(settingsRepositoryProvider).save(state);
  }
}

/// The single global settings provider. Never autoDispose — must live for the
/// full app lifetime so GeetaApp can read themeMode reactively.
final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

// ── Granular derived providers ──────────────────────────────────────────────
// Each widget only rebuilds on the specific field it cares about.

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsProvider).themeMode,
);

final fontScaleProvider = Provider<double>(
  (ref) => ref.watch(settingsProvider).fontScale,
);

final showTransliterationProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).showTransliteration,
);

final showCommentaryProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).showCommentary,
);

/// Repository provider — overridden in ProviderScope with the opened Hive box.
/// Declared here to break circular imports; overridden in app_providers.dart.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => throw UnimplementedError('settingsRepositoryProvider must be overridden.'),
  name: 'settingsRepositoryProvider',
);