import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';

class CalendarMonthView extends ConsumerWidget {
  final DateTime focusedMonth;
  final bool isShopOwner;
  final bool isCurrentUser;
  final String currentUserId;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onMonthChanged;

  const CalendarMonthView({
    super.key,
    required this.focusedMonth,
    required this.onDaySelected,
    required this.isCurrentUser,
    required this.onMonthChanged,
    required this.currentUserId,
    required this.isShopOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ✅ Only fetch data if isCurrentUser is true
    final state =
        isCurrentUser
            ? ref.watch(
              calendarControllerProvider(
                userIdOrShopId: currentUserId,
                isShopOwner: isShopOwner,
              ),
            )
            : null; // No data fetching for other users

    // Build events from state (only if we have data)
    final events = <DateTime, List<dynamic>>{};
    if (isCurrentUser && state != null && state.hasValue) {
      final calendarState = state.value!;
      for (final booking in calendarState.bookings) {
        final date = DateTime.utc(
          booking.startTime.year,
          booking.startTime.month,
          booking.startTime.day,
        );
        events.putIfAbsent(date, () => []).add(booking);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Listener(
        onPointerMove: (event) {
          if (event.delta.dy.abs() > event.delta.dx.abs()) {
            // Allow parent to scroll
          }
        },
        behavior: HitTestBehavior.opaque,
        child: TableCalendar(
          rowHeight: 40.h,
          daysOfWeekHeight: 25.h,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedMonth,
          pageAnimationCurve: Curves.easeInOut,
          availableGestures: AvailableGestures.horizontalSwipe,
          selectedDayPredicate: (day) => false,
          onDaySelected: (selectedDay, focusedDay) {
            onDaySelected(selectedDay);
          },
          onPageChanged: (focusedDay) {
            HapticFeedback.lightImpact();
            onMonthChanged(focusedDay);
          },
          eventLoader: (day) {
            final normalizedDay = DateTime.utc(day.year, day.month, day.day);
            return events[normalizedDay] ?? [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, _) {
              final normalizedDate = DateTime.utc(
                date.year,
                date.month,
                date.day,
              );
              final dayEvents = events[normalizedDate] ?? [];
              if (dayEvents.isEmpty) return const SizedBox();

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children:
                    dayEvents.take(3).map((event) {
                      final statusColor = _getStatusColor(
                        event.status,
                        colorScheme,
                      );

                      return AnimatedScaleFade(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        child: Container(
                          width: 12.h,
                          height: 12.w,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrentUser ? statusColor : Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onBackground,
            ),
            cellMargin: EdgeInsets.all(0),
            todayDecoration: BoxDecoration(
              color: colorScheme.onBackground.withOpacity(.2),
              shape: BoxShape.circle,
            ),
            markersMaxCount: 0,
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onBackground,
            ),
            headerMargin: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20),
            titleCentered: false,
            leftChevronVisible: false,
            rightChevronVisible: false,
            formatButtonVisible: false,
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: colorScheme.primary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  /// Get color based on booking status
  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return colorScheme.info;
      case 'pending':
        return colorScheme.primary;
      case 'completed':
        return colorScheme.success;
      case 'cancelled':
        return colorScheme.error;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
