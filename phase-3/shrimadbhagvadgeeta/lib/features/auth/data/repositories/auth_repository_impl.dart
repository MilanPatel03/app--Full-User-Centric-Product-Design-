import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/repository_calls.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';


/// Concrete implementation of [AuthRepository].
///
/// Calls [AuthRemoteDataSource] for all operations.
/// Uses [RepositoryCalls.safeRemoteRead] which already catches [DioException],
/// [NetworkException], [ServerException], and generic [Exception].
///
/// [AuthException] (Supabase) is caught explicitly and mapped to [AuthFailure]
/// so the domain layer receives a typed failure, not a raw exception string.
///


class AuthRepositoryImpl with RepositoryCalls implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) =>
      _safeAuth(
        () => _remote.login(email: email, password: password),
      );

  @override
  Future<Result<AppUser>> signup({
    required String email,
    required String password,
  }) =>
      _safeAuth(
        () => _remote.signup(email: email, password: password),
      );

  @override
  Future<Result<void>> logout() => _safeAuth<void>(_remote.logout);

  @override
  Future<Result<AppUser?>> getCurrentUser() =>
      _safeAuth(_remote.getCurrentUser);

  @override
  Stream<AppUser?> watchAuthState() => _remote.watchAuthState();

  // ── Private: safeRemoteRead + AuthException mapping ──────────────────────

  /// Like [safeRemoteRead] but also catches [AuthException] — Supabase's
  /// specific exception for auth failures (wrong password, email not found,
  /// etc.) and maps it to [AuthFailure].
  Future<Result<T>> _safeAuth<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    } on Exception catch (e, st) {
      // Delegate to existing RepositoryCalls logic, preserving the stack trace.
      return safeRemoteRead(() => Future.error(e, st));
    }
  }
}
