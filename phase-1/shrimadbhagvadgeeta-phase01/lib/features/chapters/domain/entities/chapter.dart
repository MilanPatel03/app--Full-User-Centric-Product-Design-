import 'package:equatable/equatable.dart';

/// Domain entity representing a single chapter of the Bhagavad Gita.
///
/// ## ID Convention
/// Stable string ID: `"BG_1"` through `"BG_18"`.
/// Use [Chapter.formatId] to generate. Never construct the string manually.
///
/// ## Removed Fields
/// - `name` → renamed to [title]
/// - `nameSanskrit` → renamed to [titleSanskrit]
/// - `nameTransliterated` → removed (transliteration is a presentation concern)
/// - `meaning` → removed (derived from [title], not a distinct domain fact)
/// - `summary` → renamed to [description] and made optional
class Chapter extends Equatable {
  const Chapter({
    required this.id,
    required this.index,
    required this.title,
    required this.titleSanskrit,
    required this.verseCount,
    this.description,
  });

  /// Stable string identifier — `"BG_1"` through `"BG_18"`.
  /// Generated via [Chapter.formatId].
  final String id;

  /// Chapter number (1–18). The integer position in the Gita.
  final int index;

  /// English title. e.g. `"Sankhya Yoga"`.
  final String title;

  /// Sanskrit title in Devanagari. e.g. `"साङ्ख्ययोग"`.
  final String titleSanskrit;

  /// Total number of verses in this chapter.
  final int verseCount;

  /// Optional short description of the chapter's key teaching.
  final String? description;

  // ── Factory / Helpers ───────────────────────────────────────────────────

  /// Generates the stable chapter ID. e.g. `Chapter.formatId(2)` → `"BG_2"`.
  static String formatId(int index) => 'BG_$index';

  @override
  List<Object?> get props => [
        id,
        index,
        title,
        titleSanskrit,
        verseCount,
        description,
      ];

  Chapter copyWith({
    String? id,
    int? index,
    String? title,
    String? titleSanskrit,
    int? verseCount,
    String? description,
  }) {
    return Chapter(
      id: id ?? this.id,
      index: index ?? this.index,
      title: title ?? this.title,
      titleSanskrit: titleSanskrit ?? this.titleSanskrit,
      verseCount: verseCount ?? this.verseCount,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'Chapter($id: $title, $verseCount verses)';
}
