import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/auth_use_cases.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth state — StreamProvider backed by Supabase session stream
// ─────────────────────────────────────────────────────────────────────────────

/// Reactive auth state: emits [AppUser] when logged in, null when not.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
});

// ─────────────────────────────────────────────────────────────────────────────
// Auth actions — login, signup, logout
// ─────────────────────────────────────────────────────────────────────────────

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

  /// Clears any error state — called when the user switches between
  /// sign-in and sign-up mode so stale errors don't persist.
  void clearError() {
    if (state is AsyncError) {
      state = const AsyncData(null);
    }
  }
}

final authActionsProvider =
AsyncNotifierProvider<AuthActionsNotifier, void>(AuthActionsNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Sync trigger — hydrates Hive from Supabase on login
// ─────────────────────────────────────────────────────────────────────────────

final syncTriggerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
        (previous, next) async {
      final prevUser = previous?.valueOrNull;
      final nextUser = next.valueOrNull;

      if (prevUser == null && nextUser != null) {
        final syncService = ref.read(syncServiceProvider);
        await syncService.hydrate(nextUser.id);
      }
    },
  );
});