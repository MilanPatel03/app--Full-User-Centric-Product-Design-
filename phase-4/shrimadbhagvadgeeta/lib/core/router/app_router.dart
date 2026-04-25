import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';
import '../../features/chapters/presentation/screens/chapters_screen.dart';
import '../../features/collections/presentation/screens/collections_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shloks/presentation/screens/search_screen.dart';
import '../../features/shloks/presentation/screens/shlok_detail_screen.dart';
import '../../features/shloks/presentation/screens/shlok_list_screen.dart';
import '../constants/app_constants.dart';
import '../shell/app_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route constants
// ─────────────────────────────────────────────────────────────────────────────

/// Tab root paths — these are the four bottom nav destinations.
class _TabRoutes {
  static const home     = '/home';
  static const explore  = '/explore';
  static const library  = '/library';
  static const profile  = '/profile';
}

/// Map a bottom nav index to its root path.
String _tabPath(int index) => switch (index) {
  0 => _TabRoutes.home,
  1 => _TabRoutes.explore,
  2 => _TabRoutes.library,
  _ => _TabRoutes.profile,
};

/// Map a path to its bottom nav index.
int _tabIndex(String location) {
  if (location.startsWith(_TabRoutes.explore)) return 1;
  if (location.startsWith(_TabRoutes.library)) return 2;
  if (location.startsWith(_TabRoutes.profile)) return 3;
  return 0; // home is default
}

/// Protected routes — unauthenticated users are redirected to login.
const _protectedRoutes = {
  _TabRoutes.library,
  _TabRoutes.profile,
  AppConstants.routeBookmarks,
  AppConstants.routeCollections,
};

// ─────────────────────────────────────────────────────────────────────────────
// Router provider
// ─────────────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: _TabRoutes.home,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,

    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      if (authAsync.isLoading) return null;

      final isAuthenticated = authAsync.valueOrNull != null;
      final location = state.uri.path;
      final goingToLogin = location == AppConstants.routeLogin;

      final isProtected = _protectedRoutes.any(
            (route) => location.startsWith(route),
      );

      if (!isAuthenticated && isProtected) return AppConstants.routeLogin;
      if (isAuthenticated && goingToLogin) return _TabRoutes.home;
      return null;
    },

    routes: [
      // ── Shell — wraps all 4 tab destinations ────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          final index = _tabIndex(state.uri.path);
          return AppShell(
            currentIndex: index,
            onTabSelected: (i) => context.go(_tabPath(i)),
            child: child,
          );
        },
        routes: [
          // Tab 0 — Home
          GoRoute(
            path: _TabRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),

          // Tab 1 — Explore (chapters)
          GoRoute(
            path: _TabRoutes.explore,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChaptersScreen(),
            ),
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

          // Tab 2 — Library [PROTECTED]
          GoRoute(
            path: _TabRoutes.library,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookmarksScreen(),
            ),
            routes: [
              GoRoute(
                path: 'collections',
                builder: (context, state) => const CollectionsScreen(),
              ),
            ],
          ),

          // Tab 3 — Profile [PROTECTED]
          GoRoute(
            path: _TabRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ── Routes outside the shell (no bottom nav) ─────────────────────────
      GoRoute(
        path: AppConstants.routeSearch,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),

      // Legacy deep-link support — redirect old paths to shell equivalents
      GoRoute(
        path: '/',
        redirect: (_, __) => _TabRoutes.home,
      ),
      GoRoute(
        path: AppConstants.routeBookmarks,
        redirect: (_, __) => _TabRoutes.library,
      ),
      GoRoute(
        path: AppConstants.routeCollections,
        redirect: (_, __) => '${_TabRoutes.library}/collections',
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Auth change notifier
// ─────────────────────────────────────────────────────────────────────────────

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) {
      if (prev?.valueOrNull != next.valueOrNull) {
        notifyListeners();
      }
    });
  }
}