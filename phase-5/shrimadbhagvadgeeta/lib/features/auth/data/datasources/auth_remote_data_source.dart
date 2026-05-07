import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_user.dart';
import '../models/user_dto.dart';

/// Contract for remote authentication operations.
///
/// Isolates Supabase from the repository layer.
abstract class AuthRemoteDataSource {
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> signup({required String email, required String password});
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> watchAuthState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Supabase implementation
// ─────────────────────────────────────────────────────────────────────────────

/// Concrete Supabase implementation of [AuthRemoteDataSource].
///
/// This class is the ONLY place in the codebase where Supabase Auth is used.
/// All other layers receive [AppUser] — never Supabase's own [User] type.
///
/// ## Error Policy
/// Methods throw — the repository's [RepositoryCalls.safeRemoteRead] wrapper
/// catches and converts exceptions into typed [Failure]s. Do not catch here.
class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const SupabaseAuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Login succeeded but returned no user.');
    }
    return UserDto.toDomain(user);
  }

  @override
  Future<AppUser> signup({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException(
          'Sign up succeeded but returned no user. '
          'Check if email confirmation is required in Supabase dashboard.');
    }
    return UserDto.toDomain(user);
  }

  @override
  Future<void> logout() => _client.auth.signOut();

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    return user != null ? UserDto.toDomain(user) : null;
  }

  @override
  Stream<AppUser?> watchAuthState() {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? UserDto.toDomain(user) : null;
    });
  }
}
