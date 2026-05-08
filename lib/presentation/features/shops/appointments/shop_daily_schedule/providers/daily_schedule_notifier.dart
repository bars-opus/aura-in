import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/repositories/booking_repository.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';
import 'daily_schedule_state.dart';

class DailyScheduleNotifier extends StateNotifier<DailyScheduleState> {
  final BookingRepository _bookingRepository;
  final String _shopId;

  DailyScheduleNotifier({
    required BookingRepository bookingRepository,
    required String shopId,
  }) : _bookingRepository = bookingRepository,
       _shopId = shopId,
       super(DailyScheduleState(cache: {}, selectedDate: DateTime.now())) {
    _loadAppointmentsForDate(DateTime.now());
  }

  Future<void> _loadAppointmentsForDate(DateTime date) async {
    final key = DateCacheKey(shopId: _shopId, date: date);

    if (state.cache.containsKey(key)) {
      return;
    }

    state = state.copyWith(
      cache: {...state.cache, key: const AsyncValue.loading()},
    );

    try {
      // Use the new getAppointmentsForDate method from BookingRepository
      final result = await _bookingRepository.getAppointmentsForDate(
        shopId: _shopId,
        date: date,
      );
      state = state.copyWith(
        cache: {
          ...state.cache,
          key: AsyncValue.data(
            result.bookings,
          ), // result.bookings is List<ShopCalendarBooking>
        },
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        cache: {...state.cache, key: AsyncValue.error(error, stackTrace)},
      );
    }
  }

  Future<void> refreshDate(DateTime date) async {
    final key = DateCacheKey(shopId: _shopId, date: date);
    final newCache =
        Map<DateCacheKey, AsyncValue<List<ShopCalendarBooking>>>.from(
          state.cache,
        )..remove(key);
    state = state.copyWith(cache: newCache);
    await _loadAppointmentsForDate(date);
  }

  void selectDate(DateTime date) {
    if (state.selectedDate == date) return;
    state = state.copyWith(selectedDate: date);
    _loadAppointmentsForDate(date);
  }

  bool isLoading(DateTime date) {
    final key = DateCacheKey(shopId: _shopId, date: date);
    final cached = state.cache[key];
    return cached?.isLoading ?? false;
  }

  Future<void> markBookingAsCompleted(String bookingId, DateTime date) async {
    await _bookingRepository.markAsComplete(bookingId);
    await refreshDate(date);
  }

  Future<void> cancelBooking(
    String bookingId,
    DateTime date, {
    String? reason,
  }) async {
    await _bookingRepository.cancelBooking(bookingId, reason: reason);
    await refreshDate(date);
  }

  Future<void> markBookingAsNoShow(String bookingId, DateTime date) async {
    // This should be added to BookingRepository
    await _bookingRepository.markAsNoShow(bookingId,);
    await refreshDate(date);
  }
}
