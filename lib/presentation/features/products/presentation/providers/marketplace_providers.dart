// lib/presentation/features/products/presentation/providers/marketplace_providers.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'marketplace_providers.g.dart';
part 'marketplace_providers.freezed.dart';

// ============================================
// Sort Option Enum
// ============================================
enum SortOption {
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
    @Default(SortOption.recent) SortOption sortBy,
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
// Marketplace Products Provider
// ============================================
@riverpod
Future<List<ProductModel>> marketplaceProducts(MarketplaceProductsRef ref) {
  final filter = ref.watch(marketplaceFilterProvider);
  final repository = ref.watch(productRepositoryProvider);

  return repository.getMarketplaceProducts(
    category: filter.category,
    sortBy: filter.sortBy,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    showVerifiedOnly: filter.showVerifiedOnly,
    limit: filter.limit,
    page: filter.page,
  );
}
