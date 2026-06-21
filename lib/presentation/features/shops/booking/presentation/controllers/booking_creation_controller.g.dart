// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_creation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingCreationControllerHash() =>
    r'746e1578d06419ac0990025b84354ff2dabfca15';

/// Controller responsible for creating bookings after payment.
///
/// Pre-validates the draft client-side (services selected, time slots
/// assigned, group quantities within max_clients), then posts to the
/// server through a single idempotency key. The key is generated once
/// in `build()` and reused across retries; the underlying RPC dedupes
/// on it.
///
/// Copied from [BookingCreationController].
@ProviderFor(BookingCreationController)
final bookingCreationControllerProvider = AutoDisposeNotifierProvider<
    BookingCreationController, BookingCreationState>.internal(
  BookingCreationController.new,
  name: r'bookingCreationControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingCreationControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingCreationController = AutoDisposeNotifier<BookingCreationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
