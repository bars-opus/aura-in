// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$discoverStateHash() => r'a74d366a7e99f442f7ba3b2b0a985fb73e5a29c2';

/// Shared orchestration helpers for the Discover screen.
///
/// NOTE: Loading is no longer triggered from here. shopListProvider watches
/// selectedServiceCategoryProvider and selectedLuxuryLevelProvider directly,
/// so it reloads automatically whenever those change. allFreelancersProvider
/// (FutureProvider) does the same for freelancers. This class now only
/// provides query helpers that don't fit cleanly on individual list providers.
///
/// Copied from [DiscoverState].
@ProviderFor(DiscoverState)
final discoverStateProvider =
    AutoDisposeNotifierProvider<DiscoverState, void>.internal(
  DiscoverState.new,
  name: r'discoverStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$discoverStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiscoverState = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
