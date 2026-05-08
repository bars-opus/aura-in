// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_quantity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviceQuantityHash() => r'd69562d5ec9fc88a268d214b6b1aeda15b9951b7';

/// Provider that tracks the quantity (number of people) for each selected service.
///
/// This is essential for group bookings where multiple people book the same service.
///
/// ## Features
/// - Stores quantity per service ID
/// - Default quantity is 1
/// - Validates against max_clients
/// - Automatically cleaned up when services are removed
///
/// ## Usage
/// ```dart
/// // Set quantity for a service
/// ref.read(serviceQuantityProvider.notifier).setQuantity(service.id, 3);
///
/// // Get quantity for a service
/// final qty = ref.watch(serviceQuantityProvider)[service.id] ?? 1;
/// ```
///
/// Copied from [ServiceQuantity].
@ProviderFor(ServiceQuantity)
final serviceQuantityProvider =
    AutoDisposeNotifierProvider<ServiceQuantity, Map<String, int>>.internal(
  ServiceQuantity.new,
  name: r'serviceQuantityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serviceQuantityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ServiceQuantity = AutoDisposeNotifier<Map<String, int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
