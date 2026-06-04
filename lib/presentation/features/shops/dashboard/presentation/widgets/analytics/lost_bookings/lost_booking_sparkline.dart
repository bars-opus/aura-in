// lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_sparkline.dart
//
// 12-bar sparkline showing weekly lost-booking rate trend.
//
// Stand-alone CustomPainter — fl_chart's BarChart is overkill (and
// QuarterlyRevenueChart is too coupled to YearlyRevenue to reuse).
// Each bar's height is proportional to its week's rate (clamped to
// [0, 0.25] visually so a single 30%-spike week doesn't crush the
// rest). Empty weeks render as a 1-pixel baseline so the bar count
// matches `weeks.length` consistently.

import 'package:flutter/material.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart';

/// Compact 12-bar sparkline. Designed for a ~80×32 logical-pixel
/// footprint inside [LostBookingHeadlineCard]. Use a SizedBox if you
/// want a different size — the painter scales to its constraints.
class LostBookingSparkline extends StatelessWidget {
  final List<LostBookingWeek> weeks;
  final double width;
  final double height;

  const LostBookingSparkline({
    super.key,
    required this.weeks,
    this.width = 80,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Resolve theme-driven colours here (NOT inside the painter — keeps
    // hot-reload theme switches honest, per checklist R6 mitigation).
    final palette = LostBookingSparklinePalette(
      healthy: scheme.primary,
      watch: const Color(0xFFFFB020), // amber 600 — matches Material 3 warning
      hot: scheme.error,
      baseline: scheme.outline.withValues(alpha: 0.35),
    );

    final summary = _semanticSummary(weeks);
    return Semantics(
      label: summary,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _LostBookingSparklinePainter(
            weeks: weeks,
            palette: palette,
          ),
        ),
      ),
    );
  }

  /// One-sentence summary for screen readers: "12-week trend: 8 percent
  /// to 12 percent, rising".
  static String _semanticSummary(List<LostBookingWeek> weeks) {
    if (weeks.isEmpty) return 'Lost-booking trend: no data yet';

    final firstRated = weeks.firstWhere(
      (w) => w.rate != null,
      orElse: () => weeks.first,
    );
    final lastRated = weeks.lastWhere(
      (w) => w.rate != null,
      orElse: () => weeks.last,
    );
    final startPct = ((firstRated.rate ?? 0) * 100).round();
    final endPct = ((lastRated.rate ?? 0) * 100).round();
    final direction = endPct > startPct
        ? 'rising'
        : (endPct < startPct ? 'falling' : 'flat');
    return '${weeks.length}-week lost-booking trend: '
        '$startPct percent to $endPct percent, $direction';
  }
}

/// Colour palette resolved from theme by the wrapping widget and
/// passed in so the painter has no Theme dependency (cleaner hot-reload
/// behaviour and easier to test).
class LostBookingSparklinePalette {
  final Color healthy;
  final Color watch;
  final Color hot;
  final Color baseline;

  const LostBookingSparklinePalette({
    required this.healthy,
    required this.watch,
    required this.hot,
    required this.baseline,
  });

  Color colorFor(LostBookingSeverity s) {
    switch (s) {
      case LostBookingSeverity.healthy:
        return healthy;
      case LostBookingSeverity.watch:
        return watch;
      case LostBookingSeverity.hot:
        return hot;
    }
  }
}

class _LostBookingSparklinePainter extends CustomPainter {
  final List<LostBookingWeek> weeks;
  final LostBookingSparklinePalette palette;

  /// Visual cap so a single spike doesn't crush the rest of the bars.
  /// Set just above watchMax to keep within-band variation legible.
  static const double _visualCap = 0.25;

  /// Bar width fraction of the per-bar slot (the rest is gap).
  static const double _barWidthFrac = 0.7;

  /// Minimum bar height (baseline) so even empty weeks are visible.
  static const double _baselineHeight = 1.0;

  _LostBookingSparklinePainter({
    required this.weeks,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weeks.isEmpty) {
      _paintBaseline(canvas, size, palette.baseline);
      return;
    }

    final n = weeks.length;
    final slotW = size.width / n;
    final barW = slotW * _barWidthFrac;
    final radius = Radius.circular(barW * 0.25);

    for (var i = 0; i < n; i++) {
      final week = weeks[i];
      final rate = week.rate ?? 0;
      final isEmpty = week.total == 0 || week.rate == null;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = isEmpty
            ? palette.baseline
            : palette.colorFor(LostBookingThresholds.classify(rate));

      // Height: proportional to rate vs visual cap, clamped.
      final pct = isEmpty ? 0.0 : (rate / _visualCap).clamp(0.0, 1.0);
      final hPx = isEmpty
          ? _baselineHeight
          : ((size.height - _baselineHeight) * pct + _baselineHeight)
              .clamp(_baselineHeight, size.height);

      final left = i * slotW + (slotW - barW) / 2;
      final top = size.height - hPx;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barW, hPx),
        topLeft: radius,
        topRight: radius,
      );
      canvas.drawRRect(rect, paint);
    }
  }

  void _paintBaseline(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(
      0,
      size.height - _baselineHeight,
      size.width,
      _baselineHeight,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _LostBookingSparklinePainter old) =>
      old.weeks != weeks ||
      old.palette.healthy != palette.healthy ||
      old.palette.watch != palette.watch ||
      old.palette.hot != palette.hot ||
      old.palette.baseline != palette.baseline;
}
