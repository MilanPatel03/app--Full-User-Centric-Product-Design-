import 'package:equatable/equatable.dart';

/// Domain entity representing a single verse (shlok) of the Bhagavad Gita.
///
/// ## ID Convention
/// Stable string ID: `"BG_<chapter>_<verse>"` — e.g., `"BG_2_47"`.
/// Generated via [Shlok.formatId]. This ID is:
/// - stable across API versions
/// - human-readable and debuggable
/// - safe to store in Hive, databases, and URLs
/// - independent of any external API's ID scheme
///
/// ## Field Naming
/// - `sanskritText` is explicit — never use `text` (ambiguous)
/// - `commentary` is optional — not all APIs provide it; UI must handle null
///
/// ## Removed Fields
/// - `wordMeanings` — too granular for a domain entity; belongs in the
///   data layer as part of a DTO if the API provides it
/// - `displayId` computed getter — presentation logic, not domain
class Shlok extends Equatable {
  const Shlok({
    required this.id,
    required this.chapterId,
    required this.verseNumber,
    required this.sanskritText,
    required this.transliteration,
    required this.translation,
    this.commentary,
  });

  /// Stable identifier: `"BG_{chapter}_{verse}"` — e.g., `"BG_2_47"`.
  /// Use [Shlok.formatId] to generate. Never construct manually.
  final String id;

  /// The chapter this verse belongs to (1–18).
  final int chapterId;

  /// Verse number within its chapter (1-based).
  final int verseNumber;

  /// Original Sanskrit text in Devanagari script.
  /// e.g., `"कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।"`
  final String sanskritText;

  /// Roman transliteration of [sanskritText].
  /// e.g., `"karmaṇy evādhikāras te mā phaleṣu kadācana"`
  final String transliteration;

  /// Full English translation of the verse.
  final String translation;

  /// Optional spiritual commentary and explanation.
  /// May be null if the data source does not provide it.
  final String? commentary;

  // ── Factory / Helpers ───────────────────────────────────────────────────

  /// Generates the stable shlok ID.
  /// e.g., `Shlok.formatId(2, 47)` → `"BG_2_47"`.
  static String formatId(int chapter, int verse) => 'BG_${chapter}_$verse';

  bool get hasCommentary => commentary != null && commentary!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        chapterId,
        verseNumber,
        sanskritText,
        transliteration,
        translation,
        commentary,
      ];

  Shlok copyWith({
    String? id,
    int? chapterId,
    int? verseNumber,
    String? sanskritText,
    String? transliteration,
    String? translation,
    String? commentary,
  }) {
    return Shlok(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      verseNumber: verseNumber ?? this.verseNumber,
      sanskritText: sanskritText ?? this.sanskritText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      commentary: commentary ?? this.commentary,
    );
  }

  @override
  String toString() => 'Shlok($id)';
}
