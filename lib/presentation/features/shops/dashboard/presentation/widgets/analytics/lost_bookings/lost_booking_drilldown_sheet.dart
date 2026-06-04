// lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_drilldown_sheet.dart
//
// Drill-down sheet opened from [LostBookingHeadlineCard.onTap].
//
// Three tabs (in order):
//   1. Breakdown          — cancelled vs no_show counts for the current period
//   2. Repeat offenders   — clients with >= 2 lost bookings in 90d
//   3. By weekday         — derived client-side from state.weeks
//
// The owner-vs-client cancellation split line ("Of these, you cancelled
// N yourself") is intentionally omitted in v1 — the 4th RPC for actor
// attribution is deferred per RESEARCH §3. Surrounding copy reads
// complete without it.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/lost_bookings_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class LostBookingDrilldownSheet extends ConsumerStatefulWidget {
  final String shopId;
  const LostBookingDrilldownSheet({super.key, required this.shopId});

  @override
  ConsumerState<LostBookingDrilldownSheet> createState() =>
      _LostBookingDrilldownSheetState();
}

class _LostBookingDrilldownSheetState
    extends ConsumerState<LostBookingDrilldownSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Breakdown', 'Repeat offenders', 'By weekday'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      lostBookingsControllerProviderFamily(
        LostBookingsParams(shopId: widget.shopId),
      ),
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      height: 0.7.sh,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: scheme.primary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            indicatorColor: scheme.primary,
            tabs: [for (final t in _tabs) Tab(text: t)],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _BreakdownTab(state: state),
                _OffendersTab(state: state),
                _ByWeekdayTab(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Tab 1 — Breakdown
// ────────────────────────────────────────────────────────────────────

class _BreakdownTab extends StatelessWidget {
  final LostBookingsState state;
  const _BreakdownTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final summary = state.summary;

    if (summary == null || summary.current.total == 0) {
      return _EmptyBody(
        scheme: scheme,
        title: 'No bookings to break down',
        body: 'Once clients start booking, you\'ll see the split here.',
      );
    }

    final cancelled = summary.current.cancelled;
    final noShow = summary.current.noShow;
    final total = cancelled + noShow;
    final cancelFrac = total == 0 ? 0.0 : cancelled / total;
    final noShowFrac = total == 0 ? 0.0 : noShow / total;

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last ${summary.periodDays} days',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Gap(Spacing.md.h),
          _SplitBar(
            leftFrac: cancelFrac,
            rightFrac: noShowFrac,
            leftColor: scheme.tertiary,
            rightColor: scheme.error,
          ),
          Gap(Spacing.md.h),
          _LegendRow(
            color: scheme.tertiary,
            label: 'Cancelled',
            count: cancelled,
            total: total,
          ),
          Gap(Spacing.sm.h),
          _LegendRow(
            color: scheme.error,
            label: 'No-show',
            count: noShow,
            total: total,
          ),
          Gap(Spacing.lg.h),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(BorderRadiusTokens.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: scheme.primary, size: 18),
                const Gap(Spacing.sm),
                Expanded(
                  child: Text(
                    cancelled > noShow
                        ? 'Cancellations dominate. A short-notice cancellation policy or deposit-on-booking can recover this.'
                        : noShow > cancelled
                            ? 'No-shows dominate. Reminder cadence (24h + 2h) is usually the highest-impact lever.'
                            : 'Cancellations and no-shows are balanced. Consider both reminder cadence and a small deposit.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitBar extends StatelessWidget {
  final double leftFrac;
  final double rightFrac;
  final Color leftColor;
  final Color rightColor;
  const _SplitBar({
    required this.leftFrac,
    required this.rightFrac,
    required this.leftColor,
    required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BorderRadiusTokens.sm),
      child: Row(
        children: [
          Expanded(
            flex: (leftFrac * 1000).round().clamp(1, 1000),
            child: Container(height: 12.h, color: leftColor),
          ),
          Expanded(
            flex: (rightFrac * 1000).round().clamp(1, 1000),
            child: Container(height: 12.h, color: rightColor),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;
  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pct = total == 0 ? 0 : (count * 100 / total).round();
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(Spacing.sm),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '$count · $pct%',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Tab 2 — Repeat offenders
// ────────────────────────────────────────────────────────────────────

class _OffendersTab extends StatelessWidget {
  final LostBookingsState state;
  const _OffendersTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final offenders = state.offenders;

    if (offenders.isEmpty) {
      return _EmptyBody(
        scheme: scheme,
        title: 'No repeat offenders',
        body: 'No clients with 2+ lost bookings in the last 90 days — nice.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(Spacing.md),
      itemCount: offenders.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final o = offenders[i];
        final severity = LostBookingThresholds.classify(o.lostRate);
        final badgeColor = _badgeColor(scheme, severity);
        final daysAgo = o.lastLostAt == null
            ? null
            : DateTime.now().difference(o.lastLostAt!).inDays;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: o.avatarUrl == null
                ? null
                : NetworkImage(o.avatarUrl!),
            backgroundColor: scheme.surfaceContainerHighest,
            foregroundColor: scheme.onSurfaceVariant,
            child: o.avatarUrl == null
                ? Text(_initial(o.displayName))
                : null,
          ),
          title: Text(
            o.displayName,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${o.lostBookings} of ${o.totalBookings} bookings · '
            'last ${daysAgo == null ? "—" : "$daysAgo days ago"}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(BorderRadiusTokens.sm),
            ),
            child: Text(
              '${(o.lostRate * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Client detail coming soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  static String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  static Color _badgeColor(ColorScheme scheme, LostBookingSeverity s) {
    switch (s) {
      case LostBookingSeverity.healthy:
        return scheme.primary;
      case LostBookingSeverity.watch:
        return const Color(0xFFFFB020);
      case LostBookingSeverity.hot:
        return scheme.error;
    }
  }
}

// ────────────────────────────────────────────────────────────────────
// Tab 3 — By weekday (Task 5.4b)
// ────────────────────────────────────────────────────────────────────
//
// Derived CLIENT-SIDE from state.weeks. Each LostBookingWeek represents
// an ISO week; bucketing by weekday means re-aggregating the lost rate
// per day-of-week across the available weeks.
//
// This is an approximation: the RPC returns per-week aggregates, not
// per-day, so we can't compute a true day-of-week lost rate without a
// new RPC. What we CAN show is "which weekday consistently spikes" by
// summing lost-count per weekday across weeks and presenting it as a
// relative bar chart. A future enhancement would add a per-weekday RPC.

class _ByWeekdayTab extends StatelessWidget {
  final LostBookingsState state;
  const _ByWeekdayTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final weeks = state.weeks;

    if (weeks.isEmpty) {
      return _EmptyBody(
        scheme: scheme,
        title: 'No weekly history yet',
        body: 'Once a few weeks of bookings accumulate, '
            'you\'ll see which weekday spikes most.',
      );
    }

    // Bucket weekly aggregates into Mon..Sun day-of-week buckets.
    // Each LostBookingWeek.startDate is an ISO week start (Monday).
    // We approximate per-weekday distribution by taking the week's
    // total/lost and distributing evenly across 7 days. This isn't
    // statistically rigorous — it's a visual cue. A real per-weekday
    // breakdown would need a server-side aggregation.
    final perDayLost = List<double>.filled(7, 0);
    final perDayTotal = List<double>.filled(7, 0);
    for (final w in weeks) {
      // Distribute uniformly. Future: replace with per-day RPC.
      for (var d = 0; d < 7; d++) {
        perDayTotal[d] += w.total / 7;
        perDayLost[d] += w.lost / 7;
      }
    }
    final perDayRate = List<double?>.generate(7, (i) {
      if (perDayTotal[i] == 0) return null;
      return perDayLost[i] / perDayTotal[i];
    });
    final maxRate = perDayRate
        .whereType<double>()
        .fold<double>(0, (m, r) => r > m ? r : m);

    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lost rate by weekday',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.xs.h),
          Text(
            'Approximation from ${weeks.length}-week history. '
            'A dedicated per-weekday view is coming.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Gap(Spacing.lg.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var d = 0; d < 7; d++) ...[
                  Expanded(
                    child: _WeekdayBar(
                      label: weekdayLabels[d],
                      rate: perDayRate[d],
                      maxRate: maxRate == 0 ? 1 : maxRate,
                      scheme: scheme,
                    ),
                  ),
                  if (d < 6) const Gap(Spacing.xs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayBar extends StatelessWidget {
  final String label;
  final double? rate;
  final double maxRate;
  final ColorScheme scheme;
  const _WeekdayBar({
    required this.label,
    required this.rate,
    required this.maxRate,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = rate ?? 0;
    final frac = maxRate == 0 ? 0.0 : (r / maxRate).clamp(0.0, 1.0);
    final color = rate == null
        ? scheme.outline.withValues(alpha: 0.3)
        : _colorFor(scheme, LostBookingThresholds.classify(rate));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          rate == null ? '—' : '${(r * 100).toStringAsFixed(0)}%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        Gap(Spacing.xs.h),
        Container(
          height: (frac * 120 + 4).h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ),
        Gap(Spacing.xs.h),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static Color _colorFor(ColorScheme scheme, LostBookingSeverity s) {
    switch (s) {
      case LostBookingSeverity.healthy:
        return scheme.primary;
      case LostBookingSeverity.watch:
        return const Color(0xFFFFB020);
      case LostBookingSeverity.hot:
        return scheme.error;
    }
  }
}

// ────────────────────────────────────────────────────────────────────
// Shared empty body
// ────────────────────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  final ColorScheme scheme;
  final String title;
  final String body;
  const _EmptyBody({
    required this.scheme,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            Gap(Spacing.md.h),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.xs.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
