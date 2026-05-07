import '../../../../core/utils/result.dart';
import '../entities/chapter.dart';

/// Domain contract for chapter data access.
///
/// This interface lives in the domain layer and knows NOTHING about:
/// - Which API provides the data
/// - How Hive stores it
/// - What the JSON looks like
///
/// The [data] layer provides the concrete implementation.
/// The [presentation] layer receives [Chapter] entities, never DTOs.
abstract interface class ChapterRepository {
  /// Fetch all 18 chapters.
  /// Returns cached data when offline; fetches from remote when online.
  Future<Result<List<Chapter>>> getChapters();

  /// Fetch a single chapter by its number (1–18).
  Future<Result<Chapter>> getChapterById(int chapterId);

  /// Force a fresh fetch from the remote source and update local cache.
  Future<Result<List<Chapter>>> refreshChapters();
}
