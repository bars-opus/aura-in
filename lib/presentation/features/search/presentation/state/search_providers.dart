// lib/features/search/presentation/state/search_providers.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/profile/repositories/supabase_profile_repository.dart';
import 'package:nano_embryo/presentation/features/profile/repositories/profile_repository_interface.dart';
import 'package:nano_embryo/presentation/features/search/domain/local/search_history_storage.dart';
import 'package:nano_embryo/presentation/features/search/domain/models/category_search_section.dart';
import 'package:nano_embryo/presentation/features/search/domain/models/search_params.dart';
import 'package:nano_embryo/presentation/features/search/domain/repositories/freelancer_search_repository.dart';
import 'package:nano_embryo/presentation/features/search/domain/repositories/profile_search_repository.dart';
import 'package:nano_embryo/presentation/features/search/domain/repositories/shop_search_repository.dart';
import 'package:nano_embryo/presentation/features/search/domain/repositories/unified_search_repository.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart';

// ==================== DEPENDENCY PROVIDERS ====================

final supabaseShopRepositoryProvider = Provider<SupabaseShopRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseShopRepository(client);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(client);
});

final shopSearchRepositoryProvider = Provider<ShopSearchRepository>((ref) {
  final shopRepo = ref.watch(supabaseShopRepositoryProvider);
  return ShopSearchRepository(shopRepo);
});

final profileSearchRepositoryProvider = Provider<ProfileSearchRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileSearchRepository(client);
});

// Add freelancer repository provider
final freelancerSearchRepositoryProvider = Provider<FreelancerSearchRepository>(
  (ref) {
    final freelancerRepo = ref.watch(freelancerRepositoryProvider);
    return FreelancerSearchRepository(freelancerRepo);
  },
);

// Update unifiedSearchRepositoryProvider
final unifiedSearchRepositoryProvider = Provider<UnifiedSearchRepository>((
  ref,
) {
  final shopSearch = ref.watch(shopSearchRepositoryProvider);
  final profileSearch = ref.watch(profileSearchRepositoryProvider);
  final freelancerSearch = ref.watch(
    freelancerSearchRepositoryProvider,
  ); // Add this
  return UnifiedSearchRepository(
    shopRepository: shopSearch,
    profileRepository: profileSearch,
    freelancerRepository: freelancerSearch, // Add this
  );
});
// ==================== STATE PROVIDERS ====================

/// Current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Current search filters
final searchFiltersProvider = StateProvider<SearchFilters>((ref) {
  return const SearchFilters();
});

/// Selected category (null = All)
final selectedCategoryProvider = StateProvider<SearchCategory?>((ref) => null);

/// Search history with persistence
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>(
      (ref) => SearchHistoryNotifier(),
    );

/// All sections provider (for "All" view)
// lib/features/search/presentation/state/search_providers.dart

// Change this provider to use searchAllSections instead of searchAllSectionsWithCache
final allSearchSectionsProvider = FutureProvider<List<CategorySearchSection>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  final filters = ref.watch(searchFiltersProvider);

  if (query.isEmpty) {
    return [];
  }

  final repository = ref.watch(unifiedSearchRepositoryProvider);
  final params = SearchParams.forAllView(query: query, filters: filters);

  // ✅ Use searchAllSections (no cache)
  return await repository.searchAllSections(params: params);
});

/// Main search provider
final searchProvider = StateNotifierProvider<
  SearchNotifier,
  AsyncValue<SearchPaginatedResult<UnifiedSearchResult>>
>((ref) => SearchNotifier(ref));

// ==================== SEARCH NOTIFIER ====================

