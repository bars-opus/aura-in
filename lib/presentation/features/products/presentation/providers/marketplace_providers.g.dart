// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketplaceProductsHash() =>
    r'2e4edaa01000ae825c92e4f7b2f6a77878f3bc5b';

/// See also [marketplaceProducts].
@ProviderFor(marketplaceProducts)
final marketplaceProductsProvider =
    AutoDisposeFutureProvider<List<ProductModel>>.internal(
  marketplaceProducts,
  name: r'marketplaceProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$marketplaceProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarketplaceProductsRef
    = AutoDisposeFutureProviderRef<List<ProductModel>>;
String _$marketplaceFilterHash() => r'7ca679bf6d21006b786df2a28ff5ad9664451c94';

/// See also [MarketplaceFilter].
@ProviderFor(MarketplaceFilter)
final marketplaceFilterProvider = AutoDisposeNotifierProvider<MarketplaceFilter,
    MarketplaceFilterState>.internal(
  MarketplaceFilter.new,
  name: r'marketplaceFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$marketplaceFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MarketplaceFilter = AutoDisposeNotifier<MarketplaceFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
