import 'dart:async';
import 'dart:math';

import 'package:nano_embryo/core/feedback/exceptions/feedback_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Default per-request deadline for feedback DB calls. Storage uploads use a
/// longer deadline (see [kFeedbackUploadTimeout]).
const Duration kFeedbackCallTimeout = Duration(seconds: 15);

/// Screenshots can legitimately take ~10s on slow networks; pad accordingly.
const Duration kFeedbackUploadTimeout = Duration(seconds: 30);

/// Retry knobs (checklist 3.9): max attempts ≤ 6, base ≥ 250ms, max ≤ 60s,
/// jitter ≥ 25%.
const int _kMaxAttempts = 3;
const Duration _kBaseDelay = Duration(milliseconds: 250);
const Duration _kMaxDelay = Duration(seconds: 4);

bool _isRetryablePostgrest(PostgrestException e) {
  // Permanent failures (4xx-equivalent) — never retry.
  const permanent = {
    'PGRST301', // JWT expired
    'PGRST302', // JWT missing
    '23505',    // unique violation (incl. idempotency-key dedupe → not an error)
    '23503',    // foreign key violation
    '23514',    // check constraint violation
    '42501',    // insufficient_privilege (RLS deny)
  };
  if (permanent.contains(e.code)) return false;
  return true;
}

/// Runs [op] with a per-attempt timeout and exponential backoff + jitter.
///
/// Retries only on transient errors (network, 5xx, timeout). Auth, validation,
/// RLS denials, and unique violations short-circuit immediately.
///
/// On terminal timeout, throws [FeedbackTimeoutException]; other terminal
/// errors are rethrown unchanged so the repo can translate them.
Future<T> runFeedbackCall<T>(
  Future<T> Function() op, {
  Duration timeout = kFeedbackCallTimeout,
  int maxAttempts = _kMaxAttempts,
  Random? random,
}) async {
  final rng = random ?? Random();
  var attempt = 0;
  while (true) {
    attempt++;
    try {
      return await op().timeout(timeout);
    } on TimeoutException catch (e) {
      if (attempt >= maxAttempts) {
        throw FeedbackTimeoutException('Request timed out: ${e.message ?? ''}');
      }
    } on PostgrestException catch (e) {
      if (!_isRetryablePostgrest(e) || attempt >= maxAttempts) {
        rethrow;
      }
    } on AuthException {
      rethrow; // never retry auth
    } catch (_) {
      if (attempt >= maxAttempts) rethrow;
    }
    final delayMs = _kBaseDelay.inMilliseconds * (1 << (attempt - 1));
    final cappedMs = delayMs.clamp(0, _kMaxDelay.inMilliseconds);
    final jitterMs = (cappedMs * 0.25 * rng.nextDouble()).toInt();
    await Future<void>.delayed(Duration(milliseconds: cappedMs + jitterMs));
  }
}
