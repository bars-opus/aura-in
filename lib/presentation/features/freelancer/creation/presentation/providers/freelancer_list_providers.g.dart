// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freelancer_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$topRatedFreelancersListHash() =>
    r'24e60579a010577c7295a1331f733051953fd0c9';

/// Provider for top rated freelancers list (paginated).
/// keepAlive: discover-screen data persists across tab/route switches.
/// Call refresh() to invalidate stale data.
///
/// Copied from [TopRatedFreelancersList].
@ProviderFor(TopRatedFreelancersList)
final topRatedFreelancersListProvider = AsyncNotifierProvider<
    TopRatedFreelancersList, FreelancerListState>.internal(
  TopRatedFreelancersList.new,
  name: r'topRatedFreelancersListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topRatedFreelancersListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TopRatedFreelancersList = AsyncNotifier<FreelancerListState>;
String _$nearbyFreelancersListHash() =>
    r'3744b845d71175891d3808afa719862f2658b54a';

/// Provider for nearby freelancers list (paginated).
/// keepAlive: discover-screen data persists across tab/route switches.
/// Call refresh() to invalidate stale data when location changes significantly.
///
/// Copied from [NearbyFreelancersList].
@ProviderFor(NearbyFreelancersList)
final nearbyFreelancersListProvider =
    AsyncNotifierProvider<NearbyFreelancersList, FreelancerListState>.internal(
  NearbyFreelancersList.new,
  name: r'nearbyFreelancersListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nearbyFreelancersListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NearbyFreelancersList = AsyncNotifier<FreelancerListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
