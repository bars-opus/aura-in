// test/dashboard/lost_bookings_controller_test.dart
//
// Controller-level tests for LostBookingsController (Task 7.3).
// Covers:
//   1. Happy path — all three RPCs succeed → state populated, error == null.
//   2. Graceful degradation — offenders fails but the other two succeed
//      → state still populated, offenders == [], error == null.
//   3. Disposed-mid-flight — dispose() fires while futures are pending,
//      no further state mutations land after disposal.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/lost_bookings_controller.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late _MockDashboardRepository repo;

  final summaryFixture = LostBookingSummary(
    periodDays: 7,
    windowStart: DateTime.utc(2026, 5, 27),
    windowEnd: DateTime.utc(2026, 6, 3),
    current: const LostBookingPeriod(
      total: 100,
      honoured: 90,
      cancelled: 7,
      noShow: 3,
      lostRevenue: 500,
    ),
    previous: const LostBookingPeriod(
      total: 90,
      honoured: 85,
      cancelled: 4,
      noShow: 1,
    ),
  );
  final weeksFixture = [
    LostBookingWeek(
      isoYear: 2026,
      isoWeek: 22,
      startDate: DateTime.utc(2026, 5, 27),
      total: 50,
      lost: 5,
      rate: 0.1,
    ),
  ];
  final offendersFixture = [
    LostBookingOffender(
      clientId: 'client-1',
      displayName: 'Test Client',
      avatarUrl: null,
      totalBookings: 4,
      lostBookings: 2,
      lostRate: 0.5,
      lastLostAt: DateTime.utc(2026, 6, 1),
    ),
  ];

  setUp(() {
    repo = _MockDashboardRepository();
  });

  /// Waits for all controller state writes triggered by the in-flight
  /// Future.wait to settle. Two microtask drains are enough because the
  /// controller does one await on Future.wait followed by one state write.
  Future<void> settle() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  test('happy path: all three RPCs succeed → state populated', () async {
    when(() => repo.getLostBookingSummary(
          shopId: any(named: 'shopId'),
          periodDays: any(named: 'periodDays'),
        )).thenAnswer((_) async => summaryFixture);
    when(() => repo.getLostBookingWeeklySeries(
          shopId: any(named: 'shopId'),
          weeks: any(named: 'weeks'),
        )).thenAnswer((_) async => weeksFixture);
    when(() => repo.getLostBookingOffenders(
          shopId: any(named: 'shopId'),
          lookbackDays: any(named: 'lookbackDays'),
          minLost: any(named: 'minLost'),
        )).thenAnswer((_) async => offendersFixture);

    final controller =
        LostBookingsController(repository: repo, shopId: 'shop-a');
    await settle();
    addTearDown(controller.dispose);

    expect(controller.state.summary, isNotNull);
    expect(controller.state.summary!.current.total, 100);
    expect(controller.state.weeks, hasLength(1));
    expect(controller.state.offenders, hasLength(1));
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.error, isNull);
  });

  test('graceful degradation: offenders throws, others succeed', () async {
    when(() => repo.getLostBookingSummary(
          shopId: any(named: 'shopId'),
          periodDays: any(named: 'periodDays'),
        )).thenAnswer((_) async => summaryFixture);
    when(() => repo.getLostBookingWeeklySeries(
          shopId: any(named: 'shopId'),
          weeks: any(named: 'weeks'),
        )).thenAnswer((_) async => weeksFixture);
    when(() => repo.getLostBookingOffenders(
          shopId: any(named: 'shopId'),
          lookbackDays: any(named: 'lookbackDays'),
          minLost: any(named: 'minLost'),
        )).thenThrow(DashboardRepositoryException('load_failed'));

    final controller =
        LostBookingsController(repository: repo, shopId: 'shop-a');
    await settle();
    addTearDown(controller.dispose);

    // Summary and weeks populated; offenders is [] (empty list, not null);
    // error stays null because not every query failed.
    expect(controller.state.summary, isNotNull);
    expect(controller.state.weeks, hasLength(1));
    expect(controller.state.offenders, isEmpty);
    expect(controller.state.error, isNull);
    expect(controller.state.isLoading, isFalse);
  });

  test('all three fail → error == "load_failed"', () async {
    when(() => repo.getLostBookingSummary(
          shopId: any(named: 'shopId'),
          periodDays: any(named: 'periodDays'),
        )).thenThrow(DashboardRepositoryException('load_failed'));
    when(() => repo.getLostBookingWeeklySeries(
          shopId: any(named: 'shopId'),
          weeks: any(named: 'weeks'),
        )).thenThrow(DashboardRepositoryException('load_failed'));
    when(() => repo.getLostBookingOffenders(
          shopId: any(named: 'shopId'),
          lookbackDays: any(named: 'lookbackDays'),
          minLost: any(named: 'minLost'),
        )).thenThrow(DashboardRepositoryException('load_failed'));

    final controller =
        LostBookingsController(repository: repo, shopId: 'shop-a');
    await settle();
    addTearDown(controller.dispose);

    expect(controller.state.error, 'load_failed');
    expect(controller.state.summary, isNull);
    expect(controller.state.weeks, isEmpty);
  });

  test('disposed mid-flight: no state mutations land after dispose()',
      () async {
    // Use a Completer so we control when the future resolves.
    final summaryCompleter = Completer<LostBookingSummary>();
    when(() => repo.getLostBookingSummary(
          shopId: any(named: 'shopId'),
          periodDays: any(named: 'periodDays'),
        )).thenAnswer((_) => summaryCompleter.future);
    when(() => repo.getLostBookingWeeklySeries(
          shopId: any(named: 'shopId'),
          weeks: any(named: 'weeks'),
        )).thenAnswer((_) async => weeksFixture);
    when(() => repo.getLostBookingOffenders(
          shopId: any(named: 'shopId'),
          lookbackDays: any(named: 'lookbackDays'),
          minLost: any(named: 'minLost'),
        )).thenAnswer((_) async => offendersFixture);

    final controller =
        LostBookingsController(repository: repo, shopId: 'shop-a');

    // Subscribe to every state write. addListener fires immediately with
    // the current state, so we count writes before vs after dispose to
    // detect any late mutation. StateNotifier.state throws after dispose
    // in debug, which is why we go through the listener instead.
    var writes = 0;
    final removeListener = controller.addListener((_) => writes++);
    final writesBeforeDispose = writes;

    controller.dispose();
    summaryCompleter.complete(summaryFixture);
    await settle();

    expect(writes, writesBeforeDispose,
        reason:
            'a state write occurred after dispose() — _disposed guard failed');
    removeListener();
  });
}
