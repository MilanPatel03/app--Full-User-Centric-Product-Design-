import 'package:equatable/equatable.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/chapter.dart';
import '../repositories/chapter_repository.dart';

/// Returns all 18 chapters of the Bhagavad Gita.
///
/// The repository decides whether to serve from local cache or
/// fetch from the remote API — this use case doesn't care which.
class GetChapters implements UseCase<List<Chapter>, NoParams> {
  const GetChapters(this._repository);

  final ChapterRepository _repository;

  @override
  Future<Result<List<Chapter>>> call(NoParams params) {
    return _repository.getChapters();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Returns a single chapter by its number (1–18).
class GetChapterById implements UseCase<Chapter, GetChapterByIdParams> {
  const GetChapterById(this._repository);

  final ChapterRepository _repository;

  @override
  Future<Result<Chapter>> call(GetChapterByIdParams params) {
    return _repository.getChapterById(params.chapterId);
  }
}

class GetChapterByIdParams extends Equatable {
  const GetChapterByIdParams(this.chapterId);
  final int chapterId;

  @override
  List<Object?> get props => [chapterId];
}
