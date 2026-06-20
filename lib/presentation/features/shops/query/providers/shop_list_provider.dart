// lib/features/shops/presentation/providers/shop_list_provider.dart

import 'package:nano_embryo/presentation/features/discover/providers/discovery_seed_provider.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_query_params.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/selected_luxury_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/service_category_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shop_list_provider.g.dart';

// Sentinel used in copyWith to distinguish "caller passed null" from "caller
// didn't pass anything" for nullable fields like nextCursor.
const Object _kAbsent = Object();

class ShopListState {
  final String shopType;
  final String? luxuryLevel;
  final List<ShopListItemDTO> shops;
  final String? nextCursor;
  // isLoading is ONLY true during pagination (loadNextPage).
  // Initial loading is reflected by the outer AsyncValue being AsyncLoading.
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasReachedMax;

  const ShopListState({
    required this.shopType,
    this.luxuryLevel,
    required this.shops,
    this.nextCursor,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.hasReachedMax = false,
  });

  ShopListState copyWith({
    List<ShopListItemDTO>? shops,
    // Use _kAbsent default so callers can explicitly pass null to clear.
    Object? nextCursor = _kAbsent,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return ShopListState(
      shopType: shopType,
      luxuryLevel: luxuryLevel,
      shops: shops ?? this.shops,
      nextCursor:
          identical(nextCursor, _kAbsent)
              ? this.nextCursor
              : nextCursor as String?,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// Paginated main shop list for the Discover screen.
///
/// Architecture notes:
/// - build() uses ref.watch on the two filter providers so Riverpod
///   automatically re-runs it (and cancels the previous in-flight Future)
///   whenever the category or luxury level changes. No manual loadFirstPage()
///   call is needed from the UI layer.
/// - A generation counter lets loadNextPage() discard its result if the
///   filters changed while the page request was in flight.
@riverpod
class ShopList extends _$ShopList {
  // Incremented every time build() runs (i.e., on every filter change or
  // provider recreation). loadNextPage captures this on entry and bails if
  // it has changed by the time the async result arrives.
  int _generation = 0;

  @override
  Future<ShopListState> build() async {
    final shopType = ref.watch(selectedServiceCategoryProvider);
    final luxuryLevel = ref.watch(selectedLuxuryLevelProvider);
    final seed = ref.watch(discoverySeedProvider);
    _generation++;

    final params = ShopQueryParams(
      shopType: shopType,
      luxuryLevel: luxuryLevel,
      verifiedOnly: false,
      sortBy: 'created_at',
      limit: AppConstants.shopsPerPage,
      seed: seed,
    );

    final result = await ref.read(shopRepositoryProvider).getShops(params);

    return ShopListState(
      shopType: shopType,
      luxuryLevel: luxuryLevel,
      shops: result.items,
      nextCursor: result.nextCursor,
      hasReachedMax: result.nextCursor == null,
    );
  }

  /// Appends the next cursor page to the existing list.
  Future<void> loadNextPage() async {
    final gen = _generation;

    // valueOrNull returns null for AsyncLoading / AsyncError, letting the null
    // check narrow the type to non-nullable ShopListState without relying on
    // AsyncData smart-cast (which requires an explicit generic type argument).
    final data = state.valueOrNull;
    if (data == null || data.isLoading || data.hasReachedMax) return;

    state = AsyncValue.data(data.copyWith(isLoading: true));

    try {
      // Build params from state (not from a global params provider) so they
      // always match the data already on screen.
      final baseParams = ShopQueryParams(
        shopType: data.shopType,
        luxuryLevel: data.luxuryLevel,
        verifiedOnly: false,
        sortBy: 'created_at',
        limit: AppConstants.shopsPerPage,
        seed: ref.read(discoverySeedProvider),
      );

      final result = await ref
          .read(shopRepositoryProvider)
          .getShops(baseParams.copyWith(cursor: data.nextCursor));

      // Discard stale results if filters changed during the fetch.
      if (_generation != gen) return;

      state = AsyncValue.data(
        data.copyWith(
          shops: [...data.shops, ...result.items],
          nextCursor: result.nextCursor,
          isLoading: false,
          hasReachedMax: result.nextCursor == null,
        ),
      );
    } catch (e, stack) {
      if (_generation != gen) return;
      state = AsyncValue.data(
        data.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Forces a fresh first-page load with the current filter state.
  /// Regenerates the discovery seed so the reshuffled order is used.
  Future<void> refresh() async {
    reshuffleDiscovery(ref);
    ref.invalidateSelf();
    await future;
  }
}
