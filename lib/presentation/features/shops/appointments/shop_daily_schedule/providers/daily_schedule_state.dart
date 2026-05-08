import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';

class DateCacheKey {
  final String shopId;
  final DateTime date;

  const DateCacheKey({required this.shopId, required this.date});

  String get key => '${shopId}_${date.year}_${date.month}_${date.day}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateCacheKey &&
          runtimeType == other.runtimeType &&
          shopId == other.shopId &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day;

  @override
  int get hashCode => Object.hash(shopId, date.year, date.month, date.day);
}

class DailyScheduleState {
  final Map<DateCacheKey, AsyncValue<List<ShopCalendarBooking>>> cache;
  final DateTime selectedDate;

  const DailyScheduleState({
    required this.cache,
    required this.selectedDate,
  });

  DailyScheduleState copyWith({
    Map<DateCacheKey, AsyncValue<List<ShopCalendarBooking>>>? cache,
    DateTime? selectedDate,
  }) {
    return DailyScheduleState(
      cache: cache ?? this.cache,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  AsyncValue<List<ShopCalendarBooking>>? getAppointmentsForDate(String shopId, DateTime date) {
    final key = DateCacheKey(shopId: shopId, date: date);
    return cache[key];
  }
}
