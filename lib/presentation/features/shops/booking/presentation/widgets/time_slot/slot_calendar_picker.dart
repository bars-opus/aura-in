// lib/features/booking/presentation/widgets/time_slot/slot_calendar_picker.dart
import 'package:intl/intl.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// A beautiful calendar picker for selecting appointment dates.
///
/// Displays a scrollable list of dates with availability indicators.
/// Similar to your existing calendar picker but enhanced for booking flow.
///
/// ## Features
/// - Horizontal scrollable date chips
/// - Visual indicators for days with availability
/// - Disabled dates (past dates, closed days)
/// - Today highlighting
/// - Month headers for context
///
/// ## Usage
/// ```dart
/// SlotCalendarPicker(
///   selectedDate: selectedDate,
///   onDateSelected: (date) => selectDate(date),
///   availabilityMap: availabilityMap, // Map of dates with available slots
/// )
/// ```
class SlotCalendarPicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Map<DateTime, bool>? availabilityMap;
  final int daysToShow;

  const SlotCalendarPicker({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    this.availabilityMap,
    this.daysToShow = 14, // Show 14 days by default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(
      daysToShow,
      (index) => DateTime(today.year, today.month, today.day + index),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month headers (group dates by month)
        _buildSelectedDateHeader(context, selectedDate),
        Gap(5.h),
        // Date chips
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _isSameDay(date, selectedDate);
              final isAvailable = availabilityMap?[date] ?? true;
              final isPast = _isPastDate(date);
              final isToday = _isSameDay(date, today);

              return Padding(
                padding: EdgeInsets.only(right: Spacing.sm.w),
                child: _DateChip(
                  date: date,
                  isSelected: isSelected,
                  isAvailable: isAvailable && !isPast,
                  isPast: isPast,
                  isToday: isToday,
                  onTap: () {
                    if (!isPast && isAvailable) {
                      onDateSelected(date);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDateHeader(BuildContext context, DateTime selectedDate) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, Spacing.sm.h, Spacing.md.w, Spacing.xs.h),
      child: Text(
        DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isPastDate(DateTime date) {
    final today = DateTime.now();
    return date.year < today.year ||
        (date.year == today.year && date.month < today.month) ||
        (date.year == today.year &&
            date.month == today.month &&
            date.day < today.day);
  }
}

/// Internal date chip widget
class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isAvailable;
  final bool isPast;
  final bool isToday;
  final VoidCallback onTap;

  const _DateChip({
    Key? key,
    required this.date,
    required this.isSelected,
    required this.isAvailable,
    required this.isPast,
    required this.isToday,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    var _selectedColor =
        isSelected ? colorScheme.primary : colorScheme.surfaceVariant;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Opacity(
          opacity: isPast ? 0.3 : 1.0,
          child: CardInkWell(
            elevation: .5,
            color: _selectedColor,
            padding: const EdgeInsets.all(0),
            onTap: isAvailable && !isPast ? onTap : null,
            child: Container(
              width: 60.w,
              padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                    ),
                  ),

                  if (!isAvailable && !isPast)
                    Icon(
                      Icons.close,
                      size: IconSizes.xs.w,
                      color: colorScheme.error,
                    ),
                ],
              ),
            ),
          ),
        ),
        // if (isToday && !isSelected)
        //   Text(
        //     'Today',
        //     style: theme.textTheme.labelSmall?.copyWith(
        //       color: colorScheme.onBackground,
        //       fontSize: 8.sp,
        //     ),
        //   ),
        Text(
          isToday ? 'Today' : _getDayAbbreviation(date),
          style: theme.textTheme.labelSmall?.copyWith(
            color: isSelected ? colorScheme.primary : colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  String _getDayAbbreviation(DateTime date) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[date.weekday - 1];
  }
}
