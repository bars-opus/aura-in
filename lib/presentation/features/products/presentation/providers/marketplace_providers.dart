// lib/presentation/features/products/presentation/providers/marketplace_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nano_embryo/presentation/features/discover/providers/discovery_seed_provider.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'marketplace_providers.g.dart';
part 'marketplace_providers.freezed.dart';

// ============================================
// Sort Option Enum
// ============================================
enum SortOption {
  discover('Discover'),
  recent('Newest First'),
  priceLowHigh('Price: Low to High'),
  priceHighLow('Price: High to Low'),
  popular('Most Popular');

  final String label;
  const SortOption(this.label);
}

// ============================================
// Filter State (Freezed)
// ============================================
@freezed
class MarketplaceFilterState with _$MarketplaceFilterState {
  const factory MarketplaceFilterState({
    @Default(null) String? category,
    @Default(SortOption.discover) SortOption sortBy,
    @Default(null) double? minPrice,
    @Default(null) double? maxPrice,
    @Default(false) bool showVerifiedOnly,
    @Default(0) int page,
    @Default(20) int limit,
  }) = _MarketplaceFilterState;
}

// ============================================
// Marketplace Filter Notifier
// ============================================
@riverpod
class MarketplaceFilter extends _$MarketplaceFilter {
  @override
  MarketplaceFilterState build() {
    return const MarketplaceFilterState();
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category, page: 0);
  }

  void setSortBy(SortOption sortBy) {
    state = state.copyWith(sortBy: sortBy, page: 0);
  }

  void setPriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice, page: 0);
  }

  void setShowVerifiedOnly(bool showVerifiedOnly) {
    state = state.copyWith(showVerifiedOnly: showVerifiedOnly, page: 0);
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void reset() {
    state = const MarketplaceFilterState();
  }
}

// ============================================
// Marketplace Products Provider (single-page, kept for compatibility)
// ============================================
@riverpod
Future<List<ProductModel>> marketplaceProducts(Ref ref) {
  final filter = ref.watch(marketplaceFilterProvider);
  final repository = ref.watch(productRepositoryProvider);
  final seed = ref.watch(discoverySeedProvider);

  return repository.getMarketplaceProducts(
    category: filter.category,
    sortBy: filter.sortBy,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    showVerifiedOnly: filter.showVerifiedOnly,
    limit: filter.limit,
    page: filter.page,
    seed: seed,
  );
}

// ============================================
// Paginated Marketplace (infinite scroll)
// ============================================

class MarketplaceProductsPagedNotifier extends PagedListNotifier<ProductModel> {
  final Ref _ref;
  MarketplaceProductsPagedNotifier(this._ref) {
    // Filter changes reset and refetch from page 0.
    _ref.listen(marketplaceFilterProvider, (_, __) => refresh());
  }

  @override
  Future<List<ProductModel>> fetchPage(int page, int limit) {
    final filter = _ref.read(marketplaceFilterProvider);
    final seed = _ref.read(discoverySeedProvider);
    return _ref.read(productRepositoryProvider).getMarketplaceProducts(
          category: filter.category,
          sortBy: filter.sortBy,
          minPrice: filter.minPrice,
          maxPrice: filter.maxPrice,
          showVerifiedOnly: filter.showVerifiedOnly,
          limit: limit,
          page: page,
          seed: seed,
        );
  }
}

final marketplaceProductsPagedProvider = StateNotifierProvider.autoDispose<
    MarketplaceProductsPagedNotifier, PagedListState<ProductModel>>(
  (ref) => MarketplaceProductsPagedNotifier(ref),
);
