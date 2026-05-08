// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_time_slot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedTimeSlotsHash() => r'84f97e279d3b3161c43f8f85b55f025af3c7c45a';

/// Provider that holds the currently selected time slot.
///
/// Simple state provider that tracks which time slot the user has chosen.
/// Initializes to null (no selection).
///
/// ## Features
/// - Used in final booking creation
/// - Triggers flow completion when set
///
/// ## Usage
/// ```dart
/// final slot = ref.watch(selectedTimeSlotProvider);
/// ref.read(selectedTimeSlotProvider.notifier).state = timeSlot;
/// ```
///
/// Copied from [SelectedTimeSlots].
@ProviderFor(SelectedTimeSlots)
final selectedTimeSlotsProvider = AutoDisposeNotifierProvider<SelectedTimeSlots,
    Map<String, TimeSlotModel>>.internal(
  SelectedTimeSlots.new,
  name: r'selectedTimeSlotsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTimeSlotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedTimeSlots = AutoDisposeNotifier<Map<String, TimeSlotModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
