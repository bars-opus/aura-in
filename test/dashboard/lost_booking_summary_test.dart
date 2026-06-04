// test/dashboard/lost_booking_summary_test.dart
//
// Unit tests for LostBookingSummary rate semantics (Task 7.1).
// Locks the null-when-total-zero contract and the future/same-day/
// owner-cancelled edge cases that RESEARCH §9 gap 6.1 called out.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart';

void main() {
  group('LostBookingSummary.currentRate', () {
    test('returns null when current.total == 0', () {
      final summary = LostBookingSummary(
        periodDays: 7,
        windowStart: DateTime.utc(2026, 5, 27),
        windowEnd: DateTime.utc(2026, 6, 3),
        current: const LostBookingPeriod(
          total: 0,
          honoured: 0,
          cancelled: 0,
          noShow: 0,
        ),
        previous: const LostBookingPeriod(
          total: 0,
          honoured: 0,
          cancelled: 0,
          noShow: 0,
        ),
      );
      expect(summary.currentRate, isNull);
    });

    test('computes (cancelled + no_show) / total', () {
      final summary = LostBookingSummary(
        periodDays: 7,
        windowStart: DateTime.utc(2026, 5, 27),
        windowEnd: DateTime.utc(2026, 6, 3),
        current: const LostBookingPeriod(
          total: 339,
          honoured: 297,
          cancelled: 32,
          noShow: 10,
        ),
        previous: const LostBookingPeriod(
          total: 280,
          honoured: 257,
          cancelled: 18,
          noShow: 5,
        ),
      );
      // (32 + 10) / 339 == 0.12389...
      expect(summary.currentRate, closeTo(42 / 339, 1e-9));
    });
  });

  group('LostBookingSummary.rateDelta', () {
    test('returns null when current rate is null', () {
      final summary = LostBookingSummary(
        periodDays: 7,
        windowStart: DateTime.utc(2026, 5, 27),
        windowEnd: DateTime.utc(2026, 6, 3),
        current: const LostBookingPeriod(
          total: 0,
          honoured: 0,
          cancelled: 0,
          noShow: 0,
        ),
        previous: const LostBookingPeriod(
          total: 100,
          honoured: 90,
          cancelled: 7,
          noShow: 3,
        ),
      );
      expect(summary.rateDelta, isNull);
    });

    test('returns null when previous rate is null', () {
      final summary = LostBookingSummary(
        periodDays: 7,
        windowStart: DateTime.utc(2026, 5, 27),
        windowEnd: DateTime.utc(2026, 6, 3),
        current: const LostBookingPeriod(
          total: 100,
          honoured: 90,
          cancelled: 7,
          noShow: 3,
        ),
        previous: const LostBookingPeriod(
          total: 0,
          honoured: 0,
          cancelled: 0,
          noShow: 0,
        ),
      );
      expect(summary.rateDelta, isNull);
    });

    test('computes current - previous when both defined', () {
      final summary = LostBookingSummary(
        periodDays: 7,
        windowStart: DateTime.utc(2026, 5, 27),
        windowEnd: DateTime.utc(2026, 6, 3),
        current: const LostBookingPeriod(
          total: 100,
          honoured: 88,
          cancelled: 8,
          noShow: 4,
        ),
        previous: const LostBookingPeriod(
          total: 100,
          honoured: 91,
          cancelled: 7,
          noShow: 2,
        ),
      );
      // current rate = 12/100 = 0.12
      // previous rate = 9/100 = 0.09
      expect(summary.rateDelta, closeTo(0.03, 1e-9));
    });
  });

  group('LostBookingSummary.fromJson (server contract)', () {
    test('parses the documented RPC shape including lost_revenue', () {
      final json = <String, dynamic>{
        'period_days': 7,
        'window_start': '2026-05-27T00:00:00Z',
        'window_end': '2026-06-03T00:00:00Z',
        'current': {
          'total': 50,
          'honoured': 45,
          'cancelled': 4,
          'no_show': 1,
          'lost_revenue': 350,
        },
        'previous': {
          'total': 48,
          'honoured': 44,
          'cancelled': 3,
          'no_show': 1,
        },
      };
      final s = LostBookingSummary.fromJson(json);
      expect(s.periodDays, 7);
      expect(s.current.total, 50);
      expect(s.current.cancelled, 4);
      expect(s.current.noShow, 1);
      expect(s.current.lostRevenue, 350);
      expect(s.previous.total, 48);
      // The RPC omits lost_revenue from the previous bucket — model
      // defaults it to 0 instead of throwing.
      expect(s.previous.lostRevenue, 0);
    });

    // Server-side semantics test — a same-day cancellation IS in the
    // current window (bucket-by-start_time). The model only cares that
    // the server already counted it correctly; this test asserts the
    // model surfaces the count unchanged.
    test('owner-cancelled and same-day cancellations are counted as-is', () {
      // The server doesn't distinguish actor in v1; the count here
      // includes both owner-initiated and client-initiated cancels.
      final json = <String, dynamic>{
        'period_days': 7,
        'window_start': '2026-05-27T00:00:00Z',
        'window_end': '2026-06-03T00:00:00Z',
        'current': {
          'total': 10,
          'honoured': 6,
          // 3 client + 1 owner = 4 total cancellations
          'cancelled': 4,
          'no_show': 0,
          'lost_revenue': 0,
        },
        'previous': {
          'total': 0,
          'honoured': 0,
          'cancelled': 0,
          'no_show': 0,
        },
      };
      final s = LostBookingSummary.fromJson(json);
      expect(s.current.cancelled, 4);
      // The rate must reflect the full lost count regardless of actor.
      expect(s.currentRate, closeTo(0.4, 1e-9));
    });

    // Future-dated bookings: the server filters them out via
    // start_time < now(). The model should never see them in the
    // current bucket; this test documents that contract — if the
    // server regresses and starts including future cancellations, the
    // controller-level test in 7.3 will catch it (mock returns the
    // future booking).
    test('future-dated cancellations are excluded server-side, '
        'so model.current.total only includes bookings within the window',
        () {
      // The mock here is the JSON the server returns AFTER filtering.
      // The model is unconcerned with the filter itself.
      final json = <String, dynamic>{
        'period_days': 7,
        'window_start': '2026-05-27T00:00:00Z',
        'window_end': '2026-06-03T00:00:00Z',
        'current': {
          'total': 5, // server saw 7 - 2 future-dated = 5
          'honoured': 4,
          'cancelled': 1,
          'no_show': 0,
          'lost_revenue': 0,
        },
        'previous': {
          'total': 5,
          'honoured': 4,
          'cancelled': 1,
          'no_show': 0,
        },
      };
      final s = LostBookingSummary.fromJson(json);
      expect(s.current.total, 5);
      expect(s.currentRate, closeTo(0.2, 1e-9));
    });
  });
}
