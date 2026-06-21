// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shopListHash() => r'0b045f9bb645fa430376c9d46c1a86a02fbd85e8';

/// Paginated main shop list for the Discover screen.
///
/// Architecture notes:
/// - build() uses ref.watch on the two filter providers so Riverpod
///   automatically re-runs it (and cancels the previous in-flight Future)
///   whenever the category or luxury level changes. No manual loadFirstPage()
///   call is needed from the UI layer.
/// - A generation counter lets loadNextPage() discard its result if the
///   filters changed while the page request was in flight.
///
/// Copied from [ShopList].
@ProviderFor(ShopList)
final shopListProvider =
    AutoDisposeAsyncNotifierProvider<ShopList, ShopListState>.internal(
  ShopList.new,
  name: r'shopListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$shopListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShopList = AutoDisposeAsyncNotifier<ShopListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
