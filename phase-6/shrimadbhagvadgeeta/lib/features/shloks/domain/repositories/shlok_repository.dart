import '../../../../core/utils/result.dart';
import '../entities/shlok.dart';

/// Domain contract for verse (shlok) data access.
///
/// ## ID Convention
/// All methods accepting a shlok ID expect the stable `"BG_X_Y"` format.
/// e.g., `getShlokById("BG_2_47")` — never a raw integer or external API ID.
///
/// ## Repository Purity Rule
/// This interface returns ONLY [Shlok] domain entities — never DTOs,
/// Hive objects, or API response models. The data layer is responsible
/// for mapping external representations to [Shlok] before returning.
///
/// ## Offline Strategy
/// - Read operations: local cache first, remote fallback
/// - [searchShloks]: searches local cache only (no network search)
/// - [prefetchChapter]: populates local cache from remote
abstract interface class ShlokRepository {
  /// Fetch all verses for a given chapter (1–18).
  Future<Result<List<Shlok>>> getShloksByChapter(int chapterId);

  /// Fetch a single verse by its stable ID (e.g., `"BG_2_47"`).
  Future<Result<Shlok>> getShlokById(String shlokId);

  /// Search verses locally across [Shlok.sanskritText], [Shlok.transliteration],
  /// and [Shlok.translation].
  ///
  /// - Returns an empty list (not a failure) when no results match.
  /// - [query] must be at least 2 characters (enforced in [SearchShloks] use case).
  Future<Result<List<Shlok>>> searchShloks(String query);

  /// Pre-cache all verses for a chapter to support offline reading.
  /// Should be triggered before navigating to a chapter's verse list.
  Future<Result<void>> prefetchChapter(int chapterId);
}
