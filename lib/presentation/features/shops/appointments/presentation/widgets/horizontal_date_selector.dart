import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';

class HorizontalDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool Function(DateTime)? getLoadingState;

  const HorizontalDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.getLoadingState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Generate dates: today + next 14 days
    final today = DateTime.now();
    final dates = List.generate(15, (index) {
      return today.add(Duration(days: index));
    });

    return Padding(
      padding: EdgeInsets.only(top: Spacing.xs.h),
      child: SizedBox(
        height: 120.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            final isSelected =
                date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;
            final isLoading = getLoadingState?.call(date) ?? false;

            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap(Spacing.sm.h),
                    !isSelected
                        ? Text(
                          _getDayOfWeek(date),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color:
                                isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                        : Container(
                          width: 6.w,
                          height: 6.h,
                          // margin: EdgeInsets.only(top: 10.h),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                          ),
                        ),
                    Gap(Spacing.sm.h),
                    CardInkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      elevation: 0,
                      borderWidth: 1,
                      margin: EdgeInsets.symmetric(horizontal: Spacing.xs.w),
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.surface,
                      padding: const EdgeInsets.all(0),
                      onTap: () => onDateSelected(date),
                      child: SizedBox(
                        width: isSelected ? 60 : 50.w,
                        height: isSelected ? 60 : 50.h,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gap(Spacing.xs.h),
                            Text(
                              '${date.day}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: isSelected ? 24.sp : 16.sp,
                                color:
                                    isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gap(Spacing.xs.h),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: Spacing.sm.h),
                        child: CircularLoadingIndicator(),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(top: Spacing.xs.h),
                        child: Text(
                          'Today',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 12.sp,
                            color:
                                _isToday(date)
                                    ? colorScheme.primary
                                    : Colors.transparent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }
}
