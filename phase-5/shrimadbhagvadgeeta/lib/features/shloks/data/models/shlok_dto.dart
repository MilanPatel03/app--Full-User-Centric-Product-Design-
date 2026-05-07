/// Data Transfer Object representing a verse from the remote API.
///
/// Written as a plain class that works WITHOUT code generation.
/// When the real API is integrated, this can optionally be migrated to
/// Freezed + JSON by adding the Freezed annotations and running build_runner.
///
/// Designed to handle two common Bhagavad Gita API schemas:
///
/// Schema A (bhagavadgita.io style):
///   { chapter_number, verse_number, text, transliteration, meaning, commentary }
///
/// Schema B (vedic-scriptures style):
///   { chapter, verse, devanagari, transliteration, translation, purport }
///
/// DO NOT expose this class outside the data layer.
class ShlokDto {
  const ShlokDto({
    this.chapterNumber,
    this.chapter,
    this.verseNumber,
    this.verse,
    this.devanagari,
    this.text,
    this.transliteration,
    this.translation,
    this.meaning,
    this.commentary,
    this.purport,
  });

  // Chapter + Verse Identity
  final int? chapterNumber;    // Schema A: chapter_number
  final int? chapter;          // Schema B: chapter

  final int? verseNumber;      // Schema A: verse_number
  final int? verse;            // Schema B: verse

  // Sanskrit Text
  final String? devanagari;    // Schema B: Devanagari text
  final String? text;          // Schema A: may be transliteration or Sanskrit

  // Transliteration
  final String? transliteration;

  // English Translation
  final String? translation;   // Schema B
  final String? meaning;       // Schema A

  // Commentary
  final String? commentary;    // Schema A
  final String? purport;       // Schema B (Prabhupada's commentary)

  factory ShlokDto.fromJson(Map<String, dynamic> json) {
    return ShlokDto(
      chapterNumber: json['chapter_number'] as int?,
      chapter: json['chapter'] as int?,
      verseNumber: json['verse_number'] as int?,
      verse: json['verse'] as int?,
      devanagari: json['devanagari'] as String?,
      text: json['text'] as String?,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      meaning: json['meaning'] as String?,
      commentary: json['commentary'] as String?,
      purport: json['purport'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (chapterNumber != null) 'chapter_number': chapterNumber,
        if (chapter != null) 'chapter': chapter,
        if (verseNumber != null) 'verse_number': verseNumber,
        if (verse != null) 'verse': verse,
        if (devanagari != null) 'devanagari': devanagari,
        if (text != null) 'text': text,
        if (transliteration != null) 'transliteration': transliteration,
        if (translation != null) 'translation': translation,
        if (meaning != null) 'meaning': meaning,
        if (commentary != null) 'commentary': commentary,
        if (purport != null) 'purport': purport,
      };
}
