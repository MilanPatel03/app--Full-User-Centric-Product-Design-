import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
///
/// Repositories return failures as values (not thrown exceptions), keeping
/// the domain layer pure and testable. Use the Result/Either pattern.
///
/// Extends [Equatable] for reliable equality in tests and Riverpod state.
abstract class Failure extends Equatable {
  const Failure([this.message = 'An unexpected error occurred.']);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Network connectivity or HTTP transport error.
class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'Unable to connect. Check your internet connection.']);
}

/// Server returned a 4xx or 5xx error response.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'The server returned an error.']);
}

/// Hive local cache read/write error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

/// Resource not found (local or remote).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}

/// Input validation failure (e.g., empty search query).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input.']);
}

/// Catch-all for unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred.']);
}

class DataParsingFailure extends Failure {
  const DataParsingFailure(super.message);
}

/// Authentication failure — wrong password, unconfirmed email, etc.
/// Mapped from [AuthException] (Supabase) in [AuthRepositoryImpl].
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// Background sync failure — remote write failed but local data is safe.
/// Should be logged/shown as a non-blocking warning, not an error state.
class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Sync failed. Will retry on next launch.']);
}
