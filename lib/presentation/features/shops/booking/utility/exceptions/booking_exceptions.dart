// lib/features/booking/data/exceptions/booking_exceptions.dart

/// Base exception for all booking-related errors.
abstract class BookingException implements Exception {
  final String message;
  final String? code;

  BookingException(this.message, {this.code});
}

/// Thrown when a requested time slot is no longer available.
class SlotUnavailableException extends BookingException {
  SlotUnavailableException({String? slotId, DateTime? requestedTime})
    : super(
        'The requested time slot is no longer available${slotId != null ? ' for slot $slotId' : ''}${requestedTime != null ? ' at ${requestedTime.toIso8601String()}' : ''}. Please select another time.',
        code: 'SLOT_UNAVAILABLE',
      );
}

/// Thrown when a worker is already booked for the requested time.
class WorkerUnavailableException extends BookingException {
  final String workerId;
  final DateTime requestedTime;

  WorkerUnavailableException({
    required this.workerId,
    required this.requestedTime,
  }) : super(
         'The selected worker is not available at ${requestedTime.toIso8601String()}. Please choose another worker or time.',
         code: 'WORKER_UNAVAILABLE',
       );
}

/// Thrown when a group slot has reached maximum capacity.
class SlotFullException extends BookingException {
  final String slotId;
  final DateTime slotTime;
  final int maxCapacity;

  SlotFullException({
    required this.slotId,
    required this.slotTime,
    required this.maxCapacity,
  }) : super(
         'This time slot has reached its maximum capacity of $maxCapacity. Please select another time.',
         code: 'SLOT_FULL',
       );
}

/// Thrown when attempting to book outside shop hours.
class OutsideBusinessHoursException extends BookingException {
  final DateTime requestedTime;
  final String shopHours;

  OutsideBusinessHoursException({
    required this.requestedTime,
    required this.shopHours,
  }) : super(
         'The requested time ${requestedTime.toIso8601String()} is outside shop business hours ($shopHours).',
         code: 'OUTSIDE_HOURS',
       );
}

/// Thrown when booking validation fails.
class BookingValidationException extends BookingException {
  final Map<String, String> validationErrors;

  BookingValidationException(this.validationErrors)
    : super(
        'Booking validation failed: ${validationErrors.values.join(', ')}',
        code: 'VALIDATION_FAILED',
      );
}

/// Thrown when a database operation fails.
class DatabaseBookingException extends BookingException {
  DatabaseBookingException(String message, {String? code})
    : super(message, code: code ?? 'DATABASE_ERROR');
}

/// Thrown when a booking conflict is detected (race condition).
class BookingConflictException extends BookingException {
  BookingConflictException()
    : super(
        'This booking conflicted with another. Please review and try again.',
        code: 'CONFLICT',
      );
}
