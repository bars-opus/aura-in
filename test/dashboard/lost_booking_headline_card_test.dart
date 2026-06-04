// test/dashboard/lost_booking_headline_card_test.dart
//
// Widget tests for LostBookingHeadlineCard (Task 7.4). Strategy:
//  - Stub the LostBookingsController via a ProviderScope override.
//  - Pump the card inside MaterialApp + ScreenUtilInit (matches the
//    existing test/chat/message_bubble_test.dart pattern).
//  - Assert finder text per state without snapshot/golden infra.
//
// Three states under test:
//   1. Healthy (rate = 0.05) — no hot advisory copy
//   2. Hot (rate = 0.20) — advisory copy appears
//   3. Empty (rate == null) — empty-state copy appears, no spinner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_headline_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

LostBookingSummary _summary({
  required int total,
  required int honoured,
  required int cancelled,
  required int noShow,
  int prevTotal = 100,
  int prevCancelled = 5,
}) {
  return LostBookingSummary(
    periodDays: 7,
    windowStart: DateTime.utc(2026, 5, 27),
    windowEnd: DateTime.utc(2026, 6, 3),
    current: LostBookingPeriod(
      total: total,
      honoured: honoured,
      cancelled: cancelled,
      noShow: noShow,
      lostRevenue: 0,
    ),
    previous: LostBookingPeriod(
      total: prevTotal,
      honoured: prevTotal - prevCancelled,
      cancelled: prevCancelled,
      noShow: 0,
    ),
  );
}

/// Stubs the three repo calls to return the given state shape so the
/// real controller flows through its happy-path load. Easier than
/// stubbing the controller directly (which is internal-state-heavy).
void _stubRepo(
  _MockDashboardRepository repo, {
  required LostBookingSummary? summary,
}) {
  if (summary == null) {
    // Empty case: server returns shape with total=0.
    when(() => repo.getLostBookingSummary(
          shopId: any(named: 'shopId'),
          periodDays: any(named: 'periodDays'),
        )).thenAnswer((_) async => _summary(
          total: 0,
          honoured: 0,
          cancelled: 0,
          noShow: 0,
          prevTotal: 0,
          prevCancelled: 0,
        ));
  } else {
    when(() => repo.getLostBookingSummary(
          shopId: any(named: 'shopId'),
          periodDays: any(named: 'periodDays'),
        )).thenAnswer((_) async => summary);
  }
  when(() => repo.getLostBookingWeeklySeries(
        shopId: any(named: 'shopId'),
        weeks: any(named: 'weeks'),
      )).thenAnswer((_) async => const <LostBookingWeek>[]);
  when(() => repo.getLostBookingOffenders(
        shopId: any(named: 'shopId'),
        lookbackDays: any(named: 'lookbackDays'),
        minLost: any(named: 'minLost'),
      )).thenAnswer((_) async => const <LostBookingOffender>[]);
}

Widget _wrap(Widget child, _MockDashboardRepository repo) {
  return ProviderScope(
    overrides: [
      dashboardRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => child,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('healthy state: no hot advisory copy', (tester) async {
    final repo = _MockDashboardRepository();
    _stubRepo(repo,
        summary: _summary(total: 100, honoured: 95, cancelled: 5, noShow: 0));

    await tester.pumpWidget(
      _wrap(const LostBookingHeadlineCard(shopId: 'shop-a'), repo),
    );
    await tester.pumpAndSettle();

    // Headline title is always present.
    expect(find.text('Lost bookings · last 7 days'), findsOneWidget);
    // Healthy rate "5.0 %" surfaced.
    expect(find.text('5.0 %'), findsOneWidget);
    // No hot advisory chip.
    expect(
      find.textContaining('Consider a deposit policy'),
      findsNothing,
    );
  });

  testWidgets('hot state: advisory copy surfaces', (tester) async {
    final repo = _MockDashboardRepository();
    _stubRepo(repo,
        summary: _summary(total: 100, honoured: 80, cancelled: 15, noShow: 5));

    await tester.pumpWidget(
      _wrap(const LostBookingHeadlineCard(shopId: 'shop-a'), repo),
    );
    await tester.pumpAndSettle();

    expect(find.text('20.0 %'), findsOneWidget);
    expect(
      find.textContaining('Consider a deposit policy'),
      findsOneWidget,
    );
  });

  testWidgets('empty state: shows "no bookings yet" copy and no spinner',
      (tester) async {
    final repo = _MockDashboardRepository();
    _stubRepo(repo, summary: null);

    await tester.pumpWidget(
      _wrap(const LostBookingHeadlineCard(shopId: 'shop-a'), repo),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No completed or lost bookings in the last 7 days yet.'),
      findsOneWidget,
    );
    // No progress indicator should be present in the resolved empty state.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
