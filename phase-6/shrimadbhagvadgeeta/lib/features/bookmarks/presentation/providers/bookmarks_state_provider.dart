import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/usecases/bookmark_use_cases.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reactive bookmark stream
// ─────────────────────────────────────────────────────────────────────────────

/// Real-time stream of all bookmarks, newest first.
/// Backed by Hive's [Box.watch()] — automatically emits on add/remove/update.
final bookmarksStreamProvider = StreamProvider<List<Bookmark>>((ref) {
  return ref.watch(bookmarkRepositoryProvider).watchBookmarks();
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived: is a specific shlok bookmarked?
// ─────────────────────────────────────────────────────────────────────────────

/// Reactively derived from [bookmarksStreamProvider] — no extra async call.
/// Returns false while the stream is loading or has errored.
///
/// Usage in a widget:
///   final isBookmarked = ref.watch(isBookmarkedProvider('BG_2_47'));
final isBookmarkedProvider = Provider.family<bool, String>((ref, shlokId) {
  final bookmarks = ref.watch(bookmarksStreamProvider).valueOrNull ?? [];
  return bookmarks.any((b) => b.shlokId == shlokId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Bookmark Action Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Exposes add/remove/updateNote actions.
/// Does NOT hold the bookmark list — that's in [bookmarksStreamProvider].
class BookmarkActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final isCurrentlyBookmarked =
        ref.read(isBookmarkedProvider(bookmark.shlokId));

    if (isCurrentlyBookmarked) {
      // Find the bookmark ID from the stream
      final bookmarks =
          ref.read(bookmarksStreamProvider).valueOrNull ?? [];
      final existing =
          bookmarks.where((b) => b.shlokId == bookmark.shlokId).firstOrNull;
      if (existing != null) {
        final useCase = ref.read(removeBookmarkUseCaseProvider);
        await useCase(RemoveBookmarkParams(existing.id));
      }
    } else {
      final useCase = ref.read(addBookmarkUseCaseProvider);
      await useCase(AddBookmarkParams(bookmark));
    }
  }

  Future<void> updateNote(Bookmark bookmark) async {
    final useCase = ref.read(updateBookmarkUseCaseProvider);
    await useCase(UpdateBookmarkParams(bookmark));
  }
}

final bookmarkActionsProvider =
    NotifierProvider<BookmarkActionsNotifier, void>(
  BookmarkActionsNotifier.new,
);
