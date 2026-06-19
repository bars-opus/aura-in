import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

part 'near_you_shops_list_provider.g.dart';

// In near_you_shops_list_provider.dart

class NearYouShopsListState {
  final List<ShopListItemDTO> shops;
  final String? nextCursor;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasReachedMax;

  // 👇 Filter fields
  final String? luxuryLevel;
  final bool verifiedOnly;
  final String sortBy; // 'rating' or 'name'

  NearYouShopsListState({
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

  NearYouShopsListState copyWith({
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
    return NearYouShopsListState(
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

  factory NearYouShopsListState.initial() {
    return NearYouShopsListState(
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
/// Call refresh() to invalidate stale data. NOTE: if the user's location
/// changes significantly, call refresh() — `build()` does not re-watch
/// userLocationNotifierProvider.
@Riverpod(keepAlive: true)
class NearYouShopsList extends _$NearYouShopsList {
  /// Suppresses ref.listen-driven refetches while applyFilters is in flight
  /// (otherwise committing radius would race with the explicit refetch).
  bool _isApplyingFilters = false;

  @override
  Future<NearYouShopsListState> build() {
    // React to radius slider changes by refetching the first page.
    ref.listen<double>(searchRadiusKmProvider, (prev, next) {
      if (_isApplyingFilters) return;
      if (prev != null && prev != next) loadFirstPage();
    });
    return Future.value(NearYouShopsListState.initial());
  }

  // 👇 Main method to load first page with filters
  Future<void> loadFirstPage({
    String? cursor,
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
    final userLocation = ref.read(userLocationNotifierProvider);

    if (userLocation == null) {
      state = AsyncValue.data(NearYouShopsListState.initial());
      return;
    }

    final repository = ref.read(shopRepositoryProvider);
    final radiusKm = ref.read(searchRadiusKmProvider);

    // Capture current filter state BEFORE overwriting it with AsyncLoading.
    final currentState = state.asData?.value;
    final effectiveLuxuryLevel = luxuryLevel ?? currentState?.luxuryLevel;
    final effectiveVerifiedOnly =
        verifiedOnly ?? currentState?.verifiedOnly ?? false;
    final effectiveSortBy = sortBy ?? currentState?.sortBy ?? 'rating';

    state = const AsyncValue.loading();

    try {

      final result = await repository.getNearbyShopsPaginated(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        radiusKm: radiusKm,
        cursor: cursor,
        luxuryLevel: effectiveLuxuryLevel,
        verifiedOnly: effectiveVerifiedOnly,
        sortBy: effectiveSortBy,
        limit: AppConstants.shopsPerPage,
      );

      final hasReachedMax = result.items.isEmpty || result.nextCursor == null;

      state = AsyncValue.data(
        NearYouShopsListState(
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

  // 👇 Apply filters method (called from bottom sheet)
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

      // Update state with new filters (optimistic update)
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

  // 👇 Load next page (preserves filters)
  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    final data = currentState.value;
    if (data!.isLoading || data.hasReachedMax || data.nextCursor == null) {
      return;
    }

    state = AsyncValue.data(data.copyWith(isLoading: true));

    try {
      final userLocation = ref.read(userLocationNotifierProvider);
      if (userLocation == null) return;

      final repository = ref.read(shopRepositoryProvider);
      final radiusKm = ref.read(searchRadiusKmProvider);

      final result = await repository.getNearbyShopsPaginated(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        radiusKm: radiusKm,
        cursor: data.nextCursor,
        luxuryLevel: data.luxuryLevel,
        verifiedOnly: data.verifiedOnly,
        sortBy: data.sortBy,
        limit: AppConstants.shopsPerPage,
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
