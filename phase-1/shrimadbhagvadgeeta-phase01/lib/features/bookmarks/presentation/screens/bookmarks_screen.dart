import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../providers/bookmarks_state_provider.dart';

/// User's saved verses.
///
/// State: [bookmarksStreamProvider] (reactive Hive stream)
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Bookmarks', style: context.wisdomTitle),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: context.utilityCaption.copyWith(color: scheme.error)),
        ),
        data: (bookmarks) => bookmarks.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border_rounded,
                        size: 48, color: scheme.secondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No bookmarks yet',
                      style: context.wisdomBody
                          .copyWith(color: scheme.secondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Bookmark verses while reading',
                      style: context.utilityCaption
                          .copyWith(color: scheme.secondary),
                    ),
                  ],
                ),
              )
            : Center(
                child: SectionContainer(
                  tier: SurfaceTier.medium,
                  padding: AppEdgeInsets.card,
                  borderRadius: AppRadius.lgBorder,
                  child: Text(
                    '${bookmarks.length} bookmarks',
                    style: context.wisdomTitle,
                  ),
                ),
              ),
        // TODO (Step 5): Replace with BookmarkListView
      ),
    );
  }
}
