import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Signs in an existing user with email and password.
class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser>> call(LoginParams params) =>
      _repository.login(email: params.email, password: params.password);
}

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Creates a new account with email and password.
class Signup {
  const Signup(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser>> call(SignupParams params) =>
      _repository.signup(email: params.email, password: params.password);
}

class SignupParams {
  const SignupParams({required this.email, required this.password});
  final String email;
  final String password;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Signs out the current user.
class Logout {
  const Logout(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}

// ─────────────────────────────────────────────────────────────────────────────

/// Returns the currently authenticated user (null if unauthenticated).
class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser?>> call() => _repository.getCurrentUser();
}
