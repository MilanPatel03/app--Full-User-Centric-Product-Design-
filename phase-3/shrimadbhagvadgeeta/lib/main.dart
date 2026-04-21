import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_hive_model.dart';
import 'core/settings/settings_provider.dart';
import 'core/settings/settings_repository.dart';
import 'core/sync/pending_sync_queue.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/providers/auth_state_provider.dart';
import 'features/bookmarks/data/models/bookmark_hive_model.dart';
import 'features/chapters/data/models/chapter_hive_model.dart';
import 'features/collections/data/models/collection_hive_models.dart';
import 'features/shloks/data/models/shlok_hive_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry Point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureSystemUI();

  // ── Step 0: Init Supabase ───────────────────────────────────────────────
  await Supabase.initialize(
    url: 'https://yczxjrzhmemiaodwjctz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljenhqcnpobWVtaWFvZHdqY3R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5MTIyODgsImV4cCI6MjA5MTQ4ODI4OH0.LfDQ3SfnwiioqoOQZA4Oa8AFM7ttYA-4N3J19ZfdX30',
  );

  // ── Step 1: Init Hive ────────────────────────────────────────────────────
  await Hive.initFlutter();

  // ── Step 2: Register all TypeAdapters ───────────────────────────────────
  Hive
    ..registerAdapter(HiveChapterModelAdapter())         // typeId: 0
    ..registerAdapter(HiveShlokModelAdapter())           // typeId: 1
    ..registerAdapter(HiveBookmarkModelAdapter())        // typeId: 2
    ..registerAdapter(HiveCollectionModelAdapter())      // typeId: 3
    ..registerAdapter(HiveCollectionItemModelAdapter())  // typeId: 4
    ..registerAdapter(HivePendingSyncModelAdapter())     // typeId: 5
    ..registerAdapter(HiveSettingsModelAdapter());       // typeId: 6

  // ── Step 3: Open all Hive boxes ──────────────────────────────────────────
  final chapterBox = await Hive.openBox<HiveChapterModel>(
    AppConstants.boxChapters,
  );
  final shlokBox = await Hive.openBox<HiveShlokModel>(
    AppConstants.boxShloks,
  );
  final bookmarkBox = await Hive.openBox<HiveBookmarkModel>(
    AppConstants.boxBookmarks,
  );
  final collectionBox = await Hive.openBox<HiveCollectionModel>(
    AppConstants.boxCollections,
  );
  final collectionItemBox = await Hive.openBox<HiveCollectionItemModel>(
    AppConstants.boxCollectionItems,
  );
  final pendingSyncBox = await Hive.openBox<HivePendingSyncModel>(
    AppConstants.boxPendingSync,
  );
  final settingsBox = await Hive.openBox<HiveSettingsModel>(
    AppConstants.boxSettings,
  );

  // ── Step 4: Build settings repository eagerly so themeMode is available
  //            synchronously before the first frame.
  final settingsRepo = SettingsRepository(settingsBox);
  final initialSettings = settingsRepo.load();

  // ── Step 5: Launch app ────────────────────────────────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        chapterBoxProvider.overrideWithValue(chapterBox),
        shlokBoxProvider.overrideWithValue(shlokBox),
        bookmarkBoxProvider.overrideWithValue(bookmarkBox),
        collectionBoxProvider.overrideWithValue(collectionBox),
        collectionItemBoxProvider.overrideWithValue(collectionItemBox),
        pendingSyncBoxProvider.overrideWithValue(pendingSyncBox),
        settingsBoxProvider.overrideWithValue(settingsBox),
        // Override the stub from settings_provider.dart with the real instance
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        // Seed the notifier with persisted state so first frame is correct
        settingsProvider.overrideWith(() {
          final notifier = SettingsNotifier();
          return notifier;
        }),
      ],
      child: GeetaApp(initialThemeMode: initialSettings.themeMode),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// System UI
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _configureSystemUI() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceContainerLow,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Root Widget
// ─────────────────────────────────────────────────────────────────────────────

class GeetaApp extends ConsumerWidget {
  const GeetaApp({super.key, required this.initialThemeMode});

  /// Passed from main() so the first frame uses the correct theme
  /// without waiting for the Riverpod notifier to initialise.
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncTriggerProvider);

    final router = ref.watch(routerProvider);

    // Watch themeMode reactively — changes from ProfileScreen apply immediately.
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}