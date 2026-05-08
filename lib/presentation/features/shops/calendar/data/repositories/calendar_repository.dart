import 'package:nano_embryo/presentation/features/shops/booking/data/repositories/booking_repository.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/client_calendar_booking.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';

/// Repository specifically for calendar views.
/// Wraps the main booking repository and transforms data for calendar display.
class CalendarRepository {
  final BookingRepository _bookingRepository;

  CalendarRepository({required BookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  /// Fetch client bookings for a date range and transform to minimal mode
  // In calendar_repository.dart
  Future<List<ClientCalendarBooking>> getClientBookingsForRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _bookingRepository.getClientBookings(
      userId: userId,
      fromDate: startDate,
      toDate: endDate,
      pageSize: 100,
    );

    return result.bookings
        .map((booking) => ClientCalendarBooking.fromJson(booking.toJson()))
        .toList();
  }

  /// Fetch shop bookings for a date range and transform to minimal model
  Future<List<ShopCalendarBooking>> getShopBookingsForRange({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _bookingRepository.getShopBookings(
      shopId: shopId,
      fromDate: startDate,
      toDate: endDate,
      pageSize: 100, // Fetch up to 100 bookings for the month
    );

    return result.bookings
        .map((booking) => ShopCalendarBooking.fromJson(booking.toJson()))
        .toList();
  }

  // /// Check if a user owns any shops (to determine if they're a shop owner)
  // Future<bool> userOwnsShops(String userId) async {
  //   // This would be implemented to check shops table
  //   // For now, we'll assume a method exists on bookingRepository
  //   return _bookingRepository.userHasShops(userId);
  // }

  /// Get all shops owned by a user (for shop selector)
 
}
