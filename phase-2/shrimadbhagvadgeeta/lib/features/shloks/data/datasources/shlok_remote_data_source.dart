import 'package:dio/dio.dart';

import '../../../../core/network/network_exception.dart';
import '../models/shlok_dto.dart';

/// Interface for shlok remote data access.
abstract interface class ShlokRemoteDataSource {
  /// Fetches all verses for a chapter.
  Future<List<ShlokDto>> fetchShloksByChapter(int chapterId);

  /// Fetches a single verse by chapter and verse number.
  Future<ShlokDto> fetchShlokByVerseNumber({
    required int chapterId,
    required int verseNumber,
  });
}

/// Placeholder implementation using mock data for Chapter 2.
///
/// Swap for real Dio calls when API is ready:
/// ```dart
/// @override
/// Future<List<ShlokDto>> fetchShloksByChapter(int chapterId) async {
///   final response = await _dio.get('/v1/chapters/$chapterId/verses');
///   return (response.data as List)
///       .map((j) => ShlokDto.fromJson(j as Map<String, dynamic>))
///       .toList();
/// }
/// ```
class ShlokRemoteDataSourceImpl implements ShlokRemoteDataSource {
  const ShlokRemoteDataSourceImpl(this._dio);

  // ignore: unused_field
  final Dio _dio;

  @override
  Future<List<ShlokDto>> fetchShloksByChapter(int chapterId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final verses = _kMockShloks
        .where((j) => j['chapter_number'] == chapterId)
        .toList();
    if (verses.isEmpty) {
      throw NotFoundException('No shloks found for chapter $chapterId.');
    }
    return verses.map(ShlokDto.fromJson).toList();
  }

  @override
  Future<ShlokDto> fetchShlokByVerseNumber({
    required int chapterId,
    required int verseNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final json = _kMockShloks.firstWhere(
      (j) =>
          j['chapter_number'] == chapterId &&
          j['verse_number'] == verseNumber,
      orElse: () => throw NotFoundException(
        'Shlok $chapterId.$verseNumber not found.',
      ),
    );
    return ShlokDto.fromJson(json);
  }

  // ── Mock Data ─────────────────────────────────────────────────────────────
  // Chapter 2, key verses. Replace with real API call.

  static const List<Map<String, dynamic>> _kMockShloks = [
    {
      'chapter_number': 2,
      'verse_number': 1,
      'devanagari':
          'सञ्जय उवाच | तं तथा कृपयाविष्टमश्रुपूर्णाकुलेक्षणम् |'
              ' विषीदन्तमिदं वाक्यमुवाच मधुसूदनः ||१||',
      'transliteration':
          'sanjaya uvaca tam tatha krpayavistam asru-purnakuleksanam '
              'visidantam idam vakyam uvaca madhusudanah',
      'meaning':
          'Sanjaya said: Seeing Arjuna full of compassion, his mind depressed, '
              'his eyes full of tears, Madhusudana, Krishna, spoke the following words.',
      'commentary':
          'Due to compassion for kinsmen, Arjuna became unable to discharge his duty.',
    },
    {
      'chapter_number': 2,
      'verse_number': 47,
      'devanagari':
          'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन | '
              'मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि ||४७||',
      'transliteration':
          'karmany evadhikaras te ma phalesu kadacana '
              'ma karma-phala-hetur bhur ma te sango stv akarmani',
      'meaning':
          'You have a right to perform your prescribed duty, but you are not '
              'entitled to the fruits of action. Never consider yourself the cause of '
              'the results of your activities, and never be attached to not doing your duty.',
      'commentary':
          'This verse contains the essence of the entire Gita. The threefold '
              'instruction: perform your duty, do not be attached to results, '
              'do not abandon your duty.',
    },
    {
      'chapter_number': 2,
      'verse_number': 48,
      'devanagari':
          'योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय | '
              'सिद्ध्यसिद्ध्योः समो भूत्वा समत्वं योग उच्यते ||४८||',
      'transliteration':
          'yoga-sthah kuru karmani sangam tyaktva dhananjaya '
              'siddhy-asiddhyoh samo bhutva samatvam yoga ucyate',
      'meaning':
          'Be steadfast in yoga, O Arjuna. Perform your duty and abandon all '
              'attachment to success or failure. Such evenness of mind is yoga.',
      'commentary': null,
    },
  ];
}
