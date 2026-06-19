import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/feedback/review/review_stats_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ReviewStatsStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    store = ReviewStatsStore(prefs);
  });

  group('ReviewStatsStore', () {
    test('starts empty', () {
      expect(store.launchCount, 0);
      expect(store.firstLaunchAt, isNull);
      expect(store.lastPromptAt, isNull);
      expect(store.lastHappyAt, isNull);
    });

    test('recordLaunch increments and seeds firstLaunchAt only once',
        () async {
      final first = DateTime.utc(2026, 6, 14, 9);
      await store.recordLaunch(now: first);
      expect(store.launchCount, 1);
      expect(store.firstLaunchAt, first);

      final later = DateTime.utc(2026, 7, 1, 9);
      await store.recordLaunch(now: later);
      expect(store.launchCount, 2);
      expect(store.firstLaunchAt, first, reason: 'first-launch is immutable');
    });

    test('recordPromptShown writes timestamp', () async {
      final t = DateTime.utc(2026, 6, 14, 12);
      await store.recordPromptShown(now: t);
      expect(store.lastPromptAt, t);
    });

    test('recordHappyMoment writes timestamp', () async {
      final t = DateTime.utc(2026, 6, 14, 18);
      await store.recordHappyMoment(now: t);
      expect(store.lastHappyAt, t);
    });

    test('reset clears every key', () async {
      await store.recordLaunch(now: DateTime.utc(2026, 6, 14));
      await store.recordPromptShown(now: DateTime.utc(2026, 6, 14));
      await store.recordHappyMoment(now: DateTime.utc(2026, 6, 14));
      await store.reset();
      expect(store.launchCount, 0);
      expect(store.firstLaunchAt, isNull);
      expect(store.lastPromptAt, isNull);
      expect(store.lastHappyAt, isNull);
    });
  });
}
