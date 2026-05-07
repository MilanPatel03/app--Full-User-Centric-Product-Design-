import 'package:dio/dio.dart';

/// Configures and returns a production-ready [Dio] instance.
///
/// The base URL is intentionally NOT hardcoded here —
/// inject it at construction time so the same factory works
/// for multiple environments (dev, staging, production).
abstract final class DioClient {
  static Dio create({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging — debug builds only (assert block stripped in release)
    assert(() {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: true,
          responseBody: true,
        ),
      );
      return true;
    }());

    return dio;
  }
}

/// Placeholder API configuration.
///
/// TODO: Replace [baseUrl] with the real endpoint when the API is provided.
/// All field name mappings happen in mappers, NOT here.
abstract final class ApiConstants {
  /// Base URL for the Bhagavad Gita API.
  /// Adjust path when real endpoint is known.
  static const String baseUrl = 'https://api.bhagavadgita.io';

  // Versioned endpoint prefix (if the API uses one)
  static const String v1 = '/v1';
  static const String v2 = '/v2';
}
