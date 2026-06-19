import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/feedback/exceptions/feedback_exceptions.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_retry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('runFeedbackCall', () {
    test('returns on first success — no retry', () async {
      var calls = 0;
      final r = await runFeedbackCall(() async {
        calls++;
        return 1;
      });
      expect(r, 1);
      expect(calls, 1);
    });

    test('retries on transient failure then succeeds', () async {
      var calls = 0;
      final r = await runFeedbackCall(
        () async {
          calls++;
          if (calls < 3) throw StateError('transient');
          return 'ok';
        },
        random: Random(0),
      );
      expect(r, 'ok');
      expect(calls, 3);
    });

    test('does NOT retry on AuthException', () async {
      var calls = 0;
      await expectLater(
        runFeedbackCall<void>(() async {
          calls++;
          throw AuthException('jwt expired');
        }),
        throwsA(isA<AuthException>()),
      );
      expect(calls, 1);
    });

    test('does NOT retry on permanent Postgrest (RLS)', () async {
      var calls = 0;
      await expectLater(
        runFeedbackCall<void>(() async {
          calls++;
          throw PostgrestException(message: 'rls', code: '42501');
        }),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('does NOT retry on unique-violation (idempotency dedupe)', () async {
      var calls = 0;
      await expectLater(
        runFeedbackCall<void>(() async {
          calls++;
          throw PostgrestException(message: 'dup', code: '23505');
        }),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('terminal timeout → FeedbackTimeoutException', () async {
      await expectLater(
        runFeedbackCall<void>(
          () => Future.delayed(const Duration(milliseconds: 200)),
          timeout: const Duration(milliseconds: 10),
          maxAttempts: 2,
          random: Random(0),
        ),
        throwsA(isA<FeedbackTimeoutException>()),
      );
    });
  });
}
