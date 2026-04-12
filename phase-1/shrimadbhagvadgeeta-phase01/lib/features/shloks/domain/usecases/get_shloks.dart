import 'package:equatable/equatable.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/shlok.dart';
import '../repositories/shlok_repository.dart';

/// Returns all verses for a given chapter.
class GetShloksByChapter implements UseCase<List<Shlok>, GetShloksByChapterParams> {
  const GetShloksByChapter(this._repository);

  final ShlokRepository _repository;

  @override
  Future<Result<List<Shlok>>> call(GetShloksByChapterParams params) {
    return _repository.getShloksByChapter(params.chapterId);
  }
}

class GetShloksByChapterParams extends Equatable {
  const GetShloksByChapterParams(this.chapterId);
  final int chapterId;

  @override
  List<Object?> get props => [chapterId];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Returns a single verse by its stable ID (e.g. "2.47").
class GetShlokById implements UseCase<Shlok, GetShlokByIdParams> {
  const GetShlokById(this._repository);

  final ShlokRepository _repository;

  @override
  Future<Result<Shlok>> call(GetShlokByIdParams params) {
    return _repository.getShlokById(params.shlokId);
  }
}

class GetShlokByIdParams extends Equatable {
  const GetShlokByIdParams(this.shlokId);
  final String shlokId;

  @override
  List<Object?> get props => [shlokId];
}

// ─────────────────────────────────────────────────────────────────────────────

/// Full-text search across all verse content.
///
/// Searches: Sanskrit text, transliteration, translation, commentary.
/// Returns an empty list — not a failure — when no results are found.
class SearchShloks implements UseCase<List<Shlok>, SearchShloksParams> {
  const SearchShloks(this._repository);

  final ShlokRepository _repository;

  @override
  Future<Result<List<Shlok>>> call(SearchShloksParams params) {
    return _repository.searchShloks(params.query);
  }
}

class SearchShloksParams extends Equatable {
  const SearchShloksParams(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}
