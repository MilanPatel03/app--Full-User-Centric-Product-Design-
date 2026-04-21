import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/shlok.dart';
import '../../domain/usecases/get_shloks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Search State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable state for the search screen.
class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.failure,
  });

  final String query;
  final List<Shlok> results;

  /// True while awaiting search results (debounce active).
  final bool isSearching;

  /// Non-null when the last search returned an error.
  final Failure? failure;

  bool get hasQuery => query.trim().length >= 2;
  bool get hasResults => results.isNotEmpty;
  bool get hasError => failure != null;

  SearchState copyWith({
    String? query,
    List<Shlok>? results,
    bool? isSearching,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Manages search state with 400ms debounce.
///
/// Only locally-cached shloks are searchable.
/// Prompt the user to visit chapters for full-text search coverage.
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._useCase) : super(const SearchState());

  final SearchShloks _useCase;
  Timer? _debounce;

  /// Call on every keystroke in the search text field.
  void onQueryChanged(String query) {
    _debounce?.cancel();

    if (query.trim().length < 2) {
      state = SearchState(query: query);
      return;
    }

    state = state.copyWith(query: query, isSearching: true, clearFailure: true);

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final result = await _useCase(SearchShloksParams(query));
      if (!mounted) return;
      state = switch (result) {
        Ok(:final data) => state.copyWith(
            results: data,
            isSearching: false,
            clearFailure: true,
          ),
        Err(:final failure) => state.copyWith(
            failure: failure,
            isSearching: false,
          ),
      };
    });
  }

  /// Clear query and results.
  void clearSearch() {
    _debounce?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(searchShloksUseCaseProvider));
});