class SearchNotifier
    extends
        StateNotifier<AsyncValue<SearchPaginatedResult<UnifiedSearchResult>>> {
  final Ref _ref;
  Timer? _debounceTimer;
  // Monotonically increasing token. Each new search increments it; only
  // the latest in-flight call is allowed to write to state. Prevents a
  // slow earlier request from overwriting a fast later one.
  int _requestToken = 0;

  SearchNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> search(String query, {bool debounce = true}) async {
    if (query.isEmpty) {
      _debounceTimer?.cancel();
      _requestToken++; // invalidate any in-flight call
      state = AsyncValue.data(
        SearchPaginatedResult<UnifiedSearchResult>.empty(),
      );
      return;
    }

    _debounceTimer?.cancel();

    if (debounce) {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        await _performSearch(query);
      });
    } else {
      await _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    final token = ++_requestToken;

    state = const AsyncValue.loading();

    try {
      final filters = _ref.read(searchFiltersProvider);
      final repository = _ref.read(unifiedSearchRepositoryProvider);

      final params = SearchParams.forAllView(query: query, filters: filters);

      final sections = await repository.searchAllSections(params: params);

      // Stale-result guard: another search started after we did. Drop
      // these results silently — the latest call owns the state.
      if (token != _requestToken) return;

      final allResults = sections.expand((s) => s.results).toList();

      state = AsyncValue.data(
        SearchPaginatedResult<UnifiedSearchResult>(
          items: allResults,
          nextCursor: null,
          totalCount: allResults.length,
        ),
      );

      await _ref.read(searchHistoryProvider.notifier).addToHistory(query);
    } catch (e, stack) {
      if (token != _requestToken) return;
      state = AsyncValue.error(e, stack);
    }
  }

  void updateFilters(SearchFilters filters) {
    _ref.read(searchFiltersProvider.notifier).state = filters;
    final query = _ref.read(searchQueryProvider);
    if (query.isNotEmpty) {
      search(query, debounce: false);
    }
  }

  void clear() {
    _ref.read(searchQueryProvider.notifier).state = '';
    state = AsyncValue.data(SearchPaginatedResult<UnifiedSearchResult>.empty());
    _debounceTimer?.cancel();
    _requestToken++;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// ==================== SEARCH HISTORY NOTIFIER ====================

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await SearchHistoryStorage.loadHistory();
    state = history;
  }

  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    final newHistory =
        [query, ...state.where((item) => item != query)].take(20).toList();

    state = newHistory;
    await SearchHistoryStorage.saveHistory(state);
  }

  Future<void> removeFromHistory(String query) async {
    final newHistory = state.where((item) => item != query).toList();
    state = newHistory;
    await SearchHistoryStorage.saveHistory(state);
  }

  Future<void> clearHistory() async {
    state = [];
    await SearchHistoryStorage.clearHistory();
  }
}

// lib/features/search/presentation/state/search_providers.dart

// Add this after other providers

/// Category-specific search results provider (with pagination)
final categorySearchResultsProvider = StateNotifierProvider.family<
  CategorySearchNotifier,
  AsyncValue<SearchPaginatedResult<UnifiedSearchResult>>,
  SearchCategory
>((ref, category) {
  final repository = ref.watch(unifiedSearchRepositoryProvider);
  return CategorySearchNotifier(repository, ref, category);
});

// lib/features/search/presentation/state/search_providers.dart

class CategorySearchNotifier
    extends
        StateNotifier<AsyncValue<SearchPaginatedResult<UnifiedSearchResult>>> {
  final UnifiedSearchRepository _repository;
  final Ref _ref;
  final SearchCategory _category;
  String? _currentCursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  int _requestToken = 0;

  CategorySearchNotifier(this._repository, this._ref, this._category)
    : super(const AsyncValue.loading());

  Future<void> search(String query, SearchFilters filters) async {
    if (query.isEmpty) {
      _requestToken++;
      state = AsyncValue.data(
        SearchPaginatedResult<UnifiedSearchResult>.empty(),
      );
      return;
    }

    final token = ++_requestToken;
    _currentCursor = null;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncValue.loading();

    try {
      final params = SearchParams.forCategoryView(
        query: query,
        filters: filters,
        category: _category,
        isInitialLoad: true,
        limit: 15,
      );

      final result = await _repository.searchByCategory(params: params);

      if (token != _requestToken) return;

      _hasMore = result.hasMore;
      state = AsyncValue.data(result);
    } catch (e, stack) {
      if (token != _requestToken) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    // ✅ Don't load if already loading, no more items, or currently loading more
    if (_isLoadingMore || !_hasMore) return;

    final currentState = state;
    if (currentState is! AsyncData) return;

    final currentResults = currentState.value;
    if (currentResults!.items.isEmpty) return;

    _currentCursor = currentResults.nextCursor;

    // ✅ Don't load more if no cursor
    if (_currentCursor == null) {
      _hasMore = false;
      return;
    }

    _isLoadingMore = true;
    final token = _requestToken;

    try {
      final query = _ref.read(searchQueryProvider);
      final filters = _ref.read(searchFiltersProvider);

      final params = SearchParams.forCategoryView(
        query: query,
        filters: filters,
        category: _category,
        cursor: _currentCursor,
        isInitialLoad: false,
        limit: 5,
      );

      final moreResults = await _repository.searchByCategory(params: params);

      // A new search() started while we were paginating — discard.
      if (token != _requestToken) return;

      final allItems = [...currentResults.items, ...moreResults.items];
      final newResult = SearchPaginatedResult<UnifiedSearchResult>(
        items: allItems,
        nextCursor: moreResults.nextCursor,
        totalCount: moreResults.totalCount,
      );

      _hasMore = moreResults.hasMore;
      state = AsyncValue.data(newResult);
    } catch (e, stack) {
      if (token != _requestToken) return;
      state = AsyncValue.error(e, stack);
    } finally {
      _isLoadingMore = false;
    }
  }

  void reset() {
    final query = _ref.read(searchQueryProvider);
    final filters = _ref.read(searchFiltersProvider);
    search(query, filters);
  }
}
