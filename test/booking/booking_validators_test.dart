import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/time_slot_model.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_validators.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/exceptions/booking_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

AppointmentSlotDTO _slot({
  required String id,
  required String name,
  int maxClients = 1,
}) {
  return AppointmentSlotDTO(
    id: id,
    serviceName: name,
    serviceType: null,
    duration: '30 minutes',
    price: 50.0,
    slotType: 'regular',
    maxClients: maxClients,
    daysOfWeek: const [1, 2, 3, 4, 5],
    selectPreferredWorker: false,
    workerIds: const [],
    bufferMinutes: 0,
  );
}

TimeSlotModel _timeSlot({
  required String slotId,
  required DateTime start,
  Duration duration = const Duration(minutes: 30),
  Duration buffer = Duration.zero,
}) {
  final end = start.add(duration);
  return TimeSlotModel(
    startTime: start,
    endTime: end,
    actualEndTime: end.add(buffer),
    slotId: slotId,
    serviceName: 'Test',
    priceMinor: 5000,
    availableWorkers: const [],
    remainingSpots: null,
    requiresWorkerSelection: false,
    bufferMinutes: buffer.inMinutes,
  );
}

void main() {
  group('BookingValidators.validateSelections', () {
    test('throws when no services selected', () {
      expect(
        () => BookingValidators.validateSelections(
          services: const [],
          timeSlots: {},
          quantities: {},
          isCombinedView: false,
        ),
        throwsA(
          isA<BookingValidationException>().having(
            (e) => e.validationErrors['services'],
            'services error',
            isNotNull,
          ),
        ),
      );
    });

    test('combined view requires at least one slot', () {
      final services = [_slot(id: 'a', name: 'Cut')];
      expect(
        () => BookingValidators.validateSelections(
          services: services,
          timeSlots: const {},
          quantities: const {'a': 1},
          isCombinedView: true,
        ),
        throwsA(
          isA<BookingValidationException>().having(
            (e) => e.validationErrors['timeSlot'],
            'timeSlot error',
            isNotNull,
          ),
        ),
      );
    });

    test('per-service view requires a slot for every selected service', () {
      final services = [
        _slot(id: 'a', name: 'Cut'),
        _slot(id: 'b', name: 'Color'),
      ];
      // Only service "a" has a time slot.
      expect(
        () => BookingValidators.validateSelections(
          services: services,
          timeSlots: {
            'a': _timeSlot(slotId: 'a', start: DateTime.utc(2026, 5, 17, 10)),
          },
          quantities: const {'a': 1, 'b': 1},
          isCombinedView: false,
        ),
        throwsA(
          isA<BookingValidationException>().having(
            (e) => e.validationErrors['b'],
            'missing slot error for b',
            contains('Color'),
          ),
        ),
      );
    });

    test('quantity < 1 fails fast', () {
      final services = [_slot(id: 'a', name: 'Cut')];
      expect(
        () => BookingValidators.validateSelections(
          services: services,
          timeSlots: {
            'a': _timeSlot(slotId: 'a', start: DateTime.utc(2026, 5, 17, 10)),
          },
          quantities: const {'a': 0},
          isCombinedView: false,
        ),
        throwsA(isA<BookingValidationException>()),
      );
    });

    test('quantity > maxClients fails with capacity message', () {
      final services = [_slot(id: 'a', name: 'Cut', maxClients: 3)];
      expect(
        () => BookingValidators.validateSelections(
          services: services,
          timeSlots: {
            'a': _timeSlot(slotId: 'a', start: DateTime.utc(2026, 5, 17, 10)),
          },
          quantities: const {'a': 4},
          isCombinedView: false,
        ),
        throwsA(
          isA<BookingValidationException>().having(
            (e) => e.validationErrors['a'],
            'capacity error',
            contains('3'),
          ),
        ),
      );
    });

    test('valid draft passes silently', () {
      final services = [_slot(id: 'a', name: 'Cut', maxClients: 5)];
      expect(
        () => BookingValidators.validateSelections(
          services: services,
          timeSlots: {
            'a': _timeSlot(slotId: 'a', start: DateTime.utc(2026, 5, 17, 10)),
          },
          quantities: const {'a': 3},
          isCombinedView: false,
        ),
        returnsNormally,
      );
    });

    test('missing quantity defaults to 1 (passes for maxClients=1)', () {
      final services = [_slot(id: 'a', name: 'Cut')];
      expect(
        () => BookingValidators.validateSelections(
          services: services,
          timeSlots: {
            'a': _timeSlot(slotId: 'a', start: DateTime.utc(2026, 5, 17, 10)),
          },
          quantities: const {}, // No entry for 'a' — default 1.
          isCombinedView: false,
        ),
        returnsNormally,
      );
    });
  });

  group('BookingValidators.validateNoDuplicateWorkers', () {
    test('passes when each service uses distinct workers', () {
      expect(
        () => BookingValidators.validateNoDuplicateWorkers({
          'svc-a': [
            {'id': 'w1', 'name': 'Ada'},
            {'id': 'w2', 'name': 'Beni'},
          ],
        }),
        returnsNormally,
      );
    });

    test('passes when worker_id is null (no worker required)', () {
      expect(
        () => BookingValidators.validateNoDuplicateWorkers({
          'svc-a': [
            {'id': null, 'name': null},
            {'id': null, 'name': null},
          ],
        }),
        returnsNormally,
      );
    });

    test('passes when same worker is used across DIFFERENT services', () {
      // Distinct-worker rule is per-service (within a single group seat
      // assignment), not per-booking. The DB partial unique index is on
      // (slot_id, worker_id, start_time) — same worker on two different
      // slots at non-overlapping times is fine.
      expect(
        () => BookingValidators.validateNoDuplicateWorkers({
          'svc-a': [{'id': 'w1', 'name': 'Ada'}],
          'svc-b': [{'id': 'w1', 'name': 'Ada'}],
        }),
        returnsNormally,
      );
    });

    test('throws when the same worker is assigned to two seats of one service', () {
      expect(
        () => BookingValidators.validateNoDuplicateWorkers({
          'svc-a': [
            {'id': 'w1', 'name': 'Ada'},
            {'id': 'w1', 'name': 'Ada'},
          ],
        }),
        throwsA(
          isA<BookingValidationException>().having(
            (e) => e.validationErrors['svc-a'],
            'duplicate worker error',
            contains('cannot be assigned'),
          ),
        ),
      );
    });

    test('ignores nulls when scanning for duplicates', () {
      expect(
        () => BookingValidators.validateNoDuplicateWorkers({
          'svc-a': [
            {'id': 'w1', 'name': 'Ada'},
            {'id': null, 'name': null},
            {'id': 'w2', 'name': 'Beni'},
          ],
        }),
        returnsNormally,
      );
    });
  });

  group('BookingValidators.userFacingMessage', () {
    test('SlotUnavailableException renders without the slot id', () {
      final msg = BookingValidators.userFacingMessage(SlotUnavailableException());
      expect(msg.toLowerCase(), contains('time slot'));
      expect(msg, isNot(contains('Exception')));
    });

    test('WorkerUnavailableException renders without raw IDs', () {
      final msg = BookingValidators.userFacingMessage(
        WorkerUnavailableException(
          workerId: 'deadbeef-0000-0000-0000-000000000000',
          requestedTime: DateTime.utc(2026, 5, 17, 10),
        ),
      );
      expect(msg.toLowerCase(), contains('worker'));
      expect(msg, isNot(contains('deadbeef')));
    });

    test('SlotFullException maps to a capacity message', () {
      final msg = BookingValidators.userFacingMessage(
        SlotFullException(
          slotId: 's',
          slotTime: DateTime.utc(2026, 5, 17, 10),
          maxCapacity: 4,
        ),
      );
      expect(msg.toLowerCase(), contains('capacity'));
    });

    test('OutsideBusinessHoursException maps to a hours message', () {
      final msg = BookingValidators.userFacingMessage(
        OutsideBusinessHoursException(
          requestedTime: DateTime.utc(2026, 5, 17, 22),
          shopHours: '09:00-18:00',
        ),
      );
      expect(msg.toLowerCase(), contains('business hours'));
    });

    test('BookingConflictException maps to a conflict message', () {
      final msg = BookingValidators.userFacingMessage(BookingConflictException());
      expect(msg.toLowerCase(), contains('conflict'));
    });

    test('BookingValidationException returns the first field error', () {
      final msg = BookingValidators.userFacingMessage(
        BookingValidationException({'address': 'Address required'}),
      );
      expect(msg, 'Address required');
    });

    test('Unknown BookingException falls back to a generic message', () {
      final msg = BookingValidators.userFacingMessage(
        DatabaseBookingException('SQLSTATE 08006'),
      );
      expect(msg.toLowerCase(), contains('failed'));
      expect(msg, isNot(contains('08006')));
    });
  });

  group('BookingValidators slot reducers', () {
    test('sortedByStart orders by ascending start_time', () {
      final t1 = DateTime.utc(2026, 5, 17, 11);
      final t2 = DateTime.utc(2026, 5, 17, 10);
      final t3 = DateTime.utc(2026, 5, 17, 12);
      final out = BookingValidators.sortedByStart([
        _timeSlot(slotId: 'a', start: t1),
        _timeSlot(slotId: 'b', start: t2),
        _timeSlot(slotId: 'c', start: t3),
      ]);
      expect(out.map((s) => s.startTime).toList(), [t2, t1, t3]);
    });

    test('latestEnd picks the latest endTime across all slots', () {
      final earliestSlot = _timeSlot(
        slotId: 'a',
        start: DateTime.utc(2026, 5, 17, 10),
        duration: const Duration(minutes: 30),
      );
      final laterSlot = _timeSlot(
        slotId: 'b',
        start: DateTime.utc(2026, 5, 17, 11),
        duration: const Duration(minutes: 90),
      );
      expect(
        BookingValidators.latestEnd([earliestSlot, laterSlot]),
        DateTime.utc(2026, 5, 17, 12, 30),
      );
    });

    test('latestActualEnd respects the buffer beyond endTime', () {
      final noBuffer = _timeSlot(
        slotId: 'a',
        start: DateTime.utc(2026, 5, 17, 10),
        duration: const Duration(minutes: 30),
      );
      final withBuffer = _timeSlot(
        slotId: 'b',
        start: DateTime.utc(2026, 5, 17, 10),
        duration: const Duration(minutes: 30),
        buffer: const Duration(minutes: 15),
      );
      // endTime equal (10:30), but actualEndTime differs by buffer (10:45).
      expect(
        BookingValidators.latestActualEnd([noBuffer, withBuffer]),
        DateTime.utc(2026, 5, 17, 10, 45),
      );
    });

    test('latestEnd vs latestActualEnd on the same set', () {
      // The fix that motivated extracting these helpers: anchoring a
      // multi-service booking by `slots.values.first` was wrong. With
      // map iteration order varying, the first slot might not have the
      // latest end. Make sure we pick the correct max.
      final later = _timeSlot(
        slotId: 'a',
        start: DateTime.utc(2026, 5, 17, 14),
        duration: const Duration(minutes: 60),
      );
      final earlier = _timeSlot(
        slotId: 'b',
        start: DateTime.utc(2026, 5, 17, 10),
        duration: const Duration(minutes: 30),
      );
      // Iteration order: [earlier, later] — but latestEnd must return
      // later.endTime regardless.
      expect(
        BookingValidators.latestEnd([earlier, later]),
        DateTime.utc(2026, 5, 17, 15),
      );
      // And reversed order produces the same answer.
      expect(
        BookingValidators.latestEnd([later, earlier]),
        DateTime.utc(2026, 5, 17, 15),
      );
    });
  });
}
