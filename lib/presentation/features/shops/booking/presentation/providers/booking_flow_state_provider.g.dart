// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingFlowStateHash() => r'3719cace7f15a217e6577bb93565c05bf87d21ea';

/// Provider that combines all booking flow states into a single cohesive state.
///
/// This provider watches the individual providers and combines them
/// into a [BookingFlowState] object for easy consumption by UI components.
///
/// ## Features
/// - Automatically updates when any dependent provider changes
/// - Calculates derived values (total duration, price, people, completion status)
/// - Provides a single source of truth for the booking flow
///
/// ## Usage
/// ```dart
/// final flowState = ref.watch(bookingFlowStateProvider);
/// if (flowState.isComplete) {
///   // Proceed to payment
/// }
/// ```
///
/// Copied from [bookingFlowState].
@ProviderFor(bookingFlowState)
final bookingFlowStateProvider = AutoDisposeProvider<BookingFlowState>.internal(
  bookingFlowState,
  name: r'bookingFlowStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingFlowStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookingFlowStateRef = AutoDisposeProviderRef<BookingFlowState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
