/// Data Transfer Object representing a chapter from the remote API.
///
/// Written as a plain class that works WITHOUT code generation.
/// When the real API is integrated, this can optionally be migrated to
/// Freezed + JSON by adding the Freezed annotations and running build_runner.
///
/// Multiple alternate field names handle different Gita API schemas.
/// [ChapterMapper.fromDto] resolves the correct field priority.
///
/// DO NOT expose this class outside the data layer.
class ChapterDto {
  const ChapterDto({
    required this.chapterNumber,
    this.name,
    this.nameMeaning,
    this.nameTransliterated,
    this.nameTranslated,
    this.versesCount,
    this.verseCount,
    this.chapterSummary,
    this.summary,
  });

  final int chapterNumber;          // Always present
  final String? name;               // English or Sanskrit name (API-dependent)
  final String? nameMeaning;        // English meaning of the chapter name
  final String? nameTransliterated; // Roman transliteration of Sanskrit name
  final String? nameTranslated;     // Sanskrit name in Devanagari
  final int? versesCount;           // bhagavadgita.io convention
  final int? verseCount;            // Alternate API convention
  final String? chapterSummary;     // Primary summary field
  final String? summary;            // Alternate summary field

  factory ChapterDto.fromJson(Map<String, dynamic> json) {
    return ChapterDto(
      chapterNumber: json['chapter_number'] as int,
      name: json['name'] as String?,
      nameMeaning: json['name_meaning'] as String?,
      nameTransliterated: json['name_transliterated'] as String?,
      nameTranslated: json['name_translated'] as String?,
      versesCount: json['verses_count'] as int?,
      verseCount: json['verse_count'] as int?,
      chapterSummary: json['chapter_summary'] as String?,
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chapter_number': chapterNumber,
        if (name != null) 'name': name,
        if (nameMeaning != null) 'name_meaning': nameMeaning,
        if (nameTransliterated != null)
          'name_transliterated': nameTransliterated,
        if (nameTranslated != null) 'name_translated': nameTranslated,
        if (versesCount != null) 'verses_count': versesCount,
        if (verseCount != null) 'verse_count': verseCount,
        if (chapterSummary != null) 'chapter_summary': chapterSummary,
        if (summary != null) 'summary': summary,
      };
}
