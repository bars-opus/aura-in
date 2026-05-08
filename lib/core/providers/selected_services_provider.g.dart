// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedServicesHash() => r'f9cc19938e5a783e02c55f3265e5281a33221e87';

/// Provider that holds the currently selected services in the booking flow.
///
/// This is a simple [StateProvider] because it just holds a list of selected
/// services without complex business logic.
///
/// ## Features
/// - Tracks multiple service selections
/// - Maintains order of selection
/// - Used to calculate total duration and price
///
/// ## Usage
/// ```dart
/// // Read current value
/// final selected = ref.watch(selectedServicesProvider);
///
/// // Update value
/// ref.read(selectedServicesProvider.notifier).state = newList;
/// ```
///
/// Copied from [SelectedServices].
@ProviderFor(SelectedServices)
final selectedServicesProvider = AutoDisposeNotifierProvider<SelectedServices,
    List<AppointmentSlotDTO>>.internal(
  SelectedServices.new,
  name: r'selectedServicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedServicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedServices = AutoDisposeNotifier<List<AppointmentSlotDTO>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
