// lib/features/booking/presentation/providers/selected_date_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_date_provider.g.dart';

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
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  /// Updates the selected date
  void selectDate(DateTime date) {
    // Normalize to start of day for consistent comparisons
    final normalized = DateTime(date.year, date.month, date.day);
    state = normalized;
  }
}
