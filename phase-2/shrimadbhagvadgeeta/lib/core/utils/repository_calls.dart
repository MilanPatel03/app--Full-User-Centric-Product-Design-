import 'package:dio/dio.dart';

import '../errors/failures.dart';
import '../network/network_exception.dart';
import 'result.dart';

/// Mixin providing safe execution wrappers for repository implementations.
///
/// Eliminates repetitive try/catch in every repository method.
/// Converts data-layer exceptions into typed domain [Failure]s.
///
/// Usage:
/// ```dart
/// class MyRepositoryImpl with RepositoryCalls implements MyRepository {
///   @override
///   Future<Result<List<Item>>> getItems() =>
///       safeRemoteRead(() async {
///         final dtos = await _remote.fetch();
///         return dtos.map(ItemMapper.fromDto).toList();
///       });
/// }
/// ```
mixin RepositoryCalls {
  // ── Remote (Dio) ────────────────────────────────────────────────────────

  /// Executes a remote network call. Maps [DioException] and
  /// [DataException] to domain [Failure]s.
  Future<Result<T>> safeRemoteRead<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on DioException catch (e) {
      return Err(_mapDioException(e));
    } on NetworkException catch (e) {
      return Err(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Err(NotFoundFailure(e.message));
    } on DataParsingException catch (e) {
      return Err(DataParsingFailure(e.message));
    } on Exception catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  // ── Local (Hive) ─────────────────────────────────────────────────────────

  /// Executes a local read that returns a value. Maps [CacheException].
  Future<Result<T>> safeLocalRead<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    } on Exception catch (e) {
      return Err(CacheFailure(e.toString()));
    }
  }

  /// Executes a local write (void) operation. Maps [CacheException].
  Future<Result<void>> safeLocalWrite(Future<void> Function() call) async {
    try {
      await call();
      return const Ok(null);
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    } on Exception catch (e) {
      return Err(CacheFailure(e.toString()));
    }
  }

  // ── Private ──────────────────────────────────────────────────────────────

  Failure _mapDioException(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const NetworkFailure('Connection timed out. Check your internet.'),
        DioExceptionType.connectionError =>
          const NetworkFailure('No internet connection.'),
        DioExceptionType.badResponse => ServerFailure(
            'Server error (${e.response?.statusCode}): '
            '${e.response?.statusMessage ?? "Unknown"}',
          ),
        DioExceptionType.cancel =>
          const NetworkFailure('Request was cancelled.'),
        _ => NetworkFailure(e.message ?? 'An unknown network error occurred.'),
      };
}
