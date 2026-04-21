import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/dio_client.dart';
import '../settings/settings_hive_model.dart';
import '../settings/settings_repository.dart';
import '../sync/pending_sync_queue.dart';
import '../sync/sync_service.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_use_cases.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/bookmarks/data/datasources/bookmark_local_data_source.dart';
import '../../features/bookmarks/data/datasources/bookmark_remote_data_source.dart';
import '../../features/bookmarks/data/models/bookmark_hive_model.dart';
import '../../features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import '../../features/bookmarks/domain/repositories/bookmark_repository.dart';
import '../../features/bookmarks/domain/usecases/bookmark_use_cases.dart';
import '../../features/chapters/data/datasources/chapter_local_data_source.dart';
import '../../features/chapters/data/datasources/chapter_remote_data_source.dart';
import '../../features/chapters/data/models/chapter_hive_model.dart';
import '../../features/chapters/data/repositories/chapter_repository_impl.dart';
import '../../features/chapters/domain/repositories/chapter_repository.dart';
import '../../features/chapters/domain/usecases/get_chapters.dart';
import '../../features/collections/data/datasources/collection_local_data_source.dart';
import '../../features/collections/data/datasources/collection_remote_data_source.dart';
import '../../features/collections/data/models/collection_hive_models.dart';
import '../../features/collections/data/repositories/collection_repository_impl.dart';
import '../../features/collections/domain/repositories/collection_repository.dart';
import '../../features/collections/domain/usecases/collection_use_cases.dart';
import '../../features/shloks/data/datasources/shlok_local_data_source.dart';
import '../../features/shloks/data/datasources/shlok_remote_data_source.dart';
import '../../features/shloks/data/models/shlok_hive_model.dart';
import '../../features/shloks/data/repositories/shlok_repository_impl.dart';
import '../../features/shloks/domain/repositories/shlok_repository.dart';
import '../../features/shloks/domain/usecases/get_shloks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LAYER 0 — External SDKs
// ─────────────────────────────────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>(
      (_) => Supabase.instance.client,
);

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(baseUrl: ApiConstants.baseUrl);
});

// ─────────────────────────────────────────────────────────────────────────────
// LAYER 1 — Hive Box Providers (overridden in main.dart ProviderScope)
// ─────────────────────────────────────────────────────────────────────────────

final chapterBoxProvider = Provider<Box<HiveChapterModel>>(
      (_) => throw UnimplementedError('chapterBoxProvider must be overridden.'),
  name: 'chapterBoxProvider',
);

final shlokBoxProvider = Provider<Box<HiveShlokModel>>(
      (_) => throw UnimplementedError('shlokBoxProvider must be overridden.'),
  name: 'shlokBoxProvider',
);

final bookmarkBoxProvider = Provider<Box<HiveBookmarkModel>>(
      (_) => throw UnimplementedError('bookmarkBoxProvider must be overridden.'),
  name: 'bookmarkBoxProvider',
);

final collectionBoxProvider = Provider<Box<HiveCollectionModel>>(
      (_) => throw UnimplementedError('collectionBoxProvider must be overridden.'),
  name: 'collectionBoxProvider',
);

final collectionItemBoxProvider = Provider<Box<HiveCollectionItemModel>>(
      (_) => throw UnimplementedError(
      'collectionItemBoxProvider must be overridden.'),
  name: 'collectionItemBoxProvider',
);

final pendingSyncBoxProvider = Provider<Box<HivePendingSyncModel>>(
      (_) => throw UnimplementedError('pendingSyncBoxProvider must be overridden.'),
  name: 'pendingSyncBoxProvider',
);

/// Settings box — overridden in main.dart.
final settingsBoxProvider = Provider<Box<HiveSettingsModel>>(
      (_) => throw UnimplementedError('settingsBoxProvider must be overridden.'),
  name: 'settingsBoxProvider',
);

// ─────────────────────────────────────────────────────────────────────────────
// LAYER 1.5 — Settings repository (overrides the stub in settings_provider.dart)
// ─────────────────────────────────────────────────────────────────────────────

