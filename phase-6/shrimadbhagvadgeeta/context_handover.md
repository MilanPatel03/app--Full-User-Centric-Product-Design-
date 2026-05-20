# Project Overview
**Name:** Shrimad Bhagavad Gita App  
**Goal:** A production-grade, offline-first Bhagavad Gita reading application built with a focus on a serene, manuscript-like "Sacred Editorial" aesthetic. It aims for high performance, deep architectural cleanliness, and a meditative reading experience.  
**Current Progress Stage:** The core Clean Architecture layers are fully established. Features implemented include Chapters, Shlok lists, Shlok detail view, Bookmarks, Collections, Local Storage (Hive), and Remote Sync / Authentication (Supabase). We have just completed **Step 6 (Authentication + Backend Sync)** and the codebase has zero analysis issues.

---

# Tech Stack
- **Framework:** Flutter (latest stable, uses `uses-material-design: true` but heavily overrides Material defaults)
- **State Management:** Riverpod 2.x (`flutter_riverpod`, with code-gen dependencies available but largely using plain providers/notifiers currently for transparency)
- **Local Storage:** Hive (`hive`, `hive_flutter`) for offline-first caching of text and user data.
- **Backend/Auth:** Supabase (`supabase_flutter`) for user authentication and cloud syncing of bookmarks/collections.
- **Networking:** Dio (for remote data-fetching of Gita text, currently set up alongside Supabase).
- **Navigation:** GoRouter for declarative, deep-link ready routing.
- **Design System:** "The Sacred Editorial" (custom colors, no lines/borders, tonal surfaces, custom bundled typography: Noto Serif Devanagari & Inter).

---

# Architecture
Strict Clean Architecture applied consistently:
- **Presentation:** Riverpod providers, UI screens, widgets. Scoped state, no global mutants.
- **Domain:** Minimal entities (`AppUser`, `Shlok`, `Chapter`, `Bookmark`, `Collection`), repository interfaces, and UseCases (e.g., `GetChapters`, `Login`, `AddBookmark`).
- **Data:** DTOs, Local Data Sources (Hive), Remote Data Sources (Dio/Supabase), and Repository Implementations mapping DTOs to Domain Entities.

## Folder Structure (High Level)
```
lib/
├── core/
│   ├── constants/
│   ├── errors/ (failures.dart)
│   ├── network/
│   ├── providers/ (app_providers.dart)
│   ├── router/ (app_router.dart)
│   ├── sync/ (sync_service.dart)
│   ├── theme/
│   └── utils/ (result.dart, repository_calls.dart)
├── features/
│   ├── auth/ (domain, data, presentation)
│   ├── bookmarks/ (domain, data, presentation)
│   ├── chapters/ (domain, data, presentation)
│   ├── collections/ (domain, data, presentation)
│   ├── settings/ (presentation placeholders)
│   └── shloks/ (domain, data, presentation)
└── main.dart
```

## Data Flow
`UI` → calls `Riverpod / UseCase` → `RepositoryImpl` → reads/writes `LocalDataSource` (Hive) + triggers fire-and-forget sync to `RemoteDataSource` (Supabase).  
Results are wrapped in a sealed `Result<T>` class (`Ok<T>` or `Err<T>`) mapping to `Failure` types. Exceptions do not bubble to the UI.

---

# Features Implemented
1. **Design System Engine:** Tonal surfaces (`SectionContainer`), offline bundled typography, specific layout components (`EditorialLayout`, `EditorialHeader`).
2. **Chapters:** Chapter list fetching and UI (`ChaptersScreen`, `ChapterCard`).
3. **Verses (Shloks):** List view (`ShlokListScreen`) and Detail view (`ShlokDetailScreen`) with Sanskrit focus, transliteration, and translation.
4. **Local Data Persistence:** Complete Hive integration with `TypeAdapter`s for all entities.
5. **Bookmarks & Collections:** Domain layers, Hive mapping, and a reactive UI via StreamProviders. Bookmarking a verse works directly from `ShlokDetailScreen`.
6. **Authentication:** Supabase email/password auth login/signup UI (`LoginScreen`).
7. **Cloud Sync Strategy:** 
   - `SyncService` runs on app start/login.
   - Remote → overwrites Hive on hydration.
   - Local additions/deletions → write instantly to Hive, fire-and-forget `upsert`/`delete` to Supabase.

