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
  // 👇 New filter fields
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

@riverpod
class TopRatedShopsList extends _$TopRatedShopsList {
  @override
  Future<TopRatedShopsListState> build() {
    return Future.value(TopRatedShopsListState.initial());
  }

  Future<void> loadFirstPage({
    String? cursor,
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
    final shopType = ref.read(selectedServiceCategoryProvider);
    final repository = ref.read(shopRepositoryProvider);
    // final selectedLuxury = ref.read(selectedLuxuryLevelProvider);

    final currentState = state.asData?.value;
    final effectiveLuxuryLevel = luxuryLevel ?? currentState?.luxuryLevel;
    final effectiveVerifiedOnly =
        verifiedOnly ?? currentState?.verifiedOnly ?? false;
    final effectiveSortBy = sortBy ?? currentState?.sortBy ?? 'rating';

    state = const AsyncValue.loading();

    try {
      final result = await repository.getTopRatedShopsPaginated(
        shopType: shopType,
        cursor: cursor,
        // luxuryLevel: selectedLuxury ?? '',
        limit: AppConstants.shopsPerPage,

        luxuryLevel: effectiveLuxuryLevel,
        verifiedOnly: effectiveVerifiedOnly,
        sortBy: effectiveSortBy,
      );

      state = AsyncValue.data(
        TopRatedShopsListState(
          shops: result.items,
          nextCursor: result.nextCursor,
          hasReachedMax: result.nextCursor == null,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 👇 New method to apply filters
  Future<void> applyFilters({
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
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

    // Reload first page with new filters
    await loadFirstPage(
      luxuryLevel: luxuryLevel,
      verifiedOnly: verifiedOnly,
      sortBy: sortBy,
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! AsyncData) return;
    final data = currentState.value;
    // 👈 Don't load if already loading, reached max, or no next cursor
    if (data == null || data.isLoading || data.hasReachedMax || data.nextCursor == null) {
      return;
    }

    state = AsyncValue.data(data.copyWith(isLoading: true));

    try {
      final shopType = ref.read(selectedServiceCategoryProvider);
      final repository = ref.read(shopRepositoryProvider);
      final result = await repository.getTopRatedShopsPaginated(
        shopType: shopType,
        cursor: data.nextCursor,
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
