import '../../../../core/utils/result.dart';

/// Abstract base class for all single-input use cases.
///
/// [Type] — the domain return type on success
/// [Params] — the input parameter object (use [NoParams] if none)
///
/// Usage:
/// ```dart
/// class GetChapterById extends UseCase<Chapter, GetChapterByIdParams> {
///   @override
///   Future<Result<Chapter>> call(GetChapterByIdParams params) { ... }
/// }
/// ```
abstract interface class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Abstract base for stream-based use cases (real-time observers).
abstract interface class StreamUseCase<Type, Params> {
  Stream<Result<Type>> call(Params params);
}
