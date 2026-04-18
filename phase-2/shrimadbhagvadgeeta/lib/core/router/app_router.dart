import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/chapters/presentation/screens/chapters_screen.dart';
import '../../features/shloks/presentation/screens/shlok_detail_screen.dart';
import '../../features/shloks/presentation/screens/shlok_list_screen.dart';
import '../../features/shloks/presentation/screens/search_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';
import '../../features/collections/presentation/screens/collections_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../constants/app_constants.dart';

/// Routes that require authentication. Unauthenticated users are redirected
/// to [AppConstants.routeLogin].
const _protectedRoutes = {
  AppConstants.routeBookmarks,
  AppConstants.routeCollections,
};

/// Application router — declarative, deep-link ready.
///
/// ## Route hierarchy
/// ```
/// /              → ChaptersScreen
/// /chapter/:id   → ShlokListScreen
/// /chapter/:cid/verse/:sid → ShlokDetailScreen
/// /search        → SearchScreen
/// /bookmarks     → BookmarksScreen  [PROTECTED]
/// /collections   → CollectionsScreen [PROTECTED]
/// /settings      → SettingsScreen
/// /login         → LoginScreen
/// ```
///
/// ## Auth Redirect
/// [GoRouter.redirect] is called on every navigation. If [authStateProvider]
/// has not yet loaded (AsyncLoading), we return null (no redirect — let it
/// load). This prevents a flash to the login screen on app start while
/// Supabase restores the session from storage.
final routerProvider = Provider<GoRouter>((ref) {
  // Notify GoRouter of auth state changes so redirect() re-runs on login/logout
  final authListenable = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: AppConstants.routeHome,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,

    // ── Auth guard ─────────────────────────────────────────────────────────
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);

      // Still loading session — do not redirect (prevents flash)
      if (authAsync.isLoading) return null;

      final isAuthenticated = authAsync.valueOrNull != null;
      final location = state.uri.path;
      final goingToLogin = location == AppConstants.routeLogin;

      final isProtected = _protectedRoutes.any(
            (route) => location.startsWith(route),
      );

      // 1. Unauthenticated → protected route: redirect to login
      if (!isAuthenticated && isProtected) {
        return AppConstants.routeLogin;
      }

      // 2. Authenticated → login screen: redirect to home
      if (isAuthenticated && goingToLogin) {
        return AppConstants.routeHome;
      }

      // 3. No redirect needed
      return null;
    },

    routes: [
      // ── Home ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeHome,
        builder: (context, state) => const ChaptersScreen(),
        routes: [
          GoRoute(
            path: 'chapter/:chapterId',
            builder: (context, state) {
              final chapterId =
                  int.parse(state.pathParameters['chapterId'] ?? '1');
              return ShlokListScreen(chapterId: chapterId);
            },
            routes: [
              GoRoute(
                path: 'verse/:shlokId',
                builder: (context, state) {
                  final shlokId =
                      state.pathParameters['shlokId'] ?? 'BG_1_1';
                  return ShlokDetailScreen(shlokId: shlokId);
                },
              ),
            ],
          ),
        ],
      ),

      // ── Feature routes ─────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeSearch,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppConstants.routeBookmarks,
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCollections,
        builder: (context, state) => const CollectionsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Notifier that bridges Riverpod → GoRouter's refreshListenable
// ─────────────────────────────────────────────────────────────────────────────

/// Listens to [authStateProvider] and calls [notifyListeners] when the auth
/// state changes. GoRouter's [refreshListenable] then re-evaluates [redirect].
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) {
      if (prev?.valueOrNull != next.valueOrNull) {
        notifyListeners();
      }
    });
  }
}