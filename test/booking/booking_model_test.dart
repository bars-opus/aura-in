import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_model.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_service_model.dart';

void main() {
  group('BookingModel', () {
    BookingModel makeBooking({
      BookingStatus status = BookingStatus.pending,
      PaymentStatus paymentStatus = PaymentStatus.unpaid,
      DateTime? startTime,
      DateTime? endTime,
      double total = 100.0,
      double deposit = 30.0,
    }) {
      final start = startTime ?? DateTime.utc(2026, 5, 17, 10);
      final end = endTime ?? DateTime.utc(2026, 5, 17, 11);
      return BookingModel(
        id: 'b1',
        userId: 'u1',
        shopId: 's1',
        bookingDate: DateTime.utc(2026, 5, 17),
        startTime: start,
        endTime: end,
        actualEndTime: end,
        status: status,
        totalAmount: total,
        depositAmount: deposit,
        platformFee: 2.0,
        paymentStatus: paymentStatus,
        createdAt: DateTime.utc(2026, 5, 16),
        updatedAt: DateTime.utc(2026, 5, 16),
        shopAddress: '12 Marina, Lagos',
        latitude: 6.5244,
        longitude: 3.3792,
      );
    }

    test('toJson includes all server-mapped columns', () {
      final json = makeBooking().toJson();
      // Spot-check the keys that the create_booking_transaction RPC reads.
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('user_id'), isTrue);
      expect(json.containsKey('shop_id'), isTrue);
      expect(json.containsKey('booking_date'), isTrue);
      expect(json.containsKey('start_time'), isTrue);
      expect(json.containsKey('end_time'), isTrue);
      expect(json.containsKey('actual_end_time'), isTrue);
      expect(json.containsKey('status'), isTrue);
      expect(json.containsKey('total_amount'), isTrue);
      expect(json.containsKey('deposit_amount'), isTrue);
      expect(json.containsKey('platform_fee'), isTrue);
      expect(json.containsKey('payment_status'), isTrue);
      expect(json.containsKey('latitude'), isTrue);
      expect(json.containsKey('longitude'), isTrue);
    });

    test('fromJson tolerates missing optional fields', () {
      final booking = BookingModel.fromJson(<String, dynamic>{
        'id': 'b1',
        'user_id': 'u1',
        'shop_id': 's1',
        'booking_date': '2026-05-17T00:00:00.000Z',
        'start_time': '2026-05-17T10:00:00.000Z',
        'end_time': '2026-05-17T11:00:00.000Z',
        'actual_end_time': '2026-05-17T11:00:00.000Z',
        'status': 'pending',
        'total_amount': 100.0,
        'deposit_amount': 30.0,
        'payment_status': 'unpaid',
        'created_at': '2026-05-16T00:00:00.000Z',
        'updated_at': '2026-05-16T00:00:00.000Z',
        // No platform_fee, payment_intent_id, cancellation_reason, shop.
      });
      expect(booking.id, 'b1');
      expect(booking.status, BookingStatus.pending);
      expect(booking.platformFee, isNull);
      expect(booking.paymentIntentId, isNull);
      expect(booking.cancellationReason, isNull);
      expect(booking.shopAddress, isNull);
    });

    test('fromJson defaults to sensible values for null core fields', () {
      // Defensive: real production rows always have these, but the
      // calendar view (booking_simple) can null-pad joins.
      final booking = BookingModel.fromJson(<String, dynamic>{
        'id': null,
        'user_id': null,
        'shop_id': null,
        'status': null,
        'payment_status': null,
        'total_amount': null,
        'deposit_amount': null,
      });
      expect(booking.id, '');
      expect(booking.status, BookingStatus.pending);
      expect(booking.paymentStatus, PaymentStatus.unpaid);
      expect(booking.totalAmount, 0.0);
      expect(booking.depositAmount, 0.0);
    });

    test('isActive is true for pending + confirmed only', () {
      expect(makeBooking(status: BookingStatus.pending).isActive, isTrue);
      expect(makeBooking(status: BookingStatus.confirmed).isActive, isTrue);
      expect(makeBooking(status: BookingStatus.cancelled).isActive, isFalse);
      expect(makeBooking(status: BookingStatus.completed).isActive, isFalse);
      expect(makeBooking(status: BookingStatus.noShow).isActive, isFalse);
    });

    test('remainingBalance = total - deposit', () {
      final b = makeBooking(total: 150, deposit: 45);
      expect(b.remainingBalance, 105);
    });

    test('canCancel returns false for cancelled bookings', () {
      final b = makeBooking(status: BookingStatus.cancelled);
      expect(b.canCancel(), isFalse);
    });

    test('canCancel returns true outside the cancellation window', () {
      final future = DateTime.now().add(const Duration(days: 3));
      final b = BookingModel(
        id: 'x',
        userId: 'u',
        shopId: 's',
        bookingDate: future,
        startTime: future,
        endTime: future.add(const Duration(hours: 1)),
        actualEndTime: future.add(const Duration(hours: 1)),
        status: BookingStatus.confirmed,
        totalAmount: 0,
        depositAmount: 0,
        paymentStatus: PaymentStatus.unpaid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        shopAddress: null,
      );
      expect(b.canCancel(), isTrue);
    });

    test('canCancel returns false inside the cancellation window', () {
      final soon = DateTime.now().add(const Duration(hours: 2));
      final b = BookingModel(
        id: 'x',
        userId: 'u',
        shopId: 's',
        bookingDate: soon,
        startTime: soon,
        endTime: soon.add(const Duration(hours: 1)),
        actualEndTime: soon.add(const Duration(hours: 1)),
        status: BookingStatus.confirmed,
        totalAmount: 0,
        depositAmount: 0,
        paymentStatus: PaymentStatus.unpaid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        shopAddress: null,
      );
      expect(b.canCancel(), isFalse);
    });
  });

  group('BookingStatus.fromString', () {
    test('parses every known value', () {
      expect(BookingStatus.fromString('pending'), BookingStatus.pending);
      expect(BookingStatus.fromString('confirmed'), BookingStatus.confirmed);
      expect(BookingStatus.fromString('cancelled'), BookingStatus.cancelled);
      expect(BookingStatus.fromString('completed'), BookingStatus.completed);
      expect(BookingStatus.fromString('no_show'), BookingStatus.noShow);
    });

    test('falls back to pending for unknown strings', () {
      expect(BookingStatus.fromString('garbage'), BookingStatus.pending);
    });
  });

  group('PaymentStatus.fromString', () {
    test('parses every known value', () {
      expect(PaymentStatus.fromString('unpaid'), PaymentStatus.unpaid);
      expect(PaymentStatus.fromString('paid'), PaymentStatus.paid);
      expect(PaymentStatus.fromString('refunded'), PaymentStatus.refunded);
      expect(PaymentStatus.fromString('failed'), PaymentStatus.failed);
    });

    test('falls back to unpaid for unknown strings', () {
      expect(PaymentStatus.fromString('garbage'), PaymentStatus.unpaid);
    });
  });

  group('BookingServiceModel', () {
    test('toJson <-> fromJson round-trip preserves core fields', () {
      final original = BookingServiceModel(
        id: 'bs1',
        bookingId: 'b1',
        slotId: 'slot-1',
        workerId: 'worker-9',
        startTime: DateTime.utc(2026, 5, 17, 10),
        priceAtBooking: 50.0,
        durationMinutes: 60,
        createdAt: DateTime.utc(2026, 5, 16),
        serviceName: 'Haircut',
        workerName: 'Ada',
        specialRequirements: 'short on the sides',
      );

      // Round-trip via JSON map. Note that BookingServiceModel.toJson
      // does NOT emit created_at, so we inject one mirroring what the
      // server would return.
      final json = original.toJson()
        ..['created_at'] = original.createdAt.toIso8601String();

      final round = BookingServiceModel.fromJson(json);
      expect(round.id, 'bs1');
      expect(round.bookingId, 'b1');
      expect(round.slotId, 'slot-1');
      expect(round.workerId, 'worker-9');
      expect(round.priceAtBooking, 50.0);
      expect(round.durationMinutes, 60);
      expect(round.serviceName, 'Haircut');
      expect(round.workerName, 'Ada');
      expect(round.specialRequirements, 'short on the sides');
      expect(round.startTime, original.startTime);
    });

    test('toJson omits empty special_requirements', () {
      final m = BookingServiceModel(
        id: 'x',
        bookingId: 'b',
        slotId: 's',
        startTime: DateTime.utc(2026, 5, 17, 10),
        priceAtBooking: 0,
        durationMinutes: 30,
        createdAt: DateTime.utc(2026, 5, 16),
        specialRequirements: '',
      );
      final json = m.toJson();
      expect(json.containsKey('special_requirements'), isFalse);
    });

    test('toJson includes non-empty special_requirements', () {
      final m = BookingServiceModel(
        id: 'x',
        bookingId: 'b',
        slotId: 's',
        startTime: DateTime.utc(2026, 5, 17, 10),
        priceAtBooking: 0,
        durationMinutes: 30,
        createdAt: DateTime.utc(2026, 5, 16),
        specialRequirements: 'note',
      );
      expect(m.toJson()['special_requirements'], 'note');
    });
  });
}
