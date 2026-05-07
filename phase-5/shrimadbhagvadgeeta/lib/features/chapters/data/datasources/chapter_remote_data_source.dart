import 'package:dio/dio.dart';

import '../../../../core/network/network_exception.dart';
import '../models/chapter_dto.dart';

/// Interface for chapter remote data access.
///
/// Returns raw [ChapterDto] objects — domain mapping happens in the repository.
/// The implementation is completely replaceable; swap the placeholder
/// mock for a real Dio call without touching any other layer.
abstract interface class ChapterRemoteDataSource {
  /// Fetches all 18 chapters from the API.
  Future<List<ChapterDto>> fetchChapters();

  /// Fetches a single chapter by its number (1–18).
  Future<ChapterDto> fetchChapterById(int chapterNumber);
}

/// Placeholder implementation using mock data.
///
/// Replace the mock bodies with real Dio calls when the API is provided:
///
/// ```dart
/// @override
/// Future<List<ChapterDto>> fetchChapters() async {
///   final response = await _dio.get('${ApiConstants.v1}/chapters');
///   return (response.data as List)
///       .map((j) => ChapterDto.fromJson(j as Map<String, dynamic>))
///       .toList();
/// }
/// ```
class ChapterRemoteDataSourceImpl implements ChapterRemoteDataSource {
  const ChapterRemoteDataSourceImpl(this._dio);

  // ignore: unused_field
  final Dio _dio;

  @override
  Future<List<ChapterDto>> fetchChapters() async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 300));
    return _kMockChapters.map(ChapterDto.fromJson).toList();
  }

  @override
  Future<ChapterDto> fetchChapterById(int chapterNumber) async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 200));
    final json = _kMockChapters.firstWhere(
      (c) => c['chapter_number'] == chapterNumber,
      orElse: () =>
          throw NotFoundException('Chapter $chapterNumber not found.'),
    );
    return ChapterDto.fromJson(json);
  }

  // ── Mock Data ─────────────────────────────────────────────────────────────
  // Remove when real API is connected. All 18 chapters should be listed.

  static const List<Map<String, dynamic>> _kMockChapters = [
    {
      'chapter_number': 1,
      'name': 'अर्जुनविषादयोग',
      'name_meaning': "Arjuna's Dilemma",
      'name_transliterated': 'Arjuna Viṣāda Yoga',
      'name_translated': 'अर्जुनविषादयोग',
      'verses_count': 47,
      'chapter_summary':
          'Arjuna, seeing his kinsmen arrayed against him, is overcome with grief '
              'and compassion. He refuses to fight and asks Krishna for guidance.',
    },
    {
      'chapter_number': 2,
      'name': 'साङ्ख्ययोग',
      'name_meaning': 'Transcendental Knowledge',
      'name_transliterated': 'Sāṅkhya Yoga',
      'name_translated': 'साङ्ख्ययोग',
      'verses_count': 72,
      'chapter_summary':
          'Krishna begins his teachings. He explains the immortality of the soul, '
              'the importance of duty, and introduces the concept of Yoga.',
    },
    {
      'chapter_number': 3,
      'name': 'कर्मयोग',
      'name_meaning': 'Eternal Duties',
      'name_transliterated': 'Karma Yoga',
      'name_translated': 'कर्मयोग',
      'verses_count': 43,
      'chapter_summary':
          'Krishna explains that one must act according to duty (svadharma) '
              'without attachment to the fruits of action.',
    },
    {
      'chapter_number': 4,
      'name': 'ज्ञानकर्मसंन्यासयोग',
      'name_meaning': 'Approach to the Absolute',
      'name_transliterated': 'Jñāna-Karma-Sannyāsa Yoga',
      'name_translated': 'ज्ञानकर्मसंन्यासयोग',
      'verses_count': 42,
      'chapter_summary':
          'Krishna reveals the tradition of Yoga and explains that knowledge '
              'and renunciation of action are not contradictory.',
    },
    {
      'chapter_number': 5,
      'name': 'कर्मसंन्यासयोग',
      'name_meaning': 'True Renunciation',
      'name_transliterated': 'Karma-Sannyāsa Yoga',
      'name_translated': 'कर्मसंन्यासयोग',
      'verses_count': 29,
      'chapter_summary':
          'Krishna explains that renunciation and the Yoga of action lead to '
              'the same ultimate goal, but Karma Yoga is superior.',
    },
  ];
}
