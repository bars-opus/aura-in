// lib/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart
//
// Lost-booking metric value objects backing the Analytics > Revenue
// headline card. Maps the JSONB shapes returned by the three RPCs in
// supabase/migrations/20260603002000_lost_booking_rpcs.sql.
//
// Definitions (locked in 10-SPEC.md):
//   honoured  = bookings.status = 'completed'
//   lost      = bookings.status IN ('cancelled','no_show')
//   universe  = bookings whose terminal status is one of the above
//   lost rate = lost / universe (null when universe == 0)
//
// Money is double here for parity with RevenueComparisonCard. The
// project-wide minor-units sweep is tracked separately — search for
// TODO(money-minor-units) below.

import 'package:equatable/equatable.dart';

class LostBookingSummary extends Equatable {
  /// Number of days the current/previous windows cover. Server-capped to [1, 90].
  final int periodDays;

  /// Inclusive lower bound of the current window (UTC).
  final DateTime windowStart;

  /// Exclusive upper bound of the current window (UTC, == now() at fetch time).
  final DateTime windowEnd;

  final LostBookingPeriod current;
  final LostBookingPeriod previous;

  const LostBookingSummary({
    required this.periodDays,
    required this.windowStart,
    required this.windowEnd,
    required this.current,
    required this.previous,
  });

  /// Lost rate this period, in [0.0, 1.0].
  ///
  /// Returns null when there are zero terminal bookings — the rate is
  /// undefined, and the UI must render the empty state ("No completed
  /// or lost bookings yet") rather than 0%, which would falsely imply
  /// a perfect score.
  double? get currentRate => current.total == 0
      ? null
      : (current.cancelled + current.noShow) / current.total;

  /// Lost rate the previous period, in [0.0, 1.0]. Null semantics match
  /// [currentRate].
  double? get previousRate => previous.total == 0
      ? null
      : (previous.cancelled + previous.noShow) / previous.total;

  /// Percentage-point delta of current vs previous. Null if either rate
  /// is undefined; the UI must not invent a delta in that case.
  double? get rateDelta => (currentRate == null || previousRate == null)
      ? null
      : currentRate! - previousRate!;

  factory LostBookingSummary.fromJson(Map<String, dynamic> json) {
    return LostBookingSummary(
      periodDays: (json['period_days'] as num).toInt(),
      windowStart: DateTime.parse(json['window_start'] as String),
      windowEnd: DateTime.parse(json['window_end'] as String),
      current: LostBookingPeriod.fromJson(
        Map<String, dynamic>.from(json['current'] as Map),
      ),
      previous: LostBookingPeriod.fromJson(
        Map<String, dynamic>.from(json['previous'] as Map),
      ),
    );
  }

  @override
  List<Object?> get props =>
      [periodDays, windowStart, windowEnd, current, previous];
}

class LostBookingPeriod extends Equatable {
  /// Count of bookings with a terminal status (completed / cancelled / no_show)
  /// whose start_time falls inside the window.
  final int total;

  final int honoured;
  final int cancelled;
  final int noShow;

  /// Sum of total_amount on lost bookings, in the shop's currency.
  ///
  /// TODO(money-minor-units): convert to integer minor units when the
  /// project-wide checklist 2.19 sweep lands. Keeping double for v1
  /// parity with the rest of the dashboard.
  final double lostRevenue;

  const LostBookingPeriod({
    required this.total,
    required this.honoured,
    required this.cancelled,
    required this.noShow,
    this.lostRevenue = 0,
  });

  factory LostBookingPeriod.fromJson(Map<String, dynamic> json) {
    return LostBookingPeriod(
      total: (json['total'] as num).toInt(),
      honoured: (json['honoured'] as num).toInt(),
      cancelled: (json['cancelled'] as num).toInt(),
      noShow: (json['no_show'] as num).toInt(),
      lostRevenue: json['lost_revenue'] == null
          ? 0
          : (json['lost_revenue'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [total, honoured, cancelled, noShow, lostRevenue];
}

class LostBookingWeek extends Equatable {
  final int isoYear;
  final int isoWeek;
  final DateTime startDate;
  final int total;
  final int lost;

  /// Rate in [0.0, 1.0]. Null when [total] is zero.
  final double? rate;

  const LostBookingWeek({
    required this.isoYear,
    required this.isoWeek,
    required this.startDate,
    required this.total,
    required this.lost,
    required this.rate,
  });

  factory LostBookingWeek.fromJson(Map<String, dynamic> json) {
    return LostBookingWeek(
      isoYear: (json['iso_year'] as num).toInt(),
      isoWeek: (json['iso_week'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      total: (json['total'] as num).toInt(),
      lost: (json['lost'] as num).toInt(),
      rate: json['rate'] == null ? null : (json['rate'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [isoYear, isoWeek, startDate, total, lost, rate];
}

class LostBookingOffender extends Equatable {
  final String clientId;
  final String displayName;
  final String? avatarUrl;
  final int totalBookings;
  final int lostBookings;

  /// Per-client lost rate in [0.0, 1.0].
  final double lostRate;

  /// Timestamp of the client's most recent lost booking. Uses the
  /// status-aware column on the server (cancelled_at for cancellations,
  /// updated_at for no_shows) so no-shows aren't silently dropped.
  final DateTime? lastLostAt;

  const LostBookingOffender({
    required this.clientId,
    required this.displayName,
    required this.avatarUrl,
    required this.totalBookings,
    required this.lostBookings,
    required this.lostRate,
    required this.lastLostAt,
  });

  factory LostBookingOffender.fromJson(Map<String, dynamic> json) {
    return LostBookingOffender(
      clientId: json['client_id'] as String,
      displayName: json['display_name'] as String? ?? 'Client',
      avatarUrl: json['avatar_url'] as String?,
      totalBookings: (json['total_bookings'] as num).toInt(),
      lostBookings: (json['lost_bookings'] as num).toInt(),
      lostRate: (json['lost_rate'] as num).toDouble(),
      lastLostAt: json['last_lost_at'] == null
          ? null
          : DateTime.parse(json['last_lost_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        clientId,
        displayName,
        avatarUrl,
        totalBookings,
        lostBookings,
        lostRate,
        lastLostAt,
      ];
}
