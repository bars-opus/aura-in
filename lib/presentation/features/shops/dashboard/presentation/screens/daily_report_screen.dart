// lib/presentation/features/shops/dashboard/presentation/screens/daily_report_screen.dart
//
// Phase 16 — Owner-facing daily close-out report.
//
// Read-only ConsumerWidget. Six sections per SPEC §Outcome:
//   1. Headline      — big revenue + 4 status chips
//   2. Comparison    — vs yesterday, vs same-day-last-week (em-dash on null)
//   3. Per-worker    — list of staff + revenue + count
//   4. Per-service   — list of services + revenue + count
//   5. Tomorrow      — first booking, count, group flag
//   6. Follow-ups    — confirmed_past_end / unpaid_balance / no_show_no_action
//
// Re-generate FAB → confirm dialog → repo.regenerateDailyReport → invalidate.
// Wave 5 swaps the hard-coded EN strings for AppLocalizations getters.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/daily_report_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/daily_report_provider.dart';

class DailyReportScreen extends ConsumerWidget {
  final String shopId;
  final DateTime reportDate;

  const DailyReportScreen({
    super.key,
    required this.shopId,
    required this.reportDate,
  });

  Future<void> _regenerate(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l.dailyReportRegenerateConfirmTitle),
          content: Text(l.dailyReportRegenerateConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.dailyReportRegenerateConfirmCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.dailyReportRegenerateConfirmAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    final repo = ref.read(dashboardRepositoryProvider);
    try {
      await repo.regenerateDailyReport(
        shopId: shopId,
        reportDate: reportDate,
      );
      ref.invalidate(dailyReportProvider(
        DailyReportKey(shopId: shopId, reportDate: reportDate),
      ));
      if (!context.mounted) return;
      Snackbar.success(context, loc.dailyReportRegenerated);
    } on DailyReportException catch (e) {
      AppLogger.warn(
        'daily_report.regenerate_failed',
        fields: {'shop_id': shopId, 'code': e.code},
      );
      if (!context.mounted) return;
      Snackbar.error(context, e.userMessage);
    } catch (e) {
      AppLogger.warn(
        'daily_report.regenerate_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      if (!context.mounted) return;
      Snackbar.error(context, loc.dailyReportErrorGeneric);
    }
  }

  String _formatDateHeader(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final key = DailyReportKey(shopId: shopId, reportDate: reportDate);
    final reportAsync = ref.watch(dailyReportProvider(key));

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          loc.dailyReportTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: loc.dailyReportRefresh,
            onPressed: () => ref.invalidate(dailyReportProvider(key)),
            icon: Icon(Icons.refresh, color: scheme.onSurface),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _regenerate(context, ref),
        icon: const Icon(Icons.autorenew),
        label: Text(loc.dailyReportRegenerate),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyReportProvider(key));
          await ref.read(dailyReportProvider(key).future);
        },
        child: reportAsync.when(
          loading: () => const Center(child: CircularLoadingIndicator()),
          error: (e, _) {
            final msg = e is DailyReportException
                ? e.userMessage
                : loc.dailyReportLoadFailed;
            return _ErrorState(
              message: msg,
              retryLabel: loc.dailyReportRetry,
              onRetry: () => ref.invalidate(dailyReportProvider(key)),
            );
          },
          data: (report) {
            if (report == null) {
              return _EmptyState(
                date: reportDate,
                onRegenerate: () => _regenerate(context, ref),
              );
            }
            return ListView(
              padding: EdgeInsets.fromLTRB(
                Spacing.md.w,
                Spacing.md.h,
                Spacing.md.w,
                Spacing.xl.h * 2,
              ),
              children: [
                Text(
                  _formatDateHeader(report.reportDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Gap(Spacing.xs.h),
                _HeadlineSection(report: report),
                Gap(Spacing.md.h),
                _ComparisonSection(report: report),
                Gap(Spacing.md.h),
                _WorkerSection(report: report),
                Gap(Spacing.md.h),
                _ServiceSection(report: report),
                Gap(Spacing.md.h),
                _TomorrowSection(report: report),
                Gap(Spacing.md.h),
                _FollowUpsSection(report: report),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Sections ────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(Spacing.md.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            child,
          ],
        ),
      ),
    );
  }
}

class _HeadlineSection extends StatelessWidget {
  final DailyReportDTO report;
  const _HeadlineSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    return _SectionCard(
      title: loc.dailyReportRevenueLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.formattedRevenue(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          Gap(Spacing.sm.h),
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.xs.h,
            children: [
              _CountChip(
                label: loc.dailyReportBookingsCompleted,
                count: report.bookings.completed,
                tint: scheme.tertiary,
              ),
              _CountChip(
                label: loc.dailyReportBookingsNoShow,
                count: report.bookings.noShow,
                tint: scheme.error,
              ),
              _CountChip(
                label: loc.dailyReportBookingsCancelled,
                count: report.bookings.cancelled,
                tint: scheme.outline,
              ),
              if (report.bookings.confirmedPastEnd > 0)
                _CountChip(
                  label: loc.dailyReportBookingsConfirmedPastEnd,
                  count: report.bookings.confirmedPastEnd,
                  tint: scheme.error,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color tint;

  const _CountChip({
    required this.label,
    required this.count,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label · $count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: tint,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  final DailyReportDTO report;
  const _ComparisonSection({required this.report});

  String _formatDelta(int bps) {
    final sign = bps >= 0 ? '+' : '−';
    final pct = (bps.abs() / 100).toStringAsFixed(1);
    return '$sign$pct%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    Widget row(String label, int? bps) {
      final isDash = bps == null;
      final color = isDash
          ? scheme.onSurface.withOpacity(0.5)
          : (bps >= 0 ? scheme.tertiary : scheme.error);
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.xs.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Row(
              children: [
                if (!isDash)
                  Icon(
                    bps >= 0 ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: color,
                  ),
                if (!isDash) const SizedBox(width: 4),
                Text(
                  isDash ? loc.dailyReportComparisonNoData : _formatDelta(bps),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return _SectionCard(
      title: loc.dailyReportComparisonTitle,
      child: Column(
        children: [
          row(loc.dailyReportComparisonYesterday,
              report.comparisonYesterday?.deltaBps),
          row(loc.dailyReportComparisonLastWeek,
              report.comparisonSameDayLastWeek?.deltaBps),
        ],
      ),
    );
  }
}

class _WorkerSection extends StatelessWidget {
  final DailyReportDTO report;
  const _WorkerSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    if (report.perWorker.isEmpty) {
      return _SectionCard(
        title: loc.dailyReportPerWorkerTitle,
        child: Text(
          loc.dailyReportComparisonNoData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }
    return _SectionCard(
      title: loc.dailyReportPerWorkerTitle,
      child: Column(
        children: report.perWorker
            .map(
              (w) => Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.xs.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        w.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${report.currency} ${(w.revenueMinor / 100).toStringAsFixed(2)} · ${w.count}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  final DailyReportDTO report;
  const _ServiceSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    if (report.perService.isEmpty) {
      return _SectionCard(
        title: loc.dailyReportPerServiceTitle,
        child: Text(
          loc.dailyReportComparisonNoData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }
    return _SectionCard(
      title: loc.dailyReportPerServiceTitle,
      child: Column(
        children: report.perService
            .map(
              (s) => Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.xs.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        s.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${report.currency} ${(s.revenueMinor / 100).toStringAsFixed(2)} · ${s.count}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TomorrowSection extends StatelessWidget {
  final DailyReportDTO report;
  const _TomorrowSection({required this.report});

  String _formatTime(DateTime t) {
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final mm = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$mm $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final t = report.tomorrow;
    if (t.count == 0 || t.firstBookingAt == null) {
      return _SectionCard(
        title: loc.dailyReportTomorrowTitle,
        child: Text(
          loc.dailyReportTomorrowEmpty,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }
    return _SectionCard(
      title: loc.dailyReportTomorrowTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.dailyReportTomorrowFirstBookingAt(_formatTime(t.firstBookingAt!)),
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            loc.dailyReportTomorrowCount(t.count),
            style: theme.textTheme.bodyMedium,
          ),
          if (t.hasGroupBookings)
            Text(
              loc.dailyReportTomorrowGroupFlag,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _FollowUpsSection extends StatelessWidget {
  final DailyReportDTO report;
  const _FollowUpsSection({required this.report});

  String _reasonLabel(FollowUpReason r, AppLocalizations loc) {
    switch (r) {
      case FollowUpReason.confirmedPastEnd:
        return loc.dailyReportFollowUpConfirmedPastEnd;
      case FollowUpReason.unpaidBalance:
        return loc.dailyReportFollowUpUnpaidBalance;
      case FollowUpReason.noShowNoAction:
        return loc.dailyReportFollowUpNoShowNoAction;
    }
  }

  Color _reasonTint(FollowUpReason r, ColorScheme scheme) {
    switch (r) {
      case FollowUpReason.confirmedPastEnd:
      case FollowUpReason.noShowNoAction:
        return scheme.error;
      case FollowUpReason.unpaidBalance:
        return scheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    if (report.followUps.isEmpty) {
      return _SectionCard(
        title: loc.dailyReportFollowUpsTitle,
        child: Text(
          loc.dailyReportComparisonNoData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }
    return _SectionCard(
      title: loc.dailyReportFollowUpsTitle,
      child: Column(
        children: report.followUps.map((fu) {
          final tint = _reasonTint(fu.reason, scheme);
          return Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.xs.h),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: tint,
                    shape: BoxShape.circle,
                  ),
                ),
                Gap(Spacing.sm.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fu.clientNameRedacted,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _reasonLabel(fu.reason, loc),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (fu.amountMinor != null)
                  Text(
                    '${report.currency} ${(fu.amountMinor! / 100).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final DateTime date;
  final VoidCallback onRegenerate;

  const _EmptyState({required this.date, required this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: 80.h,
      ),
      children: [
        Icon(
          Icons.assessment_outlined,
          size: 64.w,
          color: scheme.onSurface.withOpacity(0.3),
        ),
        Gap(Spacing.md.h),
        Text(
          loc.dailyReportEmptyTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(Spacing.xs.h),
        Text(
          loc.dailyReportEmptyBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
          ),
        ),
        Gap(Spacing.lg.h),
        Center(
          child: ElevatedButton.icon(
            onPressed: onRegenerate,
            icon: const Icon(Icons.autorenew),
            label: Text(loc.dailyReportRegenerate),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: 80.h,
      ),
      children: [
        Icon(Icons.error_outline, size: 48.w, color: scheme.error),
        Gap(Spacing.md.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        Gap(Spacing.lg.h),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ),
      ],
    );
  }
}
