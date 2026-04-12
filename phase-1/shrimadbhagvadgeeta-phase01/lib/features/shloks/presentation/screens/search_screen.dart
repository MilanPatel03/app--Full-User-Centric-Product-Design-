import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../providers/search_provider.dart';

/// Search screen with live debounced search.
///
/// State: [searchProvider] (StateNotifier — autoDispose)
/// Uses [ConsumerStatefulWidget] to manage the [TextEditingController].
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: context.wisdomBody,
          cursorColor: scheme.primary,
          decoration: InputDecoration(
            hintText: 'Search verses, translations...',
            hintStyle: context.utilityCaption
                .copyWith(color: scheme.secondary),
            border: InputBorder.none,
            suffixIcon: searchState.hasQuery
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).clearSearch();
                    },
                  )
                : null,
          ),
          onChanged: (q) =>
              ref.read(searchProvider.notifier).onQueryChanged(q),
        ),
      ),
      body: _buildBody(context, searchState, scheme),
    );
  }

  Widget _buildBody(BuildContext context, SearchState state, ColorScheme scheme) {
    if (!state.hasQuery) {
      return Center(
        child: Text(
          'Type at least 2 characters to search',
          style: context.utilityCaption.copyWith(color: scheme.secondary),
        ),
      );
    }

    if (state.isSearching) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 1.5),
      );
    }

    if (state.hasError) {
      return Center(
        child: Text(
          state.failure!.message,
          style: context.utilityCaption.copyWith(color: scheme.error),
        ),
      );
    }

    if (!state.hasResults) {
      return Center(
        child: Text(
          'No verses found for "${state.query}"',
          style: context.utilityCaption.copyWith(color: scheme.secondary),
        ),
      );
    }

    // Results placeholder — replaced in Step 5
    return Center(
      child: SectionContainer(
        tier: SurfaceTier.medium,
        padding: AppEdgeInsets.card,
        borderRadius: AppRadius.lgBorder,
        child: Text(
          '${state.results.length} verses found',
          style: context.wisdomTitle,
        ),
      ),
    );
    // TODO (Step 5): Replace with ShlokSearchResultList
  }
}