---

# Features In Progress / Next Up
- **Settings Screen (Step 7):** Integrating theme selection (Light/Dark mode) and reading preferences (font scaling). Currently just a placeholder route.
- **Search Screen:** The route `/search` exists and `SearchShloks` use case exists, needs UI wiring.
- **Collections UI:** A bottom sheet or dedicated UI to manage grouping bookmarks into collections.

---

# Current Problem / Blocker
- **No immediate technical blockers.** `flutter analyze` returns 0 issues. 
- **Missing configuration:** The Supabase URL and Anon Key need to be populated in `main.dart`, and the corresponding SQL schema migrations must be run on the backend.
- **Font Assets:** The typography relies on local fonts. If they haven't been downloaded via the provided `scripts/download_fonts.ps1`, text won't render correctly.

---

# Attempts So Far / Resolved Issues
- **Riverpod Circular Dependency:** We resolved a circular import between `app_providers.dart` (which holds repositories) and `auth_state_provider.dart` (which holds the current user state) by letting `bookmarkRepositoryProvider` watch a specific `currentUserIdProvider` derived correctly.
- **Routing flash on Startup:** Implemented `GoRouter.redirect` logic that returns `null` while `authStateProvider` is `AsyncLoading`. This prevents the app from flashing the login screen while Supabase parses the local user session.
- **No-Lines Rule Execution:** Adhered strictly to the Sacred Editorial guidelines by removing all `AppBar`, `ListTile`, and `Divider` components, opting instead for pure surface layering (`SurfaceTier`) and whitespace spacing (`AppSpacing`).

---

# Important Code Snippets

**Result/Failure Pattern (Domain Layer):**
```dart
sealed class Result<T> { ... }
final class Ok<T> extends Result<T> { ... }
final class Err<T> extends Result<T> { ... }
```

**Sync-Aware Repository Wiring (app_providers.dart):**
```dart
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return BookmarkRepositoryImpl(
    local: ref.watch(bookmarkLocalDsProvider),
    remote: ref.watch(bookmarkRemoteDsProvider),
    userId: userId, // Skips sync operations if null
  );
});
```

**Sync Trigger (auth_state_provider.dart):**
```dart
final syncTriggerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
    (previous, next) async {
      final prevUser = previous?.valueOrNull;
      final nextUser = next.valueOrNull;
      if (prevUser == null && nextUser != null) {
        await ref.read(syncServiceProvider).hydrate(nextUser.id);
      }
    },
  );
});
```

---

# Assumptions & Decisions
- **Offline First Priority:** App behaves as if Supabase does not exist when offline or unauthenticated. Hive is the single source of truth for the UI.
- **Bookmark UUID:** The shlok ID (e.g., `BG_2_47`) acts as the Bookmark ID, meaning each verse can logically only be bookmarked once per user. Fast, simple, and removes the need for UUID package.
- **Cascade Deletes:** Supabase handles deleting elements in `collection_items` when the parent `collection` is deleted to prevent client-side multi-table orchestration.

---

# Next Steps
1. **Pre-flight Checks:** Feed Supabase keys into `main.dart` and deploy SQL schemas to Supabase dashboard.
2. **Implement Settings:** Wire up `SharedPreferences` or Hive to persist local UX preferences, update `GeetaApp` to listen to theme changes.
3. **Build the Collections UI:** Complete the `CollectionsScreen` and a mechanism to add a Shlok to a specific collection from the `ShlokDetailScreen`.
4. **Implement Search:** Complete the `SearchScreen` UI using the `SearchShloks` use case.

---

# Notes for Next Chat
- **Do not modify the architecture:** Keep Domain pure. DTOs and API concepts MUST remain in Data layer.
- **Do not introduce generic Material designs:** Forms, text, and layouts must use the bespoke widgets like `EditorialLayout`, `SectionContainer`, and `AppTypography`. The app uses custom animations (300ms 'meditative' pacing).
- **Do not add new packages unnecessarily:** Use `Result/Failure` instead of Freezed unions for state/error wrapping. Use existing abstractions.
