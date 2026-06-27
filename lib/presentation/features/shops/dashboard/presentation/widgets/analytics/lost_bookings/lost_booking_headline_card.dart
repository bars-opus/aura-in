// lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_headline_card.dart
//
// Analytics > Revenue headline card showing combined cancel + no-show
// rate for the last 7 days, 12-week sparkline trend, period delta, and
// lost-revenue figure.
//
// States:
//   * Skeleton — first load, `state.summary == null && state.isLoading`
//   * Empty   — `summary.currentRate == null` (no terminal bookings yet)
//   * Healthy — rate <= 7%; primary colour
//   * Watch   — 7% < rate <= 12%; amber border
//   * Hot     — rate > 12%; error border + advisory chip
//
// Tapping the card opens [LostBookingDrilldownSheet] via
// BottomSheetUtils.showDocumentationBottomSheet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_drilldown_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_sparkline.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class LostBookingHeadlineCard extends ConsumerWidget {
  final String shopId;
  final String shopCurrencyCode;

  const LostBookingHeadlineCard({
    super.key,
    required this.shopId,
    required this.shopCurrencyCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      lostBookingsControllerProviderFamily(LostBookingsParams(shopId: shopId)),
    );

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Skeleton — first load, no data yet.
    if (state.summary == null && state.isLoading) {
      return _SkeletonCard(scheme: scheme);
    }

    final summary = state.summary;
    if (summary == null) {
      // Hard failure (every RPC threw). Render a quiet empty card.
      return _EmptyCard(
        scheme: scheme,
        title: 'Lost bookings · last 7 days',
        body: "Couldn't load. Pull to refresh.",
      );
    }

    final rate = summary.currentRate;
    final severity = LostBookingThresholds.classify(rate);
    final accent = _severityAccent(scheme, severity);

    // Empty (no terminal bookings yet) — distinct from a hard failure.
    if (rate == null) {
      return _EmptyCard(
        scheme: scheme,
        title: 'Lost bookings · last 7 days',
        body: 'No completed or lost bookings in the last 7 days yet.',
      );
    }

    final pctText = '${(rate * 100).toStringAsFixed(1)} %';
    final delta = summary.rateDelta;
    final deltaText = _formatDelta(delta);
    final deltaUp = (delta ?? 0) > 0;
    final lostCount = summary.current.cancelled + summary.current.noShow;
    final subText = '$lostCount of ${summary.current.total}';
    final lostRevText =
        '${formatMajorMoney(summary.current.lostRevenue, shopCurrencyCode, fractionDigits: 0)} lost revenue';

    final semantics =
        'Lost-booking rate $pctText, $subText bookings. '
        '${deltaText ?? "No comparison."} Tap for breakdown.';

    final card = CardInkWell(
      onTap: () => _openDrilldown(context, shopId),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lost bookings · last 7 days',
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Big rate text.
                Text(
                  pctText,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const Spacer(),
                if (deltaText != null)
                  _DeltaChip(text: deltaText, up: deltaUp, scheme: scheme),
              ],
            ),
            Gap(Spacing.xs.h),
            Row(
              children: [
                Text(
                  subText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  'vs prev 7 days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Gap(Spacing.sm.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LostBookingSparkline(weeks: state.weeks),
                const Spacer(),
                Text(
                  lostRevText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (severity == LostBookingSeverity.hot) ...[
              Gap(Spacing.sm.h),
              _HotAdvisoryChip(scheme: scheme),
            ],
          ],
        ),
      ),
    );

    final shouldOutline = severity != LostBookingSeverity.healthy;

    return Semantics(
      container: true,
      label: semantics,
      button: true,
      child:
          shouldOutline
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BorderRadiusTokens.md),
                  border: Border.all(color: accent, width: 1.5),
                ),
                child: card,
              )
              : card,
    );
  }

  static Color _severityAccent(ColorScheme scheme, LostBookingSeverity s) {
    switch (s) {
      case LostBookingSeverity.healthy:
        return scheme.primary;
      case LostBookingSeverity.watch:
        return const Color(0xFFFFB020); // Material 3 amber 600
      case LostBookingSeverity.hot:
        return scheme.error;
    }
  }

  /// Returns null when delta is undefined. Otherwise like "▲ +3.1 pp"
  /// or "▼ -1.2 pp".
  static String? _formatDelta(double? delta) {
    if (delta == null) return null;
    final pp = (delta * 100);
    final abs = pp.abs().toStringAsFixed(1);
    if (pp > 0.05) return '▲ +$abs pp';
    if (pp < -0.05) return '▼ -$abs pp';
    return '— flat';
  }

  static void _openDrilldown(BuildContext context, String shopId) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: LostBookingDrilldownSheet(shopId: shopId),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String text;
  final bool up;
  final ColorScheme scheme;

  const _DeltaChip({
    required this.text,
    required this.up,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    // Rising lost-rate is bad; falling is good. So `up == true` → error-ish.
    final color =
        text.startsWith('—')
            ? scheme.onSurfaceVariant
            : (up ? scheme.error : scheme.primary);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(BorderRadiusTokens.sm),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HotAdvisoryChip extends StatelessWidget {
  final ColorScheme scheme;
  const _HotAdvisoryChip({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(BorderRadiusTokens.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.error, size: 16),
          const Gap(Spacing.xs),
          Expanded(
            child: Text(
              'Consider a deposit policy or reminder cadence review '
              '(combined cancel + no-show rate).',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final ColorScheme scheme;
  const _SkeletonCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return CardInkWell(
      onTap: () {}, // no-op while loading
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: SizedBox(
          height: 120.h,
          child: Center(
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final ColorScheme scheme;
  final String title;
  final String body;
  const _EmptyCard({
    required this.scheme,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CardInkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            Text(
              body,
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
