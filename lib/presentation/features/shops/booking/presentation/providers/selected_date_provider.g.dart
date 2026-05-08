// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_date_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedDateHash() => r'294414d78088c3a05b9e1200a4e263c867d1fcb9';

/// Provider that holds the currently selected date for booking.
///
/// Simple state provider that tracks the chosen appointment date.
/// Initializes to today's date.
///
/// ## Features
/// - Automatically invalidates slot generation when changed
/// - Used in availability checks
///
/// ## Usage
/// ```dart
/// final date = ref.watch(selectedDateProvider);
/// ref.read(selectedDateProvider.notifier).state = newDate;
/// ```
///
/// Copied from [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
  SelectedDate.new,
  name: r'selectedDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
