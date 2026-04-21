import '../../../../core/utils/repository_calls.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';
import '../datasources/chapter_local_data_source.dart';
import '../datasources/chapter_remote_data_source.dart';
import '../mappers/chapter_mapper.dart';
import '../models/chapter_hive_model.dart';

/// Concrete implementation of [ChapterRepository].
///
/// ## Cache-First Strategy
///   1. Check local Hive cache
///   2. Cache hit   → return mapped domain entities immediately
///   3. Cache miss  → fetch from remote data source
///   4. Remote success → cache result + return domain entities
///   5. Remote failure → return [Err] with typed [Failure]
///
/// ## Domain Purity
/// Only domain [Chapter] entities cross the repository boundary.
/// [ChapterDto] and [HiveChapterModel] never escape this class.
class ChapterRepositoryImpl with RepositoryCalls implements ChapterRepository {
  const ChapterRepositoryImpl({
    required ChapterLocalDataSource localDataSource,
    required ChapterRemoteDataSource remoteDataSource,
  })  : _local = localDataSource,
        _remote = remoteDataSource;

  final ChapterLocalDataSource _local;
  final ChapterRemoteDataSource _remote;

  @override
  Future<Result<List<Chapter>>> getChapters() async {
    // 1. Try local cache
    final cached = await _local.getCachedChapters();
    if (cached != null && cached.isNotEmpty) {
      return Ok(_mapHiveList(cached));
    }

    // 2. Fetch from remote and cache
    return safeRemoteRead(() async {
      final dtos = await _remote.fetchChapters();
      final chapters = dtos.map(ChapterMapper.fromDto).toList();
      await _local.cacheChapters(_toHiveList(chapters));
      return chapters;
    });
  }

  @override
  Future<Result<Chapter>> getChapterById(int chapterId) async {
    // 1. Try local cache first
    final cached =
        await _local.getCachedChapterById(Chapter.formatId(chapterId));
    if (cached != null) {
      return Ok(ChapterMapper.fromHive(cached));
    }

    // 2. Fetch from remote
    return safeRemoteRead(() async {
      final dto = await _remote.fetchChapterById(chapterId);
      final chapter = ChapterMapper.fromDto(dto);
      // Cache the single chapter for future requests
      await _local.cacheChapters([ChapterMapper.toHive(chapter)]);
      return chapter;
    });
  }

  @override
  Future<Result<List<Chapter>>> refreshChapters() async {
    // Force-refresh: clear stale cache, fetch fresh from remote
    return safeRemoteRead(() async {
      final dtos = await _remote.fetchChapters();
      final chapters = dtos.map(ChapterMapper.fromDto).toList();
      await _local.clearCache();
      await _local.cacheChapters(_toHiveList(chapters));
      return chapters;
    });
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  List<Chapter> _mapHiveList(List<HiveChapterModel> models) =>
      models.map(ChapterMapper.fromHive).toList();

  List<HiveChapterModel> _toHiveList(List<Chapter> chapters) =>
      chapters.map(ChapterMapper.toHive).toList();
}