/// Concrete override of the stub declared in settings_provider.dart.
/// Placed here so all provider wiring stays in one file.
final settingsRepositoryConcreteProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(settingsBoxProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// LAYER 1.6 — Pending Sync Queue
// ─────────────────────────────────────────────────────────────────────────────

final pendingSyncQueueProvider = Provider<PendingSyncQueue>((ref) {
  return PendingSyncQueue(ref.watch(pendingSyncBoxProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// LAYER 2 — Data Sources
// ─────────────────────────────────────────────────────────────────────────────

final authRemoteDsProvider = Provider<AuthRemoteDataSource>((ref) {
  return SupabaseAuthRemoteDataSource(ref.watch(supabaseClientProvider));
});

final chapterLocalDsProvider = Provider<ChapterLocalDataSource>((ref) {
  return ChapterLocalDataSourceImpl(ref.watch(chapterBoxProvider));
});

final chapterRemoteDsProvider = Provider<ChapterRemoteDataSource>((ref) {
  return ChapterRemoteDataSourceImpl(ref.watch(dioProvider));
});

final shlokLocalDsProvider = Provider<ShlokLocalDataSource>((ref) {
  return ShlokLocalDataSourceImpl(ref.watch(shlokBoxProvider));
});

final shlokRemoteDsProvider = Provider<ShlokRemoteDataSource>((ref) {
  return ShlokRemoteDataSourceImpl(ref.watch(dioProvider));
});

final bookmarkLocalDsProvider = Provider<BookmarkLocalDataSource>((ref) {
  return BookmarkLocalDataSourceImpl(ref.watch(bookmarkBoxProvider));
});

final bookmarkRemoteDsProvider = Provider<BookmarkRemoteDataSource>((ref) {
  return SupabaseBookmarkRemoteDataSource(ref.watch(supabaseClientProvider));
});

final collectionLocalDsProvider = Provider<CollectionLocalDataSource>((ref) {
  return CollectionLocalDataSourceImpl(
    collectionBox: ref.watch(collectionBoxProvider),
    itemBox: ref.watch(collectionItemBoxProvider),
  );
});

final collectionRemoteDsProvider = Provider<CollectionRemoteDataSource>((ref) {
  return SupabaseCollectionRemoteDataSource(ref.watch(supabaseClientProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// LAYER 3 — Repositories
// ─────────────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDsProvider));
});

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepositoryImpl(
    localDataSource: ref.watch(chapterLocalDsProvider),
    remoteDataSource: ref.watch(chapterRemoteDsProvider),
  );
});

final shlokRepositoryProvider = Provider<ShlokRepository>((ref) {
  return ShlokRepositoryImpl(
    localDataSource: ref.watch(shlokLocalDsProvider),
    remoteDataSource: ref.watch(shlokRemoteDsProvider),
  );
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return BookmarkRepositoryImpl(
    local: ref.watch(bookmarkLocalDsProvider),
    remote: ref.watch(bookmarkRemoteDsProvider),
    userId: userId,
    queue: ref.watch(pendingSyncQueueProvider),
  );
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepositoryImpl(
    local: ref.watch(collectionLocalDsProvider),
    remote: ref.watch(collectionRemoteDsProvider),
    userId: ref.watch(currentUserIdProvider),
    queue: ref.watch(pendingSyncQueueProvider),
  );
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.id;
});

// ─────────────────────────────────────────────────────────────────────────────
// LAYER 3.5 — Sync Service
// ─────────────────────────────────────────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    bookmarkLocal: ref.watch(bookmarkLocalDsProvider),
    bookmarkRemote: ref.watch(bookmarkRemoteDsProvider),
    collectionLocal: ref.watch(collectionLocalDsProvider),
    collectionRemote: ref.watch(collectionRemoteDsProvider),
    pendingQueue: ref.watch(pendingSyncQueueProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// LAYER 4 — Use Cases
// ─────────────────────────────────────────────────────────────────────────────

final loginUseCaseProvider = Provider<Login>(
      (ref) => Login(ref.watch(authRepositoryProvider)),
);
final signupUseCaseProvider = Provider<Signup>(
      (ref) => Signup(ref.watch(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider<Logout>(
      (ref) => Logout(ref.watch(authRepositoryProvider)),
);
final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>(
      (ref) => GetCurrentUser(ref.watch(authRepositoryProvider)),
);

final getChaptersUseCaseProvider = Provider<GetChapters>(
      (ref) => GetChapters(ref.watch(chapterRepositoryProvider)),
);
final getChapterByIdUseCaseProvider = Provider<GetChapterById>(
      (ref) => GetChapterById(ref.watch(chapterRepositoryProvider)),
);

final getShloksByChapterUseCaseProvider = Provider<GetShloksByChapter>(
      (ref) => GetShloksByChapter(ref.watch(shlokRepositoryProvider)),
);
final getShlokByIdUseCaseProvider = Provider<GetShlokById>(
      (ref) => GetShlokById(ref.watch(shlokRepositoryProvider)),
);
final searchShloksUseCaseProvider = Provider<SearchShloks>(
      (ref) => SearchShloks(ref.watch(shlokRepositoryProvider)),
);

final getBookmarksUseCaseProvider = Provider<GetBookmarks>(
      (ref) => GetBookmarks(ref.watch(bookmarkRepositoryProvider)),
);
final addBookmarkUseCaseProvider = Provider<AddBookmark>(
      (ref) => AddBookmark(ref.watch(bookmarkRepositoryProvider)),
);
final removeBookmarkUseCaseProvider = Provider<RemoveBookmark>(
      (ref) => RemoveBookmark(ref.watch(bookmarkRepositoryProvider)),
);
final updateBookmarkUseCaseProvider = Provider<UpdateBookmark>(
      (ref) => UpdateBookmark(ref.watch(bookmarkRepositoryProvider)),
);

final getCollectionsUseCaseProvider = Provider<GetCollections>(
      (ref) => GetCollections(ref.watch(collectionRepositoryProvider)),
);
final createCollectionUseCaseProvider = Provider<CreateCollection>(
      (ref) => CreateCollection(ref.watch(collectionRepositoryProvider)),
);
final deleteCollectionUseCaseProvider = Provider<DeleteCollection>(
      (ref) => DeleteCollection(ref.watch(collectionRepositoryProvider)),
);
final addItemToCollectionUseCaseProvider = Provider<AddItemToCollection>(
      (ref) => AddItemToCollection(ref.watch(collectionRepositoryProvider)),
);
final removeItemFromCollectionUseCaseProvider =
Provider<RemoveItemFromCollection>(
      (ref) => RemoveItemFromCollection(ref.watch(collectionRepositoryProvider)),
);