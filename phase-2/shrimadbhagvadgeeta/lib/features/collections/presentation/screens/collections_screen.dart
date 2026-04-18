import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../providers/collections_state_provider.dart';

/// User's curated verse collections.
///
/// State: [collectionsStreamProvider] (reactive Hive stream)
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsStreamProvider);
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
        title: Text('Collections', style: context.wisdomTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New collection',
            onPressed: () {
              // TODO (Step 5): Show create collection bottom sheet
            },
          ),
        ],
      ),
      body: collectionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: context.utilityCaption.copyWith(color: scheme.error)),
        ),
        data: (collections) => collections.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_outlined,
                        size: 48, color: scheme.secondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No collections yet',
                      style: context.wisdomBody
                          .copyWith(color: scheme.secondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Create a collection to organise your verses',
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
                    '${collections.length} collections',
                    style: context.wisdomTitle,
                  ),
                ),
              ),
        // TODO (Step 5): Replace with CollectionGridView
      ),
    );
  }
}
