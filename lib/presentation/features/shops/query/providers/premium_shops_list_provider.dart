import 'package:nano_embryo/presentation/features/discover/providers/discovery_seed_provider.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'premium_shops_list_provider.g.dart';

// lib/features/shops/presentation/providers/premium_shops_list_provider.dart

class PremiumShopsListState {
  final List<ShopListItemDTO> shops;
  final String? nextCursor;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasReachedMax;

  // 👇 New filter fields
  final String? luxuryLevel;
  final bool verifiedOnly;
  final String sortBy; // 'rating', 'price_asc', 'price_desc', 'name'

  PremiumShopsListState({
    required this.shops,
    this.nextCursor,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.hasReachedMax = false,
    this.luxuryLevel,
    this.verifiedOnly = false,
    this.sortBy = 'rating', // Default sort by rating
  });

  PremiumShopsListState copyWith({
    List<ShopListItemDTO>? shops,
    String? nextCursor,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? hasReachedMax,
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
  }) {
    return PremiumShopsListState(
      shops: shops ?? this.shops,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      luxuryLevel: luxuryLevel ?? this.luxuryLevel,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  factory PremiumShopsListState.initial() {
    return PremiumShopsListState(
      shops: [],
      nextCursor: null,
      isLoading: true,
      hasError: false,
      errorMessage: null,
      hasReachedMax: false,
      luxuryLevel: null,
      verifiedOnly: false,
      sortBy: 'rating',
    );
  }
}

/// keepAlive: discover-screen data persists across tab/route switches so the
/// user doesn't refetch on every back-navigation. Memory is bounded (a few
/// hundred DTOs at worst); call refresh() to invalidate stale data.
@Riverpod(keepAlive: true)
class PremiumShopsList extends _$PremiumShopsList {
  /// Suppresses ref.listen-driven refetches while applyFilters is in flight
  /// (otherwise committing radius would race with the explicit refetch).
  bool _isApplyingFilters = false;

  @override
  Future<PremiumShopsListState> build() {
    // Refetch when radius changes from elsewhere (e.g. Discover screen slider).
    ref.listen<double>(searchRadiusKmProvider, (prev, next) {
      if (_isApplyingFilters) return;
      if (prev != null && prev != next) loadFirstPage();
    });
    return Future.value(PremiumShopsListState.initial());
  }

  /// Fetches a page of premium shops using the quality-ranked non-spatial
  /// view. Premium = best luxury shops platform-wide; radius is not a filter
  /// here (that's NearYou's job). Radius changes still trigger a refetch so
  /// the filter-modal radius value is persisted globally, but the query itself
  /// is always non-spatial — matching what PremiumShopsHorizontal shows.
  Future<SearchPaginatedResult<ShopListItemDTO>> _fetchPage({
    required String shopType,
    String? cursor,
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
    final repository = ref.read(shopRepositoryProvider);
    return repository.getPremiumShopsPaginated(
      shopType: shopType,
      luxuryLevel: luxuryLevel,
      verifiedOnly: verifiedOnly,
      sortBy: sortBy,
      cursor: cursor,
      limit: AppConstants.shopsPerPage,
    );
  }

  Future<void> loadFirstPage({
    String? cursor,
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
    final shopType = ref.read(selectedServiceCategoryProvider);

    final currentState = state.asData?.value;
    final effectiveLuxuryLevel = luxuryLevel ?? currentState?.luxuryLevel;
    final effectiveVerifiedOnly =
        verifiedOnly ?? currentState?.verifiedOnly ?? false;
    final effectiveSortBy = sortBy ?? currentState?.sortBy ?? 'rating';

    state = const AsyncValue.loading();

    try {
      final result = await _fetchPage(
        shopType: shopType,
        cursor: cursor,
        luxuryLevel: effectiveLuxuryLevel,
        verifiedOnly: effectiveVerifiedOnly,
        sortBy: effectiveSortBy,
      );

      final hasReachedMax = result.items.isEmpty || result.nextCursor == null;

      state = AsyncValue.data(
        PremiumShopsListState(
          shops: result.items,
          nextCursor: result.nextCursor,
          hasReachedMax: hasReachedMax,
          isLoading: false,
          luxuryLevel: effectiveLuxuryLevel,
          verifiedOnly: effectiveVerifiedOnly,
          sortBy: effectiveSortBy,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> applyFilters({
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
    double? radiusKm,
  }) async {
    _isApplyingFilters = true;
    try {
      // Commit radius first so other screens see it. The flag prevents the
      // ref.listen above from also kicking off a refetch.
      if (radiusKm != null) {
        ref.read(searchRadiusKmProvider.notifier).state = radiusKm;
      }

      final currentState = state;
      if (currentState is AsyncData) {
        final newState = currentState.value?.copyWith(
          luxuryLevel: luxuryLevel,
          verifiedOnly: verifiedOnly ?? currentState.value?.verifiedOnly,
          sortBy: sortBy ?? currentState.value?.sortBy,
        );
        state = AsyncValue.data(newState!);
      }

      await loadFirstPage(
        luxuryLevel: luxuryLevel,
        verifiedOnly: verifiedOnly,
        sortBy: sortBy,
      );
    } finally {
      _isApplyingFilters = false;
    }
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    final data = currentState.value;
    // 👈 Don't load if already loading, reached max, or no next cursor
    if (data == null || data.isLoading || data.hasReachedMax || data.nextCursor == null) {
      return;
    }

    // Update to loading state
    state = AsyncValue.data(data.copyWith(isLoading: true));

    try {
      final shopType = ref.read(selectedServiceCategoryProvider);

      final result = await _fetchPage(
        shopType: shopType,
        cursor: data.nextCursor,
        luxuryLevel: data.luxuryLevel,
        verifiedOnly: data.verifiedOnly,
        sortBy: data.sortBy,
      );

      // Deduplicate by id — guards against overlap from offset shifts or
      // view row multiplication (shops_with_cover JOIN fanout).
      final seen = <String>{...data.shops.map((s) => s.id)};
      final newItems = result.items.where((s) => seen.add(s.id)).toList();
      final updatedShops = [...data.shops, ...newItems];

      final hasReachedMax = result.items.isEmpty || result.nextCursor == null;

      state = AsyncValue.data(
        data.copyWith(
          shops: updatedShops,
          nextCursor: result.nextCursor,
          isLoading: false,
          hasReachedMax: hasReachedMax,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        data.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    reshuffleDiscovery(ref);
    await loadFirstPage();
  }
}
