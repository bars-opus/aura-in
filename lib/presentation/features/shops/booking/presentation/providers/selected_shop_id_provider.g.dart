// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_shop_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedShopIdHash() => r'fed196a4cdf2e161e227537e3d8971190247c27d';

/// Provider that holds the ID of the shop currently being booked.
///
/// This is set when entering the booking flow from a shop page
/// and persists throughout the booking process.
///
/// ## Features
/// - Required for slot generation and booking creation
/// - Used in repository calls to filter by shop
/// - Should be reset when leaving the booking flow
///
/// ## Usage
/// ```dart
/// // Set when entering booking flow
/// ref.read(selectedShopIdProvider.notifier).setShopId('shop_123');
///
/// // Read current shop ID
/// final shopId = ref.watch(selectedShopIdProvider);
/// if (shopId == null) {
///   // Redirect to shop selection
/// }
/// ```
///
/// Copied from [SelectedShopId].
@ProviderFor(SelectedShopId)
final selectedShopIdProvider =
    AutoDisposeNotifierProvider<SelectedShopId, String?>.internal(
  SelectedShopId.new,
  name: r'selectedShopIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedShopIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedShopId = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
