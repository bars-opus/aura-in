// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviceCategoryListHash() =>
    r'8d3f2a502bb296511ab462d36d01de4a4eed5a58';

/// Provider for service categories (salon, barbers, spa, etc.)
///
/// Copied from [serviceCategoryList].
@ProviderFor(serviceCategoryList)
final serviceCategoryListProvider =
    AutoDisposeFutureProvider<List<ShopTypeCount>>.internal(
  serviceCategoryList,
  name: r'serviceCategoryListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serviceCategoryListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServiceCategoryListRef
    = AutoDisposeFutureProviderRef<List<ShopTypeCount>>;
String _$selectedServiceCategoryHash() =>
    r'9d4b230440117ed3ae1b83e6bbecdaff221ff7af';

/// Current selected service category
///
/// Copied from [SelectedServiceCategory].
@ProviderFor(SelectedServiceCategory)
final selectedServiceCategoryProvider =
    AutoDisposeNotifierProvider<SelectedServiceCategory, String>.internal(
  SelectedServiceCategory.new,
  name: r'selectedServiceCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedServiceCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedServiceCategory = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
