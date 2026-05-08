// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_freelancer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isFreelancerHash() => r'3e199ff99a06b8b247e044491e9cd0a47b5efaa5';

/// Provider that tracks whether the current booking is for a freelancer
///
/// Copied from [IsFreelancer].
@ProviderFor(IsFreelancer)
final isFreelancerProvider =
    AutoDisposeNotifierProvider<IsFreelancer, bool>.internal(
  IsFreelancer.new,
  name: r'isFreelancerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isFreelancerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IsFreelancer = AutoDisposeNotifier<bool>;
String _$selectedAddressHash() => r'29de6a369146de47ff30736cb6cc7ccda0b6ca2b';

/// Provider for selected service address (for freelancer bookings)
///
/// Copied from [SelectedAddress].
@ProviderFor(SelectedAddress)
final selectedAddressProvider =
    AutoDisposeNotifierProvider<SelectedAddress, ParsedAddress?>.internal(
  SelectedAddress.new,
  name: r'selectedAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedAddress = AutoDisposeNotifier<ParsedAddress?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
