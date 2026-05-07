import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/usecases/collection_use_cases.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reactive collections stream
// ─────────────────────────────────────────────────────────────────────────────

/// Real-time stream of all collections, sorted by creation date.
final collectionsStreamProvider = StreamProvider<List<Collection>>((ref) {
  return ref.watch(collectionRepositoryProvider).watchCollections();
});

// ─────────────────────────────────────────────────────────────────────────────
// Reactive items stream (scoped to a collection)
// ─────────────────────────────────────────────────────────────────────────────

/// Real-time stream of items in a specific collection.
/// Emits when items are added, removed, or reordered.
final collectionItemsStreamProvider =
    StreamProvider.family<List<CollectionItem>, String>(
        (ref, collectionId) {
  return ref
      .watch(collectionRepositoryProvider)
      .watchItemsForCollection(collectionId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived: is a shlok in a specific collection?
// ─────────────────────────────────────────────────────────────────────────────

/// Derived from [collectionItemsStreamProvider]. Returns false during loading.
final isShlokInCollectionProvider =
    Provider.family<bool, ({String collectionId, String shlokId})>(
        (ref, args) {
  final items = ref
      .watch(collectionItemsStreamProvider(args.collectionId))
      .valueOrNull ?? [];
  return items.any((i) => i.shlokId == args.shlokId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Collection Actions Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Exposes create/delete collection and add/remove item actions.
class CollectionActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> createCollection(Collection collection) async {
    final useCase = ref.read(createCollectionUseCaseProvider);
    await useCase(CreateCollectionParams(collection));
  }

  Future<void> deleteCollection(String collectionId) async {
    final useCase = ref.read(deleteCollectionUseCaseProvider);
    await useCase(DeleteCollectionParams(collectionId));
  }

  Future<void> addItemToCollection(CollectionItem item) async {
    final useCase = ref.read(addItemToCollectionUseCaseProvider);
    await useCase(AddItemToCollectionParams(item));
  }

  Future<void> removeItemFromCollection(String itemId) async {
    final useCase = ref.read(removeItemFromCollectionUseCaseProvider);
    await useCase(RemoveItemFromCollectionParams(itemId));
  }
}

final collectionActionsProvider =
    NotifierProvider<CollectionActionsNotifier, void>(
  CollectionActionsNotifier.new,
);
