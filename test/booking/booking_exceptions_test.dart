import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/exceptions/booking_exceptions.dart';

void main() {
  group('BookingException hierarchy', () {
    test('every domain exception is a BookingException', () {
      expect(SlotUnavailableException(), isA<BookingException>());
      expect(
        WorkerUnavailableException(
          workerId: 'w1',
          requestedTime: DateTime(2026, 5, 17, 10),
        ),
        isA<BookingException>(),
      );
      expect(
        SlotFullException(
          slotId: 's1',
          slotTime: DateTime(2026, 5, 17, 10),
          maxCapacity: 4,
        ),
        isA<BookingException>(),
      );
      expect(
        OutsideBusinessHoursException(
          requestedTime: DateTime(2026, 5, 17, 22),
          shopHours: '09:00-18:00',
        ),
        isA<BookingException>(),
      );
      expect(
        BookingValidationException({'k': 'v'}),
        isA<BookingException>(),
      );
      expect(
        DatabaseBookingException('boom'),
        isA<BookingException>(),
      );
      expect(BookingConflictException(), isA<BookingException>());
    });

    test('error codes match their semantic name', () {
      expect(SlotUnavailableException().code, 'SLOT_UNAVAILABLE');
      expect(SlotFullException(
        slotId: 's', slotTime: DateTime.now(), maxCapacity: 4,
      ).code, 'SLOT_FULL');
      expect(WorkerUnavailableException(
        workerId: 'w', requestedTime: DateTime.now(),
      ).code, 'WORKER_UNAVAILABLE');
      expect(OutsideBusinessHoursException(
        requestedTime: DateTime.now(), shopHours: '9-5',
      ).code, 'OUTSIDE_HOURS');
      expect(BookingValidationException({}).code, 'VALIDATION_FAILED');
      expect(DatabaseBookingException('x').code, 'DATABASE_ERROR');
      expect(BookingConflictException().code, 'CONFLICT');
    });

    test('DatabaseBookingException honors explicit code override', () {
      expect(DatabaseBookingException('x', code: 'CUSTOM').code, 'CUSTOM');
    });
  });

  group('BookingValidationException', () {
    test('joins multiple field errors into the message', () {
      final ex = BookingValidationException({
        'services': 'No services selected',
        'address': 'Address required',
      });
      expect(ex.message, contains('No services selected'));
      expect(ex.message, contains('Address required'));
    });

    test('preserves the structured errors map for callers', () {
      final ex = BookingValidationException({'a': 'b'});
      expect(ex.validationErrors, {'a': 'b'});
    });
  });

  group('SlotFullException', () {
    test('exposes structured fields for UI rendering', () {
      final t = DateTime(2026, 5, 17, 10, 30);
      final ex = SlotFullException(slotId: 'slot-1', slotTime: t, maxCapacity: 4);
      expect(ex.slotId, 'slot-1');
      expect(ex.slotTime, t);
      expect(ex.maxCapacity, 4);
      expect(ex.message, contains('4'));
    });
  });

  group('WorkerUnavailableException', () {
    test('exposes structured fields for UI rendering', () {
      final t = DateTime(2026, 5, 17, 14);
      final ex = WorkerUnavailableException(workerId: 'worker-9', requestedTime: t);
      expect(ex.workerId, 'worker-9');
      expect(ex.requestedTime, t);
    });
  });
}
