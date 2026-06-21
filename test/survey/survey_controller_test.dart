import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/core/config/survey/domain/entities/survey_response.dart';
import 'package:nano_embryo/core/config/survey/domain/repositories/survey_repository.dart';
import 'package:nano_embryo/core/config/survey/exceptions/survey_exceptions.dart';
import 'package:nano_embryo/core/config/survey/presentation/controllers/survey_controller.dart';

class _MockRepo extends Mock implements SurveyRepository {}

SurveyController _make(
  SurveyRepository repo, {
  int threshold = 4,
  void Function(String, Map<String, Object?>)? onEvent,
}) {
  return SurveyController(
    repo,
    'user-1',
    completionThreshold: threshold,
    onEvent: onEvent,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, Sentiment>{});
  });

  group('SurveyController.submitAllResponses', () {
    test('refuses to submit when nothing is selected', () async {
      final repo = _MockRepo();
      final c = _make(repo);

      final ok = await c.submitAllResponses();

      expect(ok, isFalse);
      expect(c.state.errorMessage, contains('at least one'));
      verifyNever(() => repo.submitResponses(any(), any()));
    });

    test('bulk-submits once and emits survey_submitted', () async {
      final repo = _MockRepo();
      when(() => repo.submitResponses(any(), any()))
          .thenAnswer((_) async {});
      final events = <(String, Map<String, Object?>)>[];
      final c = _make(repo, onEvent: (e, a) => events.add((e, a)));

      c.setSentiment('booking', Sentiment.like);
      c.setSentiment('discover_shops', Sentiment.dislike);

      final ok = await c.submitAllResponses();

      expect(ok, isTrue);
      expect(c.state.isSubmitting, isFalse);
      expect(c.state.errorMessage, isNull);
      verify(() => repo.submitResponses('user-1', {
            'booking': Sentiment.like,
            'discover_shops': Sentiment.dislike,
          })).called(1);
      expect(
        events.map((e) => e.$1).toList(),
        containsAllInOrder(['survey_submit_started', 'survey_submitted']),
      );
      final submitted = events.firstWhere((e) => e.$1 == 'survey_submitted').$2;
      expect(submitted['response_count'], 2);
      expect(submitted['likes'], 1);
      expect(submitted['dislikes'], 1);
    });

    test('reentrant double-tap fires only one repo call', () async {
      final repo = _MockRepo();
      final pending = Completer<void>();
      when(() => repo.submitResponses(any(), any()))
          .thenAnswer((_) => pending.future);
      final c = _make(repo);
      c.setSentiment('booking', Sentiment.like);

      final first = c.submitAllResponses();
      final second = c.submitAllResponses(); // mid-flight — must short-circuit

      expect(c.state.isSubmitting, isTrue);
      expect(await second, isFalse);
      pending.complete();
      expect(await first, isTrue);
      verify(() => repo.submitResponses(any(), any())).called(1);
    });

    test('maps SurveyTimeoutException to retryable error', () async {
      final repo = _MockRepo();
      when(() => repo.submitResponses(any(), any()))
          .thenThrow(SurveyTimeoutException('slow'));
      final events = <(String, Map<String, Object?>)>[];
      final c = _make(repo, onEvent: (e, a) => events.add((e, a)));
      c.setSentiment('booking', Sentiment.like);

      final ok = await c.submitAllResponses();

      expect(ok, isFalse);
      expect(c.state.errorIsRetryable, isTrue);
      expect(c.state.errorMessage, contains('Try again'));
      expect(
        events.singleWhere((e) => e.$1 == 'survey_submit_failed').$2['category'],
        'timeout',
      );
    });

    test('maps SurveyAuthException to non-retryable error', () async {
      final repo = _MockRepo();
      when(() => repo.submitResponses(any(), any()))
          .thenThrow(SurveyAuthException('jwt expired'));
      final c = _make(repo);
      c.setSentiment('booking', Sentiment.like);

      await c.submitAllResponses();

      expect(c.state.errorIsRetryable, isFalse);
      expect(c.state.errorMessage, contains('log in'));
    });

    test('maps SurveyValidationException to non-retryable error', () async {
      final repo = _MockRepo();
      when(() => repo.submitResponses(any(), any()))
          .thenThrow(SurveyValidationException('bad key'));
      final c = _make(repo);
      c.setSentiment('booking', Sentiment.like);

      await c.submitAllResponses();

      expect(c.state.errorIsRetryable, isFalse);
      expect(c.state.errorMessage, contains('invalid'));
    });

    test('safe across dispose — no state mutation after disposal', () async {
      final repo = _MockRepo();
      final pending = Completer<void>();
      when(() => repo.submitResponses(any(), any()))
          .thenAnswer((_) => pending.future);
      final c = _make(repo);
      c.setSentiment('booking', Sentiment.like);

      final f = c.submitAllResponses();
      c.dispose();
      pending.complete();

      expect(await f, isFalse);
      // No throw — the assertion is that the controller didn't crash trying
      // to set state on a disposed notifier.
    });

    test('onEvent that throws does not break the submit flow', () async {
      final repo = _MockRepo();
      when(() => repo.submitResponses(any(), any()))
          .thenAnswer((_) async {});
      final c = _make(repo, onEvent: (_, _) {
        throw StateError('analytics is on fire');
      });
      c.setSentiment('booking', Sentiment.like);

      expect(await c.submitAllResponses(), isTrue);
    });
  });

  group('SurveyController.loadResponses', () {
    test('populates state and marks complete when threshold reached',
        () async {
      final repo = _MockRepo();
      when(() => repo.getUserResponses('user-1')).thenAnswer((_) async => {
            'a': Sentiment.like,
            'b': Sentiment.like,
            'c': Sentiment.dislike,
            'd': Sentiment.like,
          });
      final c = _make(repo, threshold: 4);

      await c.loadResponses();

      expect(c.state.responses.length, 4);
      expect(c.state.hasCompleted, isTrue);
      expect(c.state.errorMessage, isNull);
    });

    test('routes timeout to retryable error message', () async {
      final repo = _MockRepo();
      when(() => repo.getUserResponses('user-1'))
          .thenThrow(SurveyTimeoutException('slow'));
      final c = _make(repo);

      await c.loadResponses();

      expect(c.state.errorIsRetryable, isTrue);
      expect(c.state.isLoading, isFalse);
    });
  });

  group('SurveyController.setSentiment', () {
    test('optimistic update flips the chip and updates hasCompleted', () {
      final repo = _MockRepo();
      final c = _make(repo, threshold: 2);

      c.setSentiment('a', Sentiment.like);
      expect(c.state.responses, {'a': Sentiment.like});
      expect(c.state.hasCompleted, isFalse);

      c.setSentiment('b', Sentiment.dislike);
      expect(c.state.hasCompleted, isTrue);

      c.setSentiment('a', Sentiment.dislike);
      expect(c.state.responses['a'], Sentiment.dislike);
    });
  });
}
