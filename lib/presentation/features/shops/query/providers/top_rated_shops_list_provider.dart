import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'top_rated_shops_list_provider.g.dart';


class TopRatedShopsListState {
  final List<ShopListItemDTO> shops;
  final String? nextCursor;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasReachedMax;
  final String? luxuryLevel;
  final bool verifiedOnly;
  final String sortBy;

  TopRatedShopsListState({
    required this.shops,
    this.nextCursor,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.hasReachedMax = false,
    this.luxuryLevel,
    this.verifiedOnly = false,
    this.sortBy = 'rating',
  });

  TopRatedShopsListState copyWith({
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
    return TopRatedShopsListState(
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

  factory TopRatedShopsListState.initial() {
    return TopRatedShopsListState(
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

/// keepAlive: discover-screen data persists across tab/route switches.
/// Call refresh() to invalidate stale data.
@Riverpod(keepAlive: true)
class TopRatedShopsList extends _$TopRatedShopsList {
  /// Suppresses ref.listen-driven refetches while applyFilters is in flight.
  bool _isApplyingFilters = false;

  @override
  Future<TopRatedShopsListState> build() {
    // Refetch when radius changes from elsewhere (e.g. Discover screen slider).
    ref.listen<double>(searchRadiusKmProvider, (prev, next) {
      if (_isApplyingFilters) return;
      if (prev != null && prev != next) loadFirstPage();
    });
    return Future.value(TopRatedShopsListState.initial());
  }

  /// Fetches a page of top-rated shops using the quality-ranked non-spatial
  /// view. Top-rated = highest-rated shops platform-wide; radius is not a
  /// filter here (that's NearYou's job). Matches what TopRatedShopsHorizontal
  /// shows so the "See all" screen is consistent with the horizontal preview.
  Future<SearchPaginatedResult<ShopListItemDTO>> _fetchPage({
    required String shopType,
    String? cursor,
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
    final repository = ref.read(shopRepositoryProvider);
    return repository.getTopRatedShopsPaginated(
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

      state = AsyncValue.data(
        TopRatedShopsListState(
          shops: result.items,
          nextCursor: result.nextCursor,
          hasReachedMax: result.nextCursor == null,
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
    if (data == null ||
        data.isLoading ||
        data.hasReachedMax ||
        data.nextCursor == null) {
      return;
    }

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
    await loadFirstPage();
  }
}
