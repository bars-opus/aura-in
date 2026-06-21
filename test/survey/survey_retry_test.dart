import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/config/survey/exceptions/survey_exceptions.dart';
import 'package:nano_embryo/core/config/survey/utils/survey_retry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('runSurveyCall', () {
    test('returns the result on first success — no retry', () async {
      var calls = 0;
      final result = await runSurveyCall(() async {
        calls++;
        return 42;
      });
      expect(result, 42);
      expect(calls, 1);
    });

    test('retries on transient failure then succeeds', () async {
      var calls = 0;
      final result = await runSurveyCall(
        () async {
          calls++;
          if (calls < 3) throw StateError('transient');
          return 'ok';
        },
        random: Random(0),
      );
      expect(result, 'ok');
      expect(calls, 3);
    });

    test('does NOT retry on auth failures', () async {
      var calls = 0;
      await expectLater(
        runSurveyCall<void>(() async {
          calls++;
          throw AuthException('jwt expired');
        }),
        throwsA(isA<AuthException>()),
      );
      expect(calls, 1);
    });

    test('does NOT retry on permanent PostgrestException (RLS)', () async {
      var calls = 0;
      await expectLater(
        runSurveyCall<void>(() async {
          calls++;
          throw PostgrestException(
            message: 'new row violates rls',
            code: '42501',
          );
        }),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 1);
    });

    test('does retry on transient PostgrestException (no code)', () async {
      var calls = 0;
      await expectLater(
        runSurveyCall<void>(
          () async {
            calls++;
            throw PostgrestException(message: 'connection reset');
          },
          maxAttempts: 3,
          random: Random(0),
        ),
        throwsA(isA<PostgrestException>()),
      );
      expect(calls, 3);
    });

    test('surfaces TimeoutException as SurveyTimeoutException after exhaust',
        () async {
      await expectLater(
        runSurveyCall<void>(
          () => Future.delayed(const Duration(milliseconds: 200)),
          timeout: const Duration(milliseconds: 10),
          maxAttempts: 2,
          random: Random(0),
        ),
        throwsA(isA<SurveyTimeoutException>()),
      );
    });
  });
}
