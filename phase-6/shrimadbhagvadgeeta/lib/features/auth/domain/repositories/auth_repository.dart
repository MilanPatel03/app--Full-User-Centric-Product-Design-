import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';

/// Domain contract for authentication operations.
///
/// The implementation lives in the data layer (Supabase).
/// The domain layer only sees this interface — never the concrete class.
///
/// All methods return [Result<T>] — no thrown exceptions reach the domain.
abstract class AuthRepository {
  /// Signs in with email and password.
  /// Returns the authenticated [AppUser] or a [Failure].
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  });

  /// Creates a new account with email and password.
  /// Returns the newly created [AppUser] or a [Failure].
  Future<Result<AppUser>> signup({
    required String email,
    required String password,
  });

  /// Signs out the current user and clears the local session.
  Future<Result<void>> logout();

  /// Returns the currently authenticated user, or null if not signed in.
  /// Does NOT throw — returns [Ok(null)] when unauthenticated.
  Future<Result<AppUser?>> getCurrentUser();

  /// Emits the current [AppUser] on subscribe, then emits on every
  /// auth state change (login, logout, token refresh).
  ///
  /// Emits null when unauthenticated.
  Stream<AppUser?> watchAuthState();
}
