import 'dart:async';
import 'dart:math';

import 'package:nano_embryo/core/config/survey/exceptions/survey_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Default per-request deadline. Survey writes are tiny; if a call hasn't
/// returned in 15s the network is likely the problem and surfacing the error
/// is better than letting the user stare at a spinner.
const Duration kSurveyCallTimeout = Duration(seconds: 15);

/// Retry knobs picked to satisfy checklist 3.9:
///   max attempts ≤ 6, base ≥ 250ms, max ≤ 60s, jitter ≥ 25%.
const int _kMaxAttempts = 3;
const Duration _kBaseDelay = Duration(milliseconds: 250);
const Duration _kMaxDelay = Duration(seconds: 4);

bool _isRetryablePostgrest(PostgrestException e) {
  // 4xx-equivalent Postgrest errors that mean "your request is wrong" — never
  // retry. RLS denials, constraint violations, unique-violations all fall here.
  // Codes are PostgREST/PostgreSQL state codes.
  const permanent = {
    'PGRST301', // JWT expired
    'PGRST302', // JWT missing
    '23505',    // unique violation
    '23503',    // foreign key violation
    '23514',    // check constraint violation
    '42501',    // insufficient_privilege (RLS deny)
  };
  if (permanent.contains(e.code)) return false;
  // No status code → likely network / 5xx → retry.
  return true;
}

/// Runs [op] with a per-attempt timeout and exponential backoff + jitter.
///
/// Retries only on transient errors (network, 5xx, timeout). Auth, validation,
/// and RLS denials short-circuit immediately.
///
/// Translates the terminal failure into a [SurveyException] subclass.
Future<T> runSurveyCall<T>(
  Future<T> Function() op, {
  Duration timeout = kSurveyCallTimeout,
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
        throw SurveyTimeoutException('Request timed out: ${e.message ?? ''}');
      }
    } on PostgrestException catch (e) {
      if (!_isRetryablePostgrest(e) || attempt >= maxAttempts) {
        // Let the repo translate; do not retry permanent errors.
        rethrow;
      }
    } on AuthException {
      // Never retry an auth failure — surface to the user immediately.
      rethrow;
    } catch (_) {
      if (attempt >= maxAttempts) rethrow;
    }
    final delayMs = _kBaseDelay.inMilliseconds *
        (1 << (attempt - 1)); // 250, 500, 1000
    final cappedMs = delayMs.clamp(0, _kMaxDelay.inMilliseconds);
    // 25% jitter, additive.
    final jitterMs = (cappedMs * 0.25 * rng.nextDouble()).toInt();
    await Future<void>.delayed(Duration(milliseconds: cappedMs + jitterMs));
  }
}
