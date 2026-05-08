// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_creation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingCreationControllerHash() =>
    r'92fe63c46dd0166da8d72954aca8c6676f464feb';

/// Controller responsible for creating bookings after payment.
///
/// Handles the final booking submission with proper error handling,
/// idempotency, and race condition management.
///
/// ## Features
/// - Idempotency key generation to prevent duplicate bookings
/// - Comprehensive error handling for all booking exceptions
/// - Multi-service booking support
/// - Post-submission state management
///
/// ## Usage
/// ```dart
/// // After successful payment
/// ref.read(bookingCreationControllerProvider.notifier)
///    .createBooking(userId, shopId);
/// ```
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
