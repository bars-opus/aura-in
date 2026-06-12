// lib/presentation/features/shops/dashboard/presentation/screens/daily_report_history_screen.dart
//
// Phase 16 — Owner-facing history list of daily reports.
//
// ConsumerStatefulWidget so we own the keyset cursor. First page comes
// from `dailyReportHistoryProvider`; subsequent pages are fetched
// directly from the repo via `listDailyReports(beforeDate: ...)`.
//
// Tap a row → push `DailyReportScreen(shopId, reportDate)`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/daily_report_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/daily_report_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/daily_report_provider.dart';

class DailyReportHistoryScreen extends ConsumerStatefulWidget {
  final String shopId;

  const DailyReportHistoryScreen({super.key, required this.shopId});

  @override
  ConsumerState<DailyReportHistoryScreen> createState() =>
      _DailyReportHistoryScreenState();
}

class _DailyReportHistoryScreenState
    extends ConsumerState<DailyReportHistoryScreen> {
  static const int _pageSize = 30;
  static const double _loadMoreThreshold = 200.0;

  final ScrollController _controller = ScrollController();
  final List<DailyReportSummaryDTO> _extra = [];
  DateTime? _cursor;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    if (!_hasMore || _loadingMore) return;
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - _loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_cursor == null) return;
    setState(() => _loadingMore = true);
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final page = await repo.listDailyReports(
        shopId: widget.shopId,
        beforeDate: _cursor,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _extra.addAll(page);
        _cursor = page.isEmpty ? _cursor : page.last.reportDate;
        _hasMore = page.length == _pageSize;
        _loadingMore = false;
      });
    } on DailyReportException catch (e) {
      AppLogger.warn(
        'daily_report.history_load_more_failed',
        fields: {'shop_id': widget.shopId, 'code': e.code},
      );
      if (mounted) setState(() => _loadingMore = false);
    } catch (e) {
      AppLogger.warn(
        'daily_report.history_load_more_failed',
        fields: {'shop_id': widget.shopId, 'error': e.toString()},
      );
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _extra.clear();
      _cursor = null;
      _hasMore = true;
    });
    ref.invalidate(dailyReportHistoryProvider(widget.shopId));
    await ref.read(dailyReportHistoryProvider(widget.shopId).future);
  }

  void _openDay(BuildContext context, DateTime reportDate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DailyReportScreen(
          shopId: widget.shopId,
          reportDate: reportDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final firstPage = ref.watch(dailyReportHistoryProvider(widget.shopId));

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          loc.dailyReportHistoryTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: firstPage.when(
          loading: () => const Center(child: CircularLoadingIndicator()),
          error: (e, _) {
            final msg = e is DailyReportException
                ? e.userMessage
                : loc.dailyReportHistoryLoadFailed;
            return _ErrorState(
              message: msg,
              retryLabel: loc.dailyReportRetry,
              onRetry: _refresh,
            );
          },
          data: (first) {
            // Seed cursor on first successful page so _loadMore knows where
            // to start. Only do this once per provider value.
            if (_cursor == null && first.isNotEmpty) {
              _cursor = first.last.reportDate;
              _hasMore = first.length == _pageSize;
            }
            final rows = [...first, ..._extra];
            if (rows.isEmpty) {
              return _EmptyState();
            }
            return ListView.separated(
              controller: _controller,
              padding: EdgeInsets.fromLTRB(
                Spacing.md.w,
                Spacing.md.h,
                Spacing.md.w,
                Spacing.xl.h,
              ),
              itemCount: rows.length + (_loadingMore ? 1 : 0),
              separatorBuilder: (_, __) => Gap(Spacing.sm.h),
              itemBuilder: (context, i) {
                if (i >= rows.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final row = rows[i];
                return _HistoryRow(
                  row: row,
                  onTap: () => _openDay(context, row.reportDate),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final DailyReportSummaryDTO row;
  final VoidCallback onTap;

  const _HistoryRow({required this.row, required this.onTap});

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(Spacing.md.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(row.reportDate),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    row.formattedRevenue(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
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
          Icons.history,
          size: 64.w,
          color: scheme.onSurface.withOpacity(0.3),
        ),
        Gap(Spacing.md.h),
        Text(
          loc.dailyReportHistoryEmpty,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
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
