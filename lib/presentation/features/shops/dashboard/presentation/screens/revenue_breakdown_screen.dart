// lib/features/dashboard/presentation/screens/revenue_breakdown_screen.dart

import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/monthly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/weekly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/revenue_monthly_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/revenue_weekly_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

enum BreakdownType { weekly, monthly }

class RevenueBreakdownScreen extends ConsumerStatefulWidget {
  final String shopId;
  final BreakdownType initialType;

  const RevenueBreakdownScreen({
    super.key,
    required this.shopId,
    this.initialType = BreakdownType.weekly,
  });

  @override
  ConsumerState<RevenueBreakdownScreen> createState() =>
      _RevenueBreakdownScreenState();
}

class _RevenueBreakdownScreenState extends ConsumerState<RevenueBreakdownScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BreakdownType _selectedType;

  List<WeeklyRevenue> _weeklyData = [];
  List<MonthlyRevenue> _monthlyData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialType == BreakdownType.weekly ? 0 : 1,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(dashboardRepositoryProvider);

      // Load weekly data for last 12 weeks
      final weekly = await repository.getWeeklyRevenueBreakdown(
        shopId: widget.shopId,
        weeks: 12,
      );

      // Load monthly data for last 12 months
      final monthly = await repository.getMonthlyRevenueBreakdown(
        shopId: widget.shopId,
        months: 12,
      );

      setState(() {
        _weeklyData = weekly;
        _monthlyData = monthly;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AppTabItem(
        label: 'Weekly Breakdown',
        content:
            _isLoading
                ? _loading()
                : _error != null
                ? _buildErrorState()
                : _buildWeeklyBreakdown(),
      ),
      AppTabItem(
        label: 'Monthly Breakdown',
        content:
            _isLoading
                ? _loading()
                : _error != null
                ? _buildErrorState()
                : _buildMonthlyBreakdown(),
      ),
    ];

    return TabsWithContent(
      useNestedScrollMode: true,
      tabs: tabs.toList(),
      initialIndex: 0,
      scrollable: false,
      showContent: true,
    );
  }

  _loading() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: 10,
      padding: EdgeInsets.only(top: Spacing.sm.h),
      separatorBuilder: (_, __) => Gap(Spacing.sm.h),
      itemBuilder: (_, __) => ShopSchimmerSkeleton(height: 70.h),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: ErrorStateWidget(
        subtitle: 'Failed to load revenue data',
        onPrimaryAction: _loadData,
      ),
    );
  }

  Widget _buildWeeklyBreakdown() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_weeklyData.isEmpty) {
      return _buildEmptyState('No weekly revenue data available');
    }

    // Group weeks by month (based on where majority of days fall)
    final Map<String, List<WeeklyRevenue>> groupedByMonth = {};

    for (final week in _weeklyData) {
      // Determine which month has the majority of days in this week
      final dominantMonth = _getDominantMonth(week.startDate, week.endDate);
      final monthKey = '${dominantMonth.year}-${dominantMonth.month}';
      final monthName = _getMonthName(dominantMonth.month);

      groupedByMonth.putIfAbsent(monthKey, () => []).add(week);
    }

    return ListView.builder(
      itemCount: groupedByMonth.keys.length,
      itemBuilder: (context, index) {
        final monthKey = groupedByMonth.keys.elementAt(index);
        final weeks = groupedByMonth[monthKey]!;
        final year = int.parse(monthKey.split('-')[0]);
        final month = int.parse(monthKey.split('-')[1]);
        final monthName = _getMonthName(month);

        // Calculate month total
        final monthTotalRevenue = weeks.fold<double>(
          0,
          (sum, w) => sum + w.revenue,
        );
        final monthTotalBookings = weeks.fold<int>(
          0,
          (sum, w) => sum + w.bookingCount,
        );

        final isCurrentMonth = _isCurrentMonth(year, month);

        return Container(
          margin: EdgeInsets.only(bottom: Spacing.lg.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '$monthName $year',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      if (isCurrentMonth) ...[
                        Gap(Spacing.sm.w),

                        MiniContainerIndicator(
                          color: colorScheme.primary,
                          text: 'Current',
                        ),
                      ],
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${monthTotalRevenue.toStringAsFixed(0)}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '$monthTotalBookings bookings',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Gap(Spacing.sm.h),

              // Weeks in this month
              ...weeks.map((week) => RevenueWeeklyCard(week: week)),
            ],
          ),
        );
      },
    );
  }

  // Helper method to determine which month has majority of days in a week
  DateTime _getDominantMonth(DateTime startDate, DateTime endDate) {
    final daysInStartMonth = _getDaysInMonth(startDate.year, startDate.month);
    final daysInEndMonth = _getDaysInMonth(endDate.year, endDate.month);

    // Calculate days in start month vs end month
    final startMonthDays = daysInStartMonth - startDate.day + 1;
    final endMonthDays = endDate.day;

    if (startMonthDays >= endMonthDays) {
      return DateTime(startDate.year, startDate.month, 1);
    } else {
      return DateTime(endDate.year, endDate.month, 1);
    }
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  bool _isCurrentMonth(int year, int month) {
    final now = DateTime.now();
    return now.year == year && now.month == month;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildMonthlyBreakdown() {
    if (_monthlyData.isEmpty) {
      return _buildEmptyState('No monthly revenue data available');
    }

    return ListView.builder(
      itemCount: _monthlyData.length,
      itemBuilder: (context, index) {
        final month = _monthlyData[index];
        return RevenueMonthlyCard(month: month);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: EmptyStateWidget(
        subtitle: 'Complete more bookings to see revenue data',
      ),
    );
  }
}
