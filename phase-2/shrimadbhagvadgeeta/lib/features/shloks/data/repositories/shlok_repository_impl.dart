import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_exception.dart';
import '../../../../core/utils/repository_calls.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/shlok.dart';
import '../../domain/repositories/shlok_repository.dart';
import '../datasources/shlok_local_data_source.dart';
import '../datasources/shlok_remote_data_source.dart';
import '../mappers/shlok_mapper.dart';
import '../models/shlok_hive_model.dart';

/// Concrete implementation of [ShlokRepository].
///
/// ## Cache-First Strategy (per-chapter)
///   1. Check if chapter is already cached locally
///   2. Cache hit  → return from Hive (zero network)
///   3. Cache miss → fetch from remote, cache + return
///
/// ## Search
/// Local full-text search across all cached shloks.
/// Only chapters that have been visited are searchable.
/// Call [prefetchChapter] to pre-populate the cache proactively.
class ShlokRepositoryImpl with RepositoryCalls implements ShlokRepository {
  const ShlokRepositoryImpl({
    required ShlokLocalDataSource localDataSource,
    required ShlokRemoteDataSource remoteDataSource,
  })  : _local = localDataSource,
        _remote = remoteDataSource;

  final ShlokLocalDataSource _local;
  final ShlokRemoteDataSource _remote;

  @override
  Future<Result<List<Shlok>>> getShloksByChapter(int chapterId) async {
    // 1. Try local cache
    final cached = await _local.getCachedShloksByChapter(chapterId);
    if (cached.isNotEmpty) {
      return Ok(_mapHiveList(cached));
    }

    // 2. Fetch from remote and cache
    return safeRemoteRead(() async {
      final dtos = await _remote.fetchShloksByChapter(chapterId);

      final List<Shlok> shloks = [];

      for (final dto in dtos) {
        try {
          final shlok = ShlokMapper.fromDto(dto);
          shloks.add(shlok);
        } on DataParsingException catch (e) {
          throw DataParsingFailure(e.message);
        }
      }

      await _local.cacheShloks(_toHiveList(shloks));
      return shloks;
    });
  }

  @override
  Future<Result<Shlok>> getShlokById(String shlokId) async {
    // 1. Try local cache
    final cached = await _local.getCachedShlokById(shlokId);
    if (cached != null) {
      return Ok(ShlokMapper.fromHive(cached));
    }

    // 2. Parse chapter/verse from stable ID and fetch remote
    final parts = _parseShlokId(shlokId);
    if (parts == null) {
      return Err(NotFoundFailure(
        'Invalid shlok ID: "$shlokId". Expected format: BG_<chapter>_<verse>.',
      ));
    }

    return safeRemoteRead(() async {
      final dto = await _remote.fetchShlokByVerseNumber(
        chapterId: parts.$1,
        verseNumber: parts.$2,
      );

      final shlok = ShlokMapper.fromDto(dto); // will throw if invalid

      await _local.cacheShloks([ShlokMapper.toHive(shlok)]);
      return shlok;
    });
  }

  @override
  Future<Result<List<Shlok>>> searchShloks(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const Ok([]);

    return safeLocalRead(() async {
      final allCached = await _local.getAllCachedShloks();
      final lowerQuery = trimmed.toLowerCase();
      return allCached
          .map(ShlokMapper.fromHive)
          .where((s) =>
              s.sanskritText.toLowerCase().contains(lowerQuery) ||
              s.transliteration.toLowerCase().contains(lowerQuery) ||
              s.translation.toLowerCase().contains(lowerQuery) ||
              (s.commentary?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    });
  }

  @override
  Future<Result<void>> prefetchChapter(int chapterId) async {
    // No-op if chapter is already cached — avoids duplicate network calls
    final cached = await _local.getCachedShloksByChapter(chapterId);
    if (cached.isNotEmpty) return const Ok(null);

    return safeRemoteRead(() async {
      final dtos = await _remote.fetchShloksByChapter(chapterId);

      final List<Shlok> shloks = [];

      for (final dto in dtos) {
        try {
          final shlok = ShlokMapper.fromDto(dto);
          shloks.add(shlok);
        } on DataParsingException {
          // Skip invalid data in prefetch
          continue;
        }
      }

      await _local.cacheShloks(_toHiveList(shloks));
    });
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  List<Shlok> _mapHiveList(List<HiveShlokModel> models) =>
      models.map(ShlokMapper.fromHive).toList();

  List<HiveShlokModel> _toHiveList(List<Shlok> shloks) =>
      shloks.map(ShlokMapper.toHive).toList();

  /// Parses "BG_2_47" → (chapter: 2, verse: 47). Returns null if invalid.
  (int, int)? _parseShlokId(String id) {
    final parts = id.split('_');
    if (parts.length != 3 || parts[0] != 'BG') return null;
    final chapter = int.tryParse(parts[1]);
    final verse = int.tryParse(parts[2]);
    if (chapter == null || verse == null) return null;
    return (chapter, verse);
  }
}



/// DTO → Mapper → throws DataParsingException (data layer)
//
// Repository:
//   catch DataParsingException
//   → convert to DataParsingFailure (domain layer)
//
// UI:
//   receives Result.Err(DataParsingFailure)