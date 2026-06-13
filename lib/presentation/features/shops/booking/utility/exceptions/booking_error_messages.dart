import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'booking_exceptions.dart';

/// Maps internal exceptions to user-safe error messages.
///
/// Why: raw PostgrestException/AuthException text leaks SQLSTATE codes,
/// constraint names, and schema hints — fails checklist P0-U 2.4 and 5.5.
/// Use at every UI boundary that catches an exception thrown by the
/// booking layer.
class BookingErrorMessages {
  BookingErrorMessages._();

  /// Returns a user-safe message. Never include `$e` or `exception.toString()`
  /// in UI; route through this function instead.
  static String forUser(Object error) {
    if (error is BookingException) {
      return _bookingException(error);
    }
    if (error is PostgrestException) {
      return _postgrest(error);
    }
    if (error is AuthException) {
      return _auth(error);
    }
    if (error is TimeoutException) {
      return 'The request took too long. Check your connection and try again.';
    }
    if (error is SocketException) {
      return 'No internet connection. Please reconnect and try again.';
    }
    if (error is HttpException) {
      return 'Network error. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  static String _bookingException(BookingException e) {
    switch (e.code) {
      case 'SLOT_UNAVAILABLE':
        return 'That time slot is no longer available. Please pick another.';
      case 'WORKER_UNAVAILABLE':
        return 'That staff member is unavailable at the selected time.';
      case 'SLOT_FULL':
        return 'That slot is full. Please pick another time.';
      case 'OUTSIDE_HOURS':
        return 'That time is outside the shop\'s opening hours.';
      case 'VALIDATION_FAILED':
        return 'Please check the booking details and try again.';
      case 'CONFLICT':
        return 'Another booking was just made for that slot. Please pick another time.';
      case 'DATABASE_ERROR':
        return 'Service temporarily unavailable. Please try again.';
    }
    return 'Booking could not be completed. Please try again.';
  }

  static String _postgrest(PostgrestException e) {
    switch (e.code) {
      case '42501':
      case 'PGRST301':
        return 'You don\'t have permission for this action.';
      case '23505':
        return 'This action was already completed.';
      case '23503':
        return 'This item is linked to other data and cannot be changed.';
      case '23514':
      case '22023':
      case '22P02':
        return 'Some of the information is invalid. Please review and try again.';
      case 'P0001':
        return 'Action not allowed in the current state.';
      case 'P0002':
        return 'Requested item could not be found.';
      case 'PGRST116':
        return 'Requested item could not be found.';
      case '57014':
        return 'The request took too long. Please try again.';
    }
    return 'Service temporarily unavailable. Please try again.';
  }

  static String _auth(AuthException e) {
    return 'Please sign in again to continue.';
  }
}
