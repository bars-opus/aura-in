import 'package:nano_embryo/presentation/features/shops/booking/data/models/time_slot_model.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/exceptions/booking_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

/// Pure validation + reduction helpers extracted from
/// `BookingCreationController` so they can be unit-tested without
/// spinning up a Riverpod container.
///
/// All functions are pure (no IO, no state). Errors are reported by
/// throwing `BookingValidationException`; callers convert to user-safe
/// messages via [userFacingMessage].
class BookingValidators {
  BookingValidators._();

  /// Throws [BookingValidationException] if the draft can't be submitted.
  ///
  /// In combined view, at least one slot must be selected. In per-service
  /// view, every selected service must have its own slot. Quantities must
  /// be in [1, service.maxClients].
  static void validateSelections({
    required List<AppointmentSlotDTO> services,
    required Map<String, TimeSlotModel> timeSlots,
    required Map<String, int> quantities,
    required bool isCombinedView,
  }) {
    if (services.isEmpty) {
      throw BookingValidationException({'services': 'No services selected'});
    }
    if (isCombinedView) {
      if (timeSlots.isEmpty) {
        throw BookingValidationException({'timeSlot': 'No time slot selected'});
      }
    } else {
      for (final service in services) {
        if (!timeSlots.containsKey(service.id)) {
          throw BookingValidationException({
            service.id: 'No time slot selected for ${service.serviceName}',
          });
        }
      }
    }
    for (final service in services) {
      final qty = quantities[service.id] ?? 1;
      if (qty < 1) {
        throw BookingValidationException({
          service.id: 'Invalid quantity for ${service.serviceName}',
        });
      }
      if (qty > service.maxClients) {
        throw BookingValidationException({
          service.id:
              'Quantity exceeds maximum allowed (${service.maxClients})',
        });
      }
    }
  }

  /// Throws if the same worker is assigned to two seats in the same
  /// service (the server enforces this via a partial unique index too;
  /// failing client-side avoids burning the rate-limit budget).
  static void validateNoDuplicateWorkers(
    Map<String, List<Map<String, String?>>> workers,
  ) {
    for (final entry in workers.entries) {
      final seen = <String>{};
      for (final w in entry.value) {
        final id = w['id'];
        if (id == null) continue;
        if (!seen.add(id)) {
          throw BookingValidationException({
            entry.key: 'The same worker cannot be assigned to multiple seats',
          });
        }
      }
    }
  }

  /// Single-line user-safe message for a domain exception. Never leaks
  /// raw exception text — that's a deliberate UX contract.
  static String userFacingMessage(BookingException e) {
    if (e is SlotUnavailableException) {
      return 'The selected time slot is no longer available. Please choose another.';
    }
    if (e is WorkerUnavailableException) {
      return 'The selected worker is no longer available at this time.';
    }
    if (e is SlotFullException) {
      return 'This time slot has reached maximum capacity.';
    }
    if (e is OutsideBusinessHoursException) {
      return 'This time is outside the shop\'s business hours.';
    }
    if (e is BookingConflictException) {
      return 'This booking conflicted with another. Please review and try again.';
    }
    if (e is BookingValidationException) {
      return e.validationErrors.values.first;
    }
    return 'Booking failed. Please try again.';
  }

  /// Sort a slot collection by start_time so callers can take the first
  /// and last reliably regardless of map iteration order.
  static List<TimeSlotModel> sortedByStart(Iterable<TimeSlotModel> slots) {
    return [...slots]..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Latest end_time across a non-empty slot collection.
  static DateTime latestEnd(List<TimeSlotModel> slots) {
    return slots
        .reduce((a, b) => a.endTime.isAfter(b.endTime) ? a : b)
        .endTime;
  }

  /// Latest actualEndTime (= end + buffer) across a non-empty collection.
  static DateTime latestActualEnd(List<TimeSlotModel> slots) {
    return slots
        .reduce(
          (a, b) => a.actualEndTime.isAfter(b.actualEndTime) ? a : b,
        )
        .actualEndTime;
  }
}
