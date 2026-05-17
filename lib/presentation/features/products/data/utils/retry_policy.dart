import 'dart:async';
import 'dart:io' show SocketException;
import 'dart:math' show Random, min;

import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

/// Wraps a Future operation in retry-with-exponential-backoff. Retries only
/// transient failures (network blips, 5xx, timeouts). Deterministic errors
/// — `MarketplaceException` family, 4xx Postgrest, validation failures —
/// fail immediately because re-trying them will get the same answer.
///
/// Defaults are tuned for mobile networks:
///   - maxAttempts: 3 (initial + 2 retries)
///   - baseDelay: 400ms
///   - maxDelay: 4s (cap so the 3rd retry doesn't feel laggy)
///   - jitter: full random in [0, currentBackoff] added to defeat
///     thundering-herd on shared backends
///   - timeout per attempt: 15s
class RetryPolicy {
  static final Random _rng = Random();

  /// Run [operation] with retry. The closure receives the attempt number
  /// (1-indexed) in case the caller wants to log it.
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
          // Either deterministic, or last attempt — give up.
          if (attempt > 1) {
            MarketplaceLogger.warn(
              '$operationName failed after $attempt attempt(s)',
              error: error,
              stack: stack,
            );
          }
          rethrow;
        }

        // Transient and we have retries left: backoff and try again.
        final backoff = _backoffFor(attempt, baseDelay, maxDelay);
        MarketplaceLogger.debug(
          '$operationName attempt $attempt failed (transient); '
          'retrying in ${backoff.inMilliseconds}ms',
          error: error,
        );
        await Future<void>.delayed(backoff);
      }
    }

    // Unreachable — the loop either returns or rethrows. Defensive throw
    // so static analysis is happy and so a future refactor that bypasses
    // the rethrow still surfaces the error rather than hanging.
    Error.throwWithStackTrace(
      lastError ?? StateError('retry loop exited without result'),
      lastStack ?? StackTrace.current,
    );
  }

  /// Classifier — true if we should retry, false if we should fail fast.
  static bool _isTransient(Object error) {
    // Deterministic application errors: never retry.
    if (error is MarketplaceException) return false;

    // Network-layer errors: always retry.
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;

    // Postgrest errors: 5xx are transient, 4xx are not.
    if (error is PostgrestException) {
      final code = error.code;
      if (code != null && code.length == 3) {
        final first = code[0];
        if (first == '5') return true;
        if (first == '4') return false;
      }
      // Some Postgres SQLSTATEs surface here too. 53400 = rate_limited
      // (our own RPC) — DO NOT retry; let the UI surface the message.
      if (code == '53400') return false;
      // Connection lost / serialization failures are transient.
      if (code == '08000' || code == '08006' || code == '40001') return true;
      // Unknown Postgrest error: treat as transient — better to retry
      // a benign error than to swallow a real network issue.
      return true;
    }

    // Unknown error type: don't retry — could be a programming error
    // (NoSuchMethodError, etc.) that retry won't help.
    return false;
  }

  /// Exponential backoff: base * 2^(attempt-1), capped at maxDelay, with
  /// full jitter. Attempt 1 → ~[0, base]; attempt 2 → ~[0, 2*base]; etc.
  static Duration _backoffFor(int attempt, Duration base, Duration max) {
    final raw = base.inMilliseconds * (1 << (attempt - 1));
    final capped = min(raw, max.inMilliseconds);
    final withJitter = _rng.nextInt(capped + 1);
    return Duration(milliseconds: withJitter);
  }
}
