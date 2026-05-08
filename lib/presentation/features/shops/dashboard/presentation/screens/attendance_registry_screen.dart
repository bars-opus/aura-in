// lib/features/dashboard/presentation/screens/attendance_registry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/attendance/attendance_calendar.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/month_selector.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/attendance/yearly_attendance_summary.dart';

class AttendanceRegistryScreen extends ConsumerStatefulWidget {
  final String shopId;

  const AttendanceRegistryScreen({super.key, required this.shopId});

  @override
  ConsumerState<AttendanceRegistryScreen> createState() =>
      _AttendanceRegistryScreenState();
}

class _AttendanceRegistryScreenState
    extends ConsumerState<AttendanceRegistryScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedMonth = DateTime.now();
  RegistryView _currentView = RegistryView.monthly;

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,

      body: Column(
        children: [
          Gap(Spacing.xl),
          SegmentedButton<RegistryView>(
            segments: const [
              ButtonSegment(
                value: RegistryView.monthly,
                label: Text('Monthly'),
              ),
              ButtonSegment(value: RegistryView.yearly, label: Text('Yearly')),
            ],
            selected: {_currentView},
            onSelectionChanged: (Set<RegistryView> selection) {
              setState(() {
                _currentView = selection.first;
              });
            },
            style: ButtonStyle(
              // Decrease height
              maximumSize: WidgetStateProperty.all(Size(150.w, 30.h)),
              // Adjust font size
              textStyle: WidgetStateProperty.all(
                textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              side: WidgetStateProperty.all(
                BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: 0.2, // Very thin border
                ),
              ),
              // Adjust padding
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              ),
            ),
          ),
          Gap(Spacing.md),
          if (_currentView == RegistryView.monthly) ...[
            MonthSelector(
              selectedMonth: _selectedMonth,
              onMonthChanged: (month) {
                setState(() {
                  _selectedMonth = month;
                });
              },
            ),
            Expanded(
              child: AttendanceCalendar(
                shopId: widget.shopId,
                month: _selectedMonth,
              ),
            ),
          ] else ...[
            Expanded(
              child: YearlyAttendanceSummary(
                shopId: widget.shopId,
                year: _selectedMonth.year,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum RegistryView { monthly, yearly }
