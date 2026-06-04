// lib/presentation/features/shops/booking/presentation/providers/booking_mutation_signal.dart
//
// Tick counter that fires whenever a booking transitions state in a way
// that materially affects downstream analytics (cancel, no-show,
// complete). Listeners care about the *change*, not the value — read
// it with `ref.listen<int>(...)` and refetch on every tick.
//
// Do NOT route through the repository or any model layer — Riverpod
// refs must stay out of the data layer. Mutators reach for this
// provider directly from the controller/notifier callsite.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped after any terminal booking state transition (cancel, no-show,
/// complete) so analytics-side controllers can react without polling.
///
/// Wiring:
///   - `DailyScheduleNotifier.cancelBooking` (lines ~83)
///   - `DailyScheduleNotifier.markBookingAsNoShow` (lines ~89)
///   - `DailyScheduleNotifier.markBookingAsCompleted` (lines ~75)
///
/// Listeners:
///   - `lostBookingsControllerProviderFamily` — refetches the headline
///     card so the lost-rate stays current without pull-to-refresh.
final bookingMutationProvider = StateProvider<int>((ref) => 0);
