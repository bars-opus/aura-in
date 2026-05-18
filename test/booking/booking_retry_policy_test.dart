import 'dart:async';
import 'dart:io' show SocketException;

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_logger.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_retry_policy.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/exceptions/booking_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

void main() {
  // Silence the debug logs the retry policy emits on each backoff so
  // test output stays readable.
  setUpAll(() {
    BookingLogger.setSink((_, __, {error, stack}) {});
  });
  tearDownAll(BookingLogger.clearSink);

  /// Microsecond base so the suite finishes well under a frame.
  const fast = Duration(microseconds: 1);

  group('BookingRetryPolicy.run — success paths', () {
    test('returns the result on the first attempt', () async {
      var calls = 0;
      final result = await BookingRetryPolicy.run(() async {
        calls++;
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(calls, 1);
      expect(result, 'ok');
    });

    test('retries SocketException once then returns', () async {
      var calls = 0;
      final result = await BookingRetryPolicy.run(() async {
        calls++;
        if (calls < 2) throw const SocketException('flaky');
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(calls, 2);
      expect(result, 'ok');
    });

    test('retries TimeoutException then returns', () async {
      var calls = 0;
      final result = await BookingRetryPolicy.run(() async {
        calls++;
        if (calls < 2) throw TimeoutException('slow');
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(calls, 2);
      expect(result, 'ok');
    });

    test('retries Postgrest 503 then returns', () async {
      var calls = 0;
      final result = await BookingRetryPolicy.run(() async {
        calls++;
        if (calls < 2) {
          throw PostgrestException(
            message: 'service unavailable',
            code: '503',
          );
        }
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(calls, 2);
      expect(result, 'ok');
    });

    test('retries serialization-failure (40001) then returns', () async {
      var calls = 0;
      final result = await BookingRetryPolicy.run(() async {
        calls++;
        if (calls < 2) {
          throw PostgrestException(
            message: 'could not serialize access',
            code: '40001',
          );
        }
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(calls, 2);
      expect(result, 'ok');
    });
  });

  group('BookingRetryPolicy.run — no-retry paths', () {
    test('BookingException fails on first attempt', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(() async {
          calls++;
          throw SlotUnavailableException();
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<SlotUnavailableException>()),
      );
      expect(calls, 1);
    });

    test('rate-limit signal (53400) does not retry', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(() async {
          calls++;
          throw PostgrestException(
            message: 'rate_limited: too many create_booking',
            code: '53400',
          );
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('auth-failure (42501) does not retry', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(() async {
          calls++;
          throw PostgrestException(
            message: 'unauthorized',
            code: '42501',
          );
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('unique violation (23505) does not retry', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(() async {
          calls++;
          throw PostgrestException(
            message: 'worker_id: deadbeef unavailable',
            code: '23505',
          );
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('invalid_parameter (22023) does not retry', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(() async {
          calls++;
          throw PostgrestException(
            message: 'address too long',
            code: '22023',
          );
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('raise_exception (P0001) does not retry', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(() async {
          calls++;
          throw PostgrestException(
            message: 'slot_full',
            code: 'P0001',
          );
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('Postgrest 4xx does not retry', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(() async {
          calls++;
          throw PostgrestException(
            message: 'bad request',
            code: '400',
          );
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('Unknown error type (StateError) does not retry', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(() async {
          calls++;
          throw StateError('logic bug');
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<StateError>()),
      );
      expect(calls, 1);
    });
  });

  group('BookingRetryPolicy.run — exhaustion', () {
    test('gives up after maxAttempts and rethrows the last error', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(
          () async {
            calls++;
            throw const SocketException('always flaky');
          },
          maxAttempts: 3,
          baseDelay: fast,
          maxDelay: fast,
        ),
        throwsA(isA<SocketException>()),
      );
      expect(calls, 3);
    });

    test('maxAttempts=1 means no retry', () async {
      var calls = 0;
      await expectLater(
        BookingRetryPolicy.run(
          () async {
            calls++;
            throw const SocketException('flaky');
          },
          maxAttempts: 1,
          baseDelay: fast,
          maxDelay: fast,
        ),
        throwsA(isA<SocketException>()),
      );
      expect(calls, 1);
    });
  });

  group('BookingRetryPolicy.run — per-attempt timeout', () {
    test('long-hanging op surfaces TimeoutException and retries', () async {
      var calls = 0;
      final result = await BookingRetryPolicy.run(
        () async {
          calls++;
          if (calls < 2) {
            await Future<void>.delayed(const Duration(seconds: 5));
          }
          return 'ok';
        },
        baseDelay: fast,
        maxDelay: fast,
        perAttemptTimeout: const Duration(milliseconds: 30),
      );
      expect(calls, 2);
      expect(result, 'ok');
    });
  });

  group('BookingRetryPolicy.run — idempotency-safe retries', () {
    test('retried op observes the same arguments each attempt', () async {
      // Simulates the createBooking RPC pattern: the idempotency key is
      // captured in the closure, so every attempt uses the same key —
      // the server-side replay logic will return the same booking.
      const idempotencyKey = 'fixed-key-for-replay';
      final keysSeen = <String>[];
      var calls = 0;
      await BookingRetryPolicy.run(() async {
        calls++;
        keysSeen.add(idempotencyKey);
        if (calls < 3) throw const SocketException('blip');
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(keysSeen, ['fixed-key-for-replay', 'fixed-key-for-replay', 'fixed-key-for-replay']);
    });
  });
}
