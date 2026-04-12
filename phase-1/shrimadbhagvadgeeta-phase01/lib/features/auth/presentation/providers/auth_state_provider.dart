import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/auth_use_cases.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth state — StreamProvider backed by Supabase session stream
// ─────────────────────────────────────────────────────────────────────────────

/// Reactive auth state: emits [AppUser] when logged in, null when not.
///
/// Backed by [AuthRepository.watchAuthState] which wraps Supabase's
/// onAuthStateChange stream. Ensures:
/// - GoRouter redirects fire immediately on login/logout
/// - The UI is always in sync with the actual session
///
/// autoDispose is NOT used — auth state must persist for the app's lifetime.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
});

// ─────────────────────────────────────────────────────────────────────────────
// Auth actions — login, signup, logout
// ─────────────────────────────────────────────────────────────────────────────

/// Holds state for an in-progress auth operation.
/// Presentation reads this for loading spinner and error display.
class AuthActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(loginUseCaseProvider)
        .call(LoginParams(email: email, password: password));
    state = switch (result) {
      Ok() => const AsyncData(null),
      Err(:final failure) => AsyncError(failure.message, StackTrace.current),
    };
  }

  Future<void> signup({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signupUseCaseProvider)
        .call(SignupParams(email: email, password: password));
    state = switch (result) {
      Ok() => const AsyncData(null),
      Err(:final failure) => AsyncError(failure.message, StackTrace.current),
    };
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(logoutUseCaseProvider).call();
    state = const AsyncData(null);
  }
}

final authActionsProvider =
    AsyncNotifierProvider<AuthActionsNotifier, void>(AuthActionsNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Sync trigger — hydrates Hive from Supabase on login
// ─────────────────────────────────────────────────────────────────────────────

/// Triggers [SyncService.hydrate] when auth state transitions from
/// unauthenticated to authenticated (null → AppUser).
///
/// Must be watched in [GeetaApp.build] so it persists for the app's lifetime.
final syncTriggerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
    (previous, next) async {
      final prevUser = previous?.valueOrNull;
      final nextUser = next.valueOrNull;

      // Only hydrate on actual login event (null → user), not on page reload
      if (prevUser == null && nextUser != null) {
        final syncService = ref.read(syncServiceProvider);
        await syncService.hydrate(nextUser.id);
      }
    },
  );
});
