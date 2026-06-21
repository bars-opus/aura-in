import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/feedback/review/app_lifecycle_launch_counter.dart';
import 'package:nano_embryo/core/feedback/review/review_stats_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ReviewStatsStore store;
  late Provider<ReviewStatsStore> storeProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    store = ReviewStatsStore(prefs);
    storeProvider = Provider<ReviewStatsStore>((_) => store);
  });

  late DateTime fakeNow;

  Future<void> pumpCounter(
    WidgetTester tester, {
    Duration minBackgrounded = const Duration(milliseconds: 50),
  }) async {
    fakeNow = DateTime.utc(2026, 6, 14, 12);
    await tester.pumpWidget(
      ProviderScope(
        child: AppLifecycleLaunchCounter(
          storeProvider: storeProvider,
          minBackgroundedDuration: minBackgrounded,
          clock: () => fakeNow,
          child: const SizedBox.shrink(),
        ),
      ),
    );
    // Let the post-frame callback fire.
    await tester.pump();
  }

  void emit(AppLifecycleState state) {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.handleAppLifecycleStateChanged(state);
  }

  testWidgets('cold mount records one launch', (tester) async {
    await pumpCounter(tester);
    expect(store.launchCount, 1);
  });

  testWidgets('rapid background → resume does NOT count', (tester) async {
    await pumpCounter(
      tester,
      minBackgrounded: const Duration(seconds: 30),
    );
    expect(store.launchCount, 1);

    emit(AppLifecycleState.paused);
    // Clock barely advances — well under the 30s threshold.
    fakeNow = fakeNow.add(const Duration(seconds: 5));
    emit(AppLifecycleState.resumed);
    await tester.pump();

    expect(store.launchCount, 1,
        reason: 'sub-30s background flip should not count');
  });

  testWidgets('background ≥ minBackgrounded then resume DOES count',
      (tester) async {
    await pumpCounter(
      tester,
      minBackgrounded: const Duration(seconds: 30),
    );
    expect(store.launchCount, 1);

    emit(AppLifecycleState.paused);
    fakeNow = fakeNow.add(const Duration(seconds: 31));
    emit(AppLifecycleState.resumed);
    await tester.pump();

    expect(store.launchCount, 2);
  });

  testWidgets('inactive/detached transitions are ignored', (tester) async {
    await pumpCounter(tester);
    emit(AppLifecycleState.inactive);
    emit(AppLifecycleState.detached);
    await tester.pump();
    expect(store.launchCount, 1);
  });
}
