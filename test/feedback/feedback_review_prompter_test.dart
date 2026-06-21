import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/core/feedback/review/feedback_review_config.dart';
import 'package:nano_embryo/core/feedback/review/feedback_review_prompter.dart';
import 'package:nano_embryo/core/feedback/review/in_app_review_client.dart';
import 'package:nano_embryo/core/feedback/review/review_stats_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockClient extends Mock implements InAppReviewClient {}

void main() {
  late ReviewStatsStore store;
  late _MockClient client;

  /// Seed the store as if the user has been using the app for [daysInstalled]
  /// days, has launched [launches] times, recorded the last happy moment
  /// [daysSinceHappy] ago, and was last prompted [daysSincePrompt] ago
  /// (`null` means never).
  Future<void> seed({
    required int launches,
    required int daysInstalled,
    int? daysSinceHappy,
    int? daysSincePrompt,
    DateTime? now,
  }) async {
    final n = now ?? DateTime.utc(2026, 6, 14, 12);
    for (var i = 0; i < launches; i++) {
      await store.recordLaunch(
        now: n.subtract(Duration(days: daysInstalled - i)),
      );
    }
    if (daysSinceHappy != null) {
      await store.recordHappyMoment(
        now: n.subtract(Duration(days: daysSinceHappy)),
      );
    }
    if (daysSincePrompt != null) {
      await store.recordPromptShown(
        now: n.subtract(Duration(days: daysSincePrompt)),
      );
    }
  }

  FeedbackReviewPrompter make({
    FeedbackReviewConfig? config,
    DateTime? now,
  }) {
    return FeedbackReviewPrompter(
      stats: store,
      client: client,
      config: config ?? const FeedbackReviewConfig(),
      now: () => now ?? DateTime.utc(2026, 6, 14, 12),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    store = ReviewStatsStore(prefs);
    client = _MockClient();
    when(() => client.isAvailable()).thenAnswer((_) async => true);
    when(() => client.requestReview()).thenAnswer((_) async {});
    when(() => client.openStoreListing(appStoreId: any(named: 'appStoreId')))
        .thenAnswer((_) async {});
  });

  group('FeedbackReviewPrompter.evaluate (conservative defaults)', () {
    test('declines a fresh install (day 1, 1 launch)', () async {
      await seed(launches: 1, daysInstalled: 0, daysSinceHappy: 0);
      final p = make();
      expect(p.evaluate(), ReviewPromptOutcome.declinedTooFewLaunches);
    });

    test('declines when install is too fresh even with enough launches',
        () async {
      await seed(launches: 5, daysInstalled: 1, daysSinceHappy: 0);
      final p = make();
      expect(p.evaluate(), ReviewPromptOutcome.declinedTooFreshInstall);
    });

    test('declines when no recent happy moment', () async {
      await seed(launches: 5, daysInstalled: 5);
      final p = make();
      expect(p.evaluate(), ReviewPromptOutcome.declinedNoHappyMoment);
    });

    test('declines when last prompt was too recent', () async {
      await seed(
        launches: 5,
        daysInstalled: 200,
        daysSinceHappy: 0,
        daysSincePrompt: 30,
      );
      final p = make();
      expect(p.evaluate(), ReviewPromptOutcome.declinedRecentlyPrompted);
    });

    test('declines when last happy moment is stale (> 7 days)', () async {
      await seed(launches: 5, daysInstalled: 30, daysSinceHappy: 10);
      final p = make();
      expect(p.evaluate(), ReviewPromptOutcome.declinedNoHappyMoment);
    });

    test('approves when every gate is satisfied', () async {
      await seed(launches: 5, daysInstalled: 30, daysSinceHappy: 0);
      final p = make();
      expect(p.evaluate(), ReviewPromptOutcome.shown);
    });
  });

  group('FeedbackReviewPrompter.maybeAsk', () {
    test('does not call OS API when evaluate declines', () async {
      await seed(launches: 1, daysInstalled: 0);
      final outcome = await make().maybeAsk();
      expect(outcome, ReviewPromptOutcome.declinedTooFewLaunches);
      verifyNever(() => client.requestReview());
    });

    test('calls OS API, records prompt timestamp on success', () async {
      await seed(launches: 5, daysInstalled: 30, daysSinceHappy: 0);
      final outcome = await make().maybeAsk();
      expect(outcome, ReviewPromptOutcome.shown);
      verify(() => client.requestReview()).called(1);
      expect(store.lastPromptAt, isNotNull);
    });

    test('returns declinedNotAvailable when isAvailable=false; does NOT burn cooldown',
        () async {
      when(() => client.isAvailable()).thenAnswer((_) async => false);
      await seed(launches: 5, daysInstalled: 30, daysSinceHappy: 0);

      final outcome = await make().maybeAsk();

      expect(outcome, ReviewPromptOutcome.declinedNotAvailable);
      verifyNever(() => client.requestReview());
      expect(store.lastPromptAt, isNull,
          reason: 'OS unavailable must not eat the 90-day cooldown');
    });

    test('returns declinedError on platform exception; does NOT burn cooldown',
        () async {
      when(() => client.requestReview())
          .thenThrow(StateError('platform exploded'));
      await seed(launches: 5, daysInstalled: 30, daysSinceHappy: 0);

      final outcome = await make().maybeAsk();

      expect(outcome, ReviewPromptOutcome.declinedError);
      expect(store.lastPromptAt, isNull);
    });
  });

  group('FeedbackReviewPrompter.recordHappyMoment', () {
    test('writes the timestamp', () async {
      final p = make();
      await p.recordHappyMoment();
      expect(store.lastHappyAt, isNotNull);
    });
  });

  group('FeedbackReviewPrompter.openStoreListing', () {
    test('forwards configured appStoreId', () async {
      await make(
        config: const FeedbackReviewConfig(appStoreId: '6471234567'),
      ).openStoreListing();
      verify(() => client.openStoreListing(appStoreId: '6471234567'))
          .called(1);
    });

    test('swallows platform errors so the UI never crashes', () async {
      when(() => client.openStoreListing(appStoreId: any(named: 'appStoreId')))
          .thenThrow(StateError('store gone'));
      await make().openStoreListing(); // must not rethrow
    });
  });

  group('FeedbackReviewConfig.disabled()', () {
    test('never approves', () async {
      await seed(launches: 9999, daysInstalled: 9999, daysSinceHappy: 0);
      final p = make(config: FeedbackReviewConfig.disabled());
      expect(p.evaluate(), ReviewPromptOutcome.declinedTooFewLaunches);
    });
  });

  group('requireHappyMoment: false', () {
    test('skips happy-moment gate', () async {
      await seed(launches: 5, daysInstalled: 30); // no happy moment
      final p = make(
        config: const FeedbackReviewConfig(requireHappyMoment: false),
      );
      expect(p.evaluate(), ReviewPromptOutcome.shown);
    });
  });
}
