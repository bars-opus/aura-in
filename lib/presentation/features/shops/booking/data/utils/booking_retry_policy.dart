import 'dart:async';
import 'dart:io' show SocketException;
import 'dart:math' show Random, min;

import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_logger.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/exceptions/booking_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

/// Wraps a Future operation in retry-with-exponential-backoff. Retries only
/// transient failures (network blips, 5xx, timeouts). Deterministic errors
/// — `BookingException` family, 4xx Postgrest, validation failures, rate
/// limits — fail immediately because retrying them will get the same answer.
///
/// Defaults are tuned for mobile networks:
///   - maxAttempts: 3 (initial + 2 retries)
///   - baseDelay: 400ms
///   - maxDelay: 4s
///   - jitter: full random in [0, currentBackoff] to defeat thundering-herd
///   - timeout per attempt: 15s
///
/// Mirrors `RetryPolicy` in the products feature; kept feature-local so
/// classifier exceptions can be tuned per-domain.
class BookingRetryPolicy {
  static final Random _rng = Random();

  static Future<T> run<T>(
    Future<T> Function() operation, {
    String operationName = 'operation',
    int maxAttempts = 3,
    Duration baseDelay = const Duration(milliseconds: 400),
    Duration maxDelay = const Duration(seconds: 4),
    Duration perAttemptTimeout = const Duration(seconds: 15),
  }) async {
    assert(maxAttempts >= 1);
    Object? lastError;
    StackTrace? lastStack;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation().timeout(perAttemptTimeout);
      } catch (error, stack) {
        lastError = error;
        lastStack = stack;

        if (!_isTransient(error) || attempt == maxAttempts) {
          if (attempt > 1) {
            BookingLogger.warn(
              '$operationName failed after $attempt attempt(s)',
              error: error,
              stack: stack,
            );
          }
          rethrow;
        }

        final backoff = _backoffFor(attempt, baseDelay, maxDelay);
        BookingLogger.debug(
          '$operationName attempt $attempt failed (transient); '
          'retrying in ${backoff.inMilliseconds}ms',
          error: error,
        );
        await Future<void>.delayed(backoff);
      }
    }

    Error.throwWithStackTrace(
      lastError ?? StateError('retry loop exited without result'),
      lastStack ?? StackTrace.current,
    );
  }

  static bool _isTransient(Object error) {
    // Deterministic application errors: never retry. The user (or the
    // server's idempotency / state machine) will get the same answer.
    if (error is BookingException) return false;

    // Network-layer errors: always retry.
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;

    if (error is PostgrestException) {
      final code = error.code;
      if (code != null && code.length == 3) {
        final first = code[0];
        if (first == '5') return true;
        if (first == '4') return false;
      }
      // Our own RPC rate-limit signal (SQLSTATE 53400) — DO NOT retry;
      // let the UI surface the message so the user knows to slow down.
      if (code == '53400') return false;
      // Auth, validation, unique-violation, etc. — deterministic.
      if (code == '42501' || code == '22023' || code == '23505' ||
          code == 'P0001' || code == 'P0002') {
        return false;
      }
      // Connection lost / serialization failures — transient.
      if (code == '08000' || code == '08006' || code == '40001') return true;
      // Unknown Postgrest error: treat as transient — better to retry
      // a benign error than to swallow a real network issue.
      return true;
    }

    return false;
  }

  static Duration _backoffFor(int attempt, Duration base, Duration max) {
    final raw = base.inMilliseconds * (1 << (attempt - 1));
    final capped = min(raw, max.inMilliseconds);
    final withJitter = _rng.nextInt(capped + 1);
    return Duration(milliseconds: withJitter);
  }
}
