import '../../../../core/network/network_exception.dart';
import '../../domain/entities/shlok.dart';
import '../models/shlok_dto.dart';
import '../models/shlok_hive_model.dart';

/// Translates between [ShlokDto], [HiveShlokModel], and the domain [Shlok].
///
/// ## Field Resolution in [fromDto]
/// Different Gita APIs use different field names for the same data.
/// Priority order (first non-null wins):
///
///   chapterNumber  : chapterNumber → chapter
///   verseNumber    : verseNumber   → verse
///   sanskritText   : devanagari    → text (Schema A may have this as transliteration)
///   transliteration: transliteration (same in both schemas)
///   translation    : translation   → meaning
///   commentary     : commentary    → purport
///
/// NOTE: Some APIs put transliteration in 'text' and have no 'devanagari' field.
/// If the Devanagari text is missing, the field will be empty — adjust this
/// rule once the real API schema is confirmed.
abstract final class ShlokMapper {
  // ── Remote → Domain ─────────────────────────────────────────────────────

  static Shlok fromDto(ShlokDto dto) {
    final chapter = dto.chapterNumber ?? dto.chapter;
    final verse = dto.verseNumber ?? dto.verse;

    // ✅ THROW EXCEPTION (NOT FAILURE)
    if (chapter == null || verse == null) {
      throw DataParsingException(
        'Invalid ShlokDto: missing chapter or verse. '
            'Received → chapter: $chapter, verse: $verse',
      );
    }

    return Shlok(
      id: Shlok.formatId(chapter, verse),
      chapterId: chapter,
      verseNumber: verse,

      // ✅ STRICT Sanskrit
      sanskritText: dto.devanagari ?? '',

      transliteration: dto.transliteration ?? '',
      translation: dto.translation ?? dto.meaning ?? '',
      commentary: dto.commentary ?? dto.purport,
    );
  }

  // ── Local → Domain ────────────────────────────────────────────────────────

  static Shlok fromHive(HiveShlokModel model) {
    return Shlok(
      id: model.id,
      chapterId: model.chapterId,
      verseNumber: model.verseNumber,
      sanskritText: model.sanskritText,
      transliteration: model.transliteration,
      translation: model.translation,
      commentary: model.commentary,
    );
  }

  // ── Domain → Local ────────────────────────────────────────────────────────

  static HiveShlokModel toHive(Shlok shlok) {
    return HiveShlokModel(
      id: shlok.id,
      chapterId: shlok.chapterId,
      verseNumber: shlok.verseNumber,
      sanskritText: shlok.sanskritText,
      transliteration: shlok.transliteration,
      translation: shlok.translation,
      commentary: shlok.commentary,
    );
  }
}
