// lib/features/dashboard/presentation/screens/worker_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_profile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/attendance_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/attendance/worker_attendance_list.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/attendance/attendance_summary_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class WorkerDetailScreen extends ConsumerStatefulWidget {
  final String shopId;
  final WorkerProfile worker;

  const WorkerDetailScreen({
    super.key,
    required this.shopId,
    required this.worker,
  });

  @override
  ConsumerState<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends ConsumerState<WorkerDetailScreen>
    with SingleTickerProviderStateMixin {


      
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load attendance data when screen loads
    Future.microtask(() {
      ref
          .read(
            attendanceControllerProviderFamily(
              AttendanceParams(shopId: widget.shopId),
            ).notifier,
          )
          .loadWorkerData(workerId: widget.worker.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onEdit() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder:
    //         (context) => AddEditWorkerScreen(
    //           shopId: widget.shopId,
    //           worker: widget.worker,
    //         ),
    //   ),
    // ).then(
    //   (_) =>
    //       ref
    //           .read(
    //             workerManagementControllerProviderFamily(
    //               WorkerManagementParams(shopId: widget.shopId),
    //             ).notifier,
    //           )
    //           .refreshWithAttendance(),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final attendanceState = ref.watch(
      attendanceControllerProviderFamily(
        AttendanceParams(shopId: widget.shopId),
      ),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          title: Text(
            widget.worker.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: _onEdit,
              icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Performance'),
              Tab(text: 'Attendance'),
            ],
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            _buildPerformanceTab(),
            _buildAttendanceTab(attendanceState),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.md.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Row(
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                    widget.worker.profileImageUrl != null
                        ? NetworkImage(widget.worker.profileImageUrl!)
                        : null,
                child:
                    widget.worker.profileImageUrl == null
                        ? Text(
                          widget.worker.name.isNotEmpty
                              ? widget.worker.name[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        )
                        : null,
              ),
              Gap(Spacing.lg.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.worker.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.worker.bio != null)
                      Text(
                        widget.worker.bio!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    Gap(Spacing.xs.h),
                    // Employment type badge
                    if (widget.worker.isShopEmployee &&
                        widget.worker.employmentType != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.xs.w,
                          vertical: Spacing.xs.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          widget.worker.employmentTypeDisplay,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Gap(Spacing.lg.h),

          // Stats row
          Row(
            children: [
              _StatBox(
                value: widget.worker.totalBookings.toString(),
                label: 'Bookings',
              ),
              _StatBox(
                value: '\$${widget.worker.totalRevenue.toStringAsFixed(0)}',
                label: 'Revenue',
              ),
              _StatBox(
                value: widget.worker.averageRating?.toStringAsFixed(1) ?? '--',
                label: 'Rating',
                suffix: widget.worker.averageRating != null ? '/5' : null,
              ),
            ],
          ),
          Gap(Spacing.lg.h),

          // Specialties
          if (widget.worker.specialties.isNotEmpty) ...[
            Text(
              'Specialties',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            Wrap(
              spacing: Spacing.sm.w,
              children:
                  widget.worker.specialties.map((specialty) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.sm.w,
                        vertical: Spacing.xs.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        specialty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.md.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance metrics
          Text(
            'Performance Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.md.h),

          Container(
            padding: EdgeInsets.all(Spacing.md.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: BorderWidthTokens.hairline,
              ),
            ),
            child: Column(
              children: [
                _PerformanceRow(
                  label: 'Total Bookings',
                  value: widget.worker.totalBookings.toString(),
                ),
                _PerformanceRow(
                  label: 'Total Revenue',
                  value: '\$${widget.worker.totalRevenue.toStringAsFixed(0)}',
                ),
                _PerformanceRow(
                  label: 'Average Rating',
                  value:
                      widget.worker.averageRating?.toStringAsFixed(1) ??
                      'No ratings',
                ),
                _PerformanceRow(
                  label: 'Total Reviews',
                  value: widget.worker.totalReviews?.toString() ?? '0',
                ),
                if (widget.worker.isShopEmployee) ...[
                  const Divider(),
                  _PerformanceRow(
                    label: 'Hourly Rate',
                    value:
                        widget.worker.hourlyRate != null
                            ? '\$${widget.worker.hourlyRate!.toStringAsFixed(2)}/hr'
                            : 'Not set',
                  ),
                  _PerformanceRow(
                    label: 'Employment Start',
                    value:
                        widget.worker.employmentStart != null
                            ? '${widget.worker.employmentStart!.month}/${widget.worker.employmentStart!.year}'
                            : 'Not set',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(AttendanceState attendanceState) {
    final theme = Theme.of(context);
    final history = attendanceState.getWorkerHistory(widget.worker.id);
    final summary = attendanceState.getWorkerSummary(widget.worker.id);

    if (attendanceState.isLoading && history.isEmpty) {
      return const Center(child: CircularLoadingIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.md.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly summary
          if (summary != null)
            AttendanceSummaryCard(
              daysWorked: summary['days_worked'] ?? 0,
              totalHours: (summary['total_hours'] ?? 0).toDouble(),
              onTimeRate: (summary['on_time_rate'] ?? 0).toDouble(),
              lateArrivals: summary['late_arrivals'] ?? 0,
            ),
          Gap(Spacing.lg.h),

          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              _MonthSelector(
                selectedMonth: attendanceState.selectedMonth,
                onMonthChanged: (month) {
                  ref
                      .read(
                        attendanceControllerProviderFamily(
                          AttendanceParams(shopId: widget.shopId),
                        ).notifier,
                      )
                      .loadWorkerData(workerId: widget.worker.id, month: month);
                },
              ),
            ],
          ),
          Gap(Spacing.md.h),

          // Attendance list
          WorkerAttendanceList(
            attendances: history,
            onItemTap: (attendance) {
              // Show attendance detail if needed
            },
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final String? suffix;

  const _StatBox({required this.value, required this.label, this.suffix});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
            width: BorderWidthTokens.hairline,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(Spacing.xs.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PerformanceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: () {
            onMonthChanged(
              DateTime(selectedMonth.year, selectedMonth.month - 1),
            );
          },
          icon: Icon(
            Icons.chevron_left,
            size: IconSizes.sm,
            color: colorScheme.onSurface,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          _formatMonth(selectedMonth),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          onPressed: () {
            onMonthChanged(
              DateTime(selectedMonth.year, selectedMonth.month + 1),
            );
          },
          icon: Icon(
            Icons.chevron_right,
            size: IconSizes.sm,
            color: colorScheme.onSurface,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  String _formatMonth(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }
}
