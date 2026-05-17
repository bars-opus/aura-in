import 'dart:async';
import 'dart:io' show SocketException;

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/retry_policy.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

void main() {
  // Silence the debug logs RetryPolicy emits on each backoff so test
  // output stays readable. The sink stays unset for production code.
  setUpAll(() {
    MarketplaceLogger.setSink((_, __, {error, stack}) {});
  });
  tearDownAll(MarketplaceLogger.clearSink);

  /// Tight defaults so the test suite stays fast — micro-second base so the
  /// total time for 3 attempts is well under a frame.
  const fast = Duration(microseconds: 1);

  group('RetryPolicy.run — success paths', () {
    test('returns the result on the first attempt', () async {
      var calls = 0;
      final result = await RetryPolicy.run(() async {
        calls++;
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(calls, 1);
      expect(result, 'ok');
    });

    test('retries SocketException once then returns', () async {
      var calls = 0;
      final result = await RetryPolicy.run(() async {
        calls++;
        if (calls < 2) throw const SocketException('flaky');
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(calls, 2);
      expect(result, 'ok');
    });

    test('retries TimeoutException then returns', () async {
      var calls = 0;
      final result = await RetryPolicy.run(() async {
        calls++;
        if (calls < 2) throw TimeoutException('slow');
        return 'ok';
      }, baseDelay: fast, maxDelay: fast);

      expect(calls, 2);
      expect(result, 'ok');
    });

    test('retries Postgrest 503 then returns', () async {
      var calls = 0;
      final result = await RetryPolicy.run(() async {
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
  });

  group('RetryPolicy.run — no-retry paths', () {
    test('MarketplaceException fails on first attempt (no retry)', () async {
      var calls = 0;
      await expectLater(
        RetryPolicy.run(() async {
          calls++;
          throw OutOfStockException('p1');
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<OutOfStockException>()),
      );
      expect(calls, 1);
    });

    test('RateLimitException-ish (53400) does not retry', () async {
      var calls = 0;
      await expectLater(
        RetryPolicy.run(() async {
          calls++;
          throw PostgrestException(
            message: 'rate_limited',
            code: '53400',
          );
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('Postgrest 4xx does not retry', () async {
      var calls = 0;
      await expectLater(
        RetryPolicy.run(() async {
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
        RetryPolicy.run(() async {
          calls++;
          throw StateError('logic bug');
        }, baseDelay: fast, maxDelay: fast),
        throwsA(isA<StateError>()),
      );
      expect(calls, 1);
    });
  });

  group('RetryPolicy.run — exhaustion', () {
    test('gives up after maxAttempts and rethrows the last error', () async {
      var calls = 0;
      await expectLater(
        RetryPolicy.run(
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
        RetryPolicy.run(
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

  group('RetryPolicy.run — per-attempt timeout', () {
    test('long-hanging op surfaces TimeoutException and retries', () async {
      var calls = 0;
      final result = await RetryPolicy.run(
        () async {
          calls++;
          if (calls < 2) {
            // First call hangs past the timeout.
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
}
