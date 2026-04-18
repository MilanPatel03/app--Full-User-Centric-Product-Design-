/// Sacred Editorial — Application Constants
///
/// Single source of truth for string keys, route paths, and app metadata.
/// Prefer these constants over inline strings to prevent typo bugs.
abstract final class AppConstants {
  // ── App Metadata ──────────────────────────────────────────────────────────
  static const String appName = 'Shrimad Bhagavad Gita';
  static const String appNameSanskrit = 'श्रीमद् भगवद्गीता';
  static const String appVersion = '1.0.0';

  // ── Gita Facts ────────────────────────────────────────────────────────────
  static const int totalChapters = 18;
  static const int totalVerses = 700;

  // ── Hive Box Keys ─────────────────────────────────────────────────────────
  /// Used with: await Hive.openBox(AppConstants.boxChapters)
  static const String boxChapters        = 'chapters';
  static const String boxShloks          = 'shloks';
  static const String boxBookmarks       = 'bookmarks';
  static const String boxCollections     = 'collections';
  static const String boxCollectionItems = 'collection_items';
  static const String boxPendingSync     = 'pending_sync_queue';
  static const String boxSettings        = 'settings';

  // ── GoRouter Route Paths ──────────────────────────────────────────────────
  static const String routeHome = '/';
  static const String routeChapters = '/chapters';
  static const String routeChapterDetail = '/chapters/:chapterId';
  static const String routeShlokDetail =
      '/chapters/:chapterId/verses/:verseId';
  static const String routeSearch = '/search';
  static const String routeBookmarks = '/bookmarks';
  static const String routeCollections = '/collections';
  static const String routeSettings = '/settings';
  static const String routeLogin = '/login';
}
