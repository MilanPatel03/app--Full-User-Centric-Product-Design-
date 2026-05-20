import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Sealed Result type for the domain layer.
///
/// All repository methods and use cases return [Result<T>] — never throw.
/// This makes failure handling explicit, exhaustive, and compile-time verified.
///
/// ## Pattern Matching (preferred)
/// ```dart
/// switch (result) {
///   case Ok(:final data)    => render(data);
///   case Err(:final failure) when failure is NetworkFailure => showOffline();
///   case Err(:final failure) => showError(failure.message);
/// }
/// ```
///
/// ## Functional Style
/// ```dart
/// result.when(ok: (data) => ..., err: (f) => ...);
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get dataOrNull => switch (this) {
        Ok(:final data) => data,
        Err() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Ok() => null,
        Err(:final failure) => failure,
      };

  /// Apply the matching handler and return the result.
  R when<R>({
    required R Function(T data) ok,
    required R Function(Failure failure) err,
  }) =>
      switch (this) {
        Ok(:final data) => ok(data),
        Err(:final failure) => err(failure),
      };

  /// Transform the success value, leaving failure untouched.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Ok(:final data) => Ok(transform(data)),
        Err(:final failure) => Err(failure),
      };

  /// Transform the failure, leaving success untouched.
  /// Useful for wrapping low-level failures with domain context.
  Result<T> mapError(Failure Function(Failure failure) transform) =>
      switch (this) {
        Ok() => this,
        Err(:final failure) => Err(transform(failure)),
      };

  /// Chain async operations that also return [Result].
  /// If this is [Err], the [next] function is never called — the error
  /// propagates automatically.
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T data) next,
  ) =>
      switch (this) {
        Ok(:final data) => next(data),
        Err(:final failure) => Future.value(Err(failure)),
      };
}

/// Successful result carrying domain data [T].
final class Ok<T> extends Result<T> {
  const Ok(this.data);
  final T data;

  @override
  String toString() => 'Ok<$T>($data)';
}

/// Failed result carrying a domain [Failure].
///
/// Use typed pattern matching to distinguish failure kinds:
/// ```dart
/// case Err(:final failure) when failure is NetworkFailure => ...
/// case Err(:final failure) when failure is NotFoundFailure => ...
/// ```
final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  String toString() => 'Err<$T>(${failure.runtimeType}: ${failure.message})';
}

/// Use-case parameter type when no input is needed.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
