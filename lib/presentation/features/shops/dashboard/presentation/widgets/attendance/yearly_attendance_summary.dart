// lib/features/dashboard/presentation/widgets/yearly_attendance_summary.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';

class YearlyAttendanceSummary extends ConsumerStatefulWidget {
  final String shopId;
  final int year;

  const YearlyAttendanceSummary({
    super.key,
    required this.shopId,
    required this.year,
  });

  @override
  ConsumerState<YearlyAttendanceSummary> createState() =>
      _YearlyAttendanceSummaryState();
}

class _YearlyAttendanceSummaryState
    extends ConsumerState<YearlyAttendanceSummary>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _workers = [];
  Map<String, Map<int, int>> _yearlyAttendance = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final workersRepo = ref.read(dashboardRepositoryProvider);
      final workers = await workersRepo.getWorkers(shopId: widget.shopId);

      setState(() {
        _workers = workers.map((w) => ({'id': w.id, 'name': w.name})).toList();
      });

      // Get yearly attendance for each worker
      final attendanceRepo = ref.read(dashboardRepositoryProvider);

      for (final worker in _workers) {
        final yearlyData = <int, int>{};

        for (int month = 1; month <= 12; month++) {
          final startDate = DateTime(widget.year, month, 1);
          final endDate = DateTime(widget.year, month + 1, 0);

          final attendance = await attendanceRepo.getWorkerAttendanceHistory(
            workerId: worker['id'],
            startDate: startDate,
            endDate: endDate,
          );

          yearlyData[month] = attendance.length;
        }

        _yearlyAttendance[worker['id']] = yearlyData;
      }
    } catch (e) {
      print('Error loading yearly attendance: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(Spacing.md),
        child: ShopSchimmerSkeleton(height: 250.h),
      );
    }

    if (_workers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64.w,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            Gap(Spacing.md.h),
            Text(
              'No attendance data available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header row
            Container(
              color: colorScheme.surfaceVariant,
              child: Row(
                children: [
                  Container(
                    width: 120.w,
                    padding: EdgeInsets.all(Spacing.sm.h),
                    child: Text(
                      'Worker',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  ...List.generate(12, (index) {
                    return Container(
                      width: 60.w,
                      padding: EdgeInsets.all(Spacing.sm.h),
                      alignment: Alignment.center,
                      child: Text(
                        _getMonthName(index + 1),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }),
                  Container(
                    width: 70.w,
                    padding: EdgeInsets.all(Spacing.sm.h),
                    alignment: Alignment.center,
                    child: Text(
                      'Total',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Worker rows
            ..._workers.map((worker) {
              final yearlyData = _yearlyAttendance[worker['id']] ?? {};
              final total = yearlyData.values.fold<int>(0, (sum, v) => sum + v);

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 120.w,
                      padding: EdgeInsets.all(Spacing.sm.h),
                      child: Text(
                        worker['name'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...List.generate(12, (month) {
                      final days = yearlyData[month + 1] ?? 0;
                      return Container(
                        width: 60.w,
                        padding: EdgeInsets.all(Spacing.sm.h),
                        alignment: Alignment.center,
                        child: Text(
                          days.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      );
                    }),
                    Container(
                      width: 70.w,
                      padding: EdgeInsets.all(Spacing.sm.h),
                      alignment: Alignment.center,
                      child: Text(
                        total.toString(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
