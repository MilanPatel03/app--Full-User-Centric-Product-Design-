import '../../domain/entities/chapter.dart';
import '../models/chapter_dto.dart';
import '../models/chapter_hive_model.dart';

/// Translates between [ChapterDto], [HiveChapterModel], and the domain [Chapter].
///
/// Three conversion paths — each is a pure function (no side effects):
///   [fromDto]  — API response DTO  → domain entity  (remote path)
///   [fromHive] — Hive cache model  → domain entity  (local path)
///   [toHive]   — domain entity     → Hive model     (cache write path)
///

///
/// Design Rule:
///   This is the ONLY place where API field names touch domain field names.
///   If the API changes its JSON structure, ONLY update [fromDto].
///   The domain [Chapter] entity is never modified.
///
abstract final class ChapterMapper {
  // ── Remote → Domain ─────────────────────────────────────────────────────

  ///
  ///
  /// Maps a [ChapterDto] from the remote API to the domain [Chapter].
  ///
  /// Field resolution order (first non-null wins):
  ///   title         : nameMeaning → name → "Chapter N"
  ///   titleSanskrit : nameTranslated → nameTransliterated → ""
  ///   verseCount    : versesCount → verseCount → 0
  ///   description   : chapterSummary → summary → null
  ///
  /// Adjust this mapping when the real API schema is confirmed.
  static Chapter fromDto(ChapterDto dto) {
    return Chapter(
      id: Chapter.formatId(dto.chapterNumber),
      index: dto.chapterNumber,
      title: dto.nameMeaning ?? dto.name ?? 'Chapter ${dto.chapterNumber}',
      titleSanskrit:
          dto.nameTranslated ?? dto.nameTransliterated ?? '',
      verseCount: dto.versesCount ?? dto.verseCount ?? 0,
      description: dto.chapterSummary ?? dto.summary,
    );
  }

  // ── Local → Domain ───────────────────────────────────────────────────────

  /// Maps a cached [HiveChapterModel] to the domain [Chapter].
  static Chapter fromHive(HiveChapterModel model) {
    return Chapter(
      id: model.id,
      index: model.index,
      title: model.title,
      titleSanskrit: model.titleSanskrit,
      verseCount: model.verseCount,
      description: model.description,
    );
  }

  // ── Domain → Local ───────────────────────────────────────────────────────

  /// Maps the domain [Chapter] to a [HiveChapterModel] for local caching.
  static HiveChapterModel toHive(Chapter chapter) {
    return HiveChapterModel(
      id: chapter.id,
      index: chapter.index,
      title: chapter.title,
      titleSanskrit: chapter.titleSanskrit,
      verseCount: chapter.verseCount,
      description: chapter.description,
    );
  }
}
