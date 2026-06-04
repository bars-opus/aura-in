// lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart
//
// Lost-booking rate severity bands.
//
// First-week tunable. Industry signal: Booksy cites 10–15% as the
// cross-industry average for cancellation + no-show rates in service
// businesses (https://biz.booksy.com/en-us/blog/no-show-policy-tips).
// We set `watchMax` at the lower bound and `hot` above the average.
//
// IEEE-754 representation of 0.07 and 0.12 in `double` is exact at
// these magnitudes, so boundary tests at exactly 0.07 and 0.12 are
// stable across platforms.

/// Severity bands for the lost-booking headline card.
enum LostBookingSeverity {
  /// Rate is within the healthy band — no callout.
  healthy,

  /// Rate is approaching the industry-average no-show zone.
  watch,

  /// Rate is above the cross-industry average — advisory chip surfaces.
  hot,
}

abstract class LostBookingThresholds {
  /// Top of the healthy band, inclusive. Rates `<= healthyMax` are healthy.
  static const double healthyMax = 0.07;

  /// Top of the watch band, inclusive. Rates `> healthyMax` and
  /// `<= watchMax` are watch. Anything above is hot.
  static const double watchMax = 0.12;

  /// Returns the severity band for a lost-booking rate.
  ///
  /// Semantics (load-bearing — tests assert each branch):
  ///
  ///   * `rate == null` → [LostBookingSeverity.healthy]. A null rate
  ///     means the universe is empty (no terminal bookings) — not a
  ///     red flag. The UI should still render the empty state, but the
  ///     severity bar should not show alarm colours.
  ///   * `rate <= healthyMax (0.07)` → [LostBookingSeverity.healthy].
  ///   * `rate <= watchMax (0.12)` → [LostBookingSeverity.watch].
  ///   * `else` → [LostBookingSeverity.hot].
  ///
  /// Use `<=` (inclusive) at each band's upper bound.
  static LostBookingSeverity classify(double? rate) {
    if (rate == null) return LostBookingSeverity.healthy;
    if (rate <= healthyMax) return LostBookingSeverity.healthy;
    if (rate <= watchMax) return LostBookingSeverity.watch;
    return LostBookingSeverity.hot;
  }
}
