// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingRepositoryHash() => r'ab7a6bf6a1b1f96988bb4d4c29d9d3df95b34491';

/// Provider for the BookingRepository implementation.
///
/// This is the foundation provider that supplies the repository
/// to all other booking-related providers and controllers.
///
/// ## Usage
/// ```dart
/// final repo = ref.watch(bookingRepositoryProvider);
/// final bookings = await repo.getBookings(params);
/// ```
///
/// Copied from [bookingRepository].
@ProviderFor(bookingRepository)
final bookingRepositoryProvider =
    AutoDisposeProvider<BookingRepository>.internal(
  bookingRepository,
  name: r'bookingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookingRepositoryRef = AutoDisposeProviderRef<BookingRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
