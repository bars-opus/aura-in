// lib/features/dashboard/presentation/widgets/attendance_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/attendance/attendance_calendar_cell.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';

class AttendanceCalendar extends ConsumerStatefulWidget {
  final String shopId;
  final DateTime month;

  const AttendanceCalendar({
    super.key,
    required this.shopId,
    required this.month,
  });

  @override
  ConsumerState<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends ConsumerState<AttendanceCalendar>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _workers = [];
  Map<String, Map<String, Map<String, dynamic>>> _attendanceData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(AttendanceCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get all workers
      final workersRepo = ref.read(dashboardRepositoryProvider);
      final workers = await workersRepo.getWorkers(shopId: widget.shopId);

      setState(() {
        _workers = workers.map((w) => {'id': w.id, 'name': w.name}).toList();
      });

      // Get attendance for each worker for the month
      final attendanceRepo = ref.read(dashboardRepositoryProvider);
      final startDate = DateTime(widget.month.year, widget.month.month, 1);
      final endDate = DateTime(widget.month.year, widget.month.month + 1, 0);

      for (final worker in _workers) {
        final attendance = await attendanceRepo.getWorkerAttendanceHistory(
          workerId: worker['id'],
          startDate: startDate,
          endDate: endDate,
        );

        for (final record in attendance) {
          final day = record.date.day;
          _attendanceData.putIfAbsent(worker['id'], () => {});
          _attendanceData[worker['id']]![day.toString()] = {
            'status': record.status.displayName,
            'clock_in': record.formattedClockIn,
            'clock_out': record.formattedClockOut,
            'total_hours': record.formattedTotalHours,
          };
        }
      }
    } catch (e) {
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
        child: EmptyStateWidget(
          icon: Icons.people_outline,
          title: '',
          subtitle: 'No workers found',
        ),
      );
    }

    // Get days in month
    final daysInMonth =
        DateTime(widget.month.year, widget.month.month + 1, 0).day;
    final firstDayOfWeek =
        DateTime(widget.month.year, widget.month.month, 1).weekday;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header row with days
            Container(
              color: colorScheme.surfaceVariant,
              child: Row(
                children: [
                  // Worker name column
                  Container(
                    width: 120.w,
                    padding: EdgeInsets.all(Spacing.sm.h),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Text(
                      'Worker',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Day columns
                  ...List.generate(daysInMonth, (index) {
                    final day = index + 1;
                    return Container(
                      width: 80.w,
                      padding: EdgeInsets.all(Spacing.sm.h),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            _getDayName((firstDayOfWeek + index) % 7),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            day.toString(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Worker rows
            ..._workers.map((worker) {
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
                    // Worker name column
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
                    // Attendance cells for each day
                    ...List.generate(daysInMonth, (index) {
                      final day = (index + 1).toString();
                      final attendance = _attendanceData[worker['id']]?[day];
                      return AttendanceCalendarCell(
                        day: index + 1,
                        attendance: attendance,
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getDayName(int index) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index % 7];
  }
}
