import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/opening_hours_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';

class OpeningHoursWidget extends StatelessWidget {
  final List<OpeningHoursDTO> openingHours;
  const OpeningHoursWidget({super.key, required this.openingHours});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = TimeOfDay.fromDateTime(now);
    final orderedHours = _buildOrderedHours(openingHours);

    final dayIcons = {
      1: FontAwesomeIcons.m, // Monday
      2: FontAwesomeIcons.t, // Tuesday
      3: FontAwesomeIcons.w, // Wednesday
      4: FontAwesomeIcons.t, // Thursday
      5: FontAwesomeIcons.f, // Friday
      6: FontAwesomeIcons.s, // Saturday
      7: FontAwesomeIcons.s, // Sunday
    };

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final todayHours = orderedHours.firstWhere(
      (hour) => hour.dayOfWeek == currentDay,
      orElse:
          () => OpeningHoursDTO(
            id: '',
            dayOfWeek: currentDay,
            opensAt: '',
            closesAt: '',
            isClosed: true,
          ),
    );
    final scheduleState = _resolveScheduleState(
      hours: orderedHours,
      currentDay: currentDay,
      currentTime: currentTime,
    );

    return ShopDetailsSection(
      title: 'Opening hours',
      seeAllOnperssed: null,
      showCard: false,
      widget: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (orderedHours.isNotEmpty) ...[
            _ScheduleStatusCard(
              title: scheduleState.title,
              subtitle: scheduleState.subtitle,
              accentColor: scheduleState.accentColor,
              icon: scheduleState.icon,
            ),
            Gap(Spacing.sm.h),
            CardInkWell(
              child: Column(
                children: [
                  ...orderedHours.map((hour) {
                    final isToday = hour.dayOfWeek == currentDay;
                    final isOpen = !hour.isClosed;

                    final openTime = _parseTimeOfDay(hour.opensAt);
                    final closeTime = _parseTimeOfDay(hour.closesAt);
                    final isCurrentlyOpen =
                        isToday && isOpen
                            ? _isCurrentlyOpen(currentTime, openTime, closeTime)
                            : false;
                    final rowStatus = _buildRowStatus(
                      hour: hour,
                      currentDay: currentDay,
                      currentTime: currentTime,
                      isCurrentlyOpen: isCurrentlyOpen,
                      todayHours: todayHours,
                      allHours: orderedHours,
                    );
                    final hasDivider =
                        hour.dayOfWeek != orderedHours.last.dayOfWeek;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: Spacing.xs.h + 2.h,
                            horizontal: Spacing.sm.w,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isToday
                                    ? colorScheme.primaryContainer.withValues(
                                      alpha: 0.38,
                                    )
                                    : colorScheme.surfaceContainerLowest
                                        .withValues(alpha: 0.35),
                            borderRadius: BorderRadiusTokens.mdAll,
                            border:
                                isToday
                                    ? Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.14,
                                      ),
                                      width: BorderWidthTokens.hairline,
                                    )
                                    : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34.w,
                                height: 34.w,
                                decoration: BoxDecoration(
                                  color:
                                      isToday
                                          ? colorScheme.primary.withValues(
                                            alpha: 0.14,
                                          )
                                          : colorScheme.surfaceContainerHigh
                                              .withValues(alpha: 0.6),
                                  borderRadius: BorderRadiusTokens.mdAll,
                                ),
                                child: Icon(
                                  dayIcons[hour.dayOfWeek] ??
                                      FontAwesomeIcons.clock,
                                  size: 14.h,
                                  color:
                                      isToday
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.75),
                                ),
                              ),
                              Gap(Spacing.sm.w - 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dayNames[hour.dayOfWeek - 1],
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight:
                                                isToday
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                            color:
                                                isToday
                                                    ? colorScheme.onSurface
                                                    : colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(
                                                          alpha: 0.82,
                                                        ),
                                          ),
                                    ),
                                    Gap(2.h),
                                    Text(
                                      isOpen
                                          ? '${_formatTime12Hour(hour.opensAt)} - ${_formatTime12Hour(hour.closesAt)}'
                                          : 'Closed',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                isToday
                                                    ? colorScheme
                                                        .onSurfaceVariant
                                                    : colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(
                                                          alpha: 0.72,
                                                        ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Gap(Spacing.xs.w),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 130.w),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _OpeningHoursBadge(
                                    label: rowStatus.label,
                                    icon: rowStatus.icon,
                                    color: rowStatus.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasDivider)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: AppDivider(),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<OpeningHoursDTO> _buildOrderedHours(List<OpeningHoursDTO> hours) {
    final byDay = {for (final hour in hours) hour.dayOfWeek: hour};
    return List.generate(7, (index) {
      final day = index + 1;
      return byDay[day] ??
          OpeningHoursDTO(
            id: '',
            dayOfWeek: day,
            opensAt: '',
            closesAt: '',
            isClosed: true,
          );
    });
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    if (timeStr.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    // Check if time is in 24-hour format (contains no AM/PM and no space)
    if (!timeStr.contains('AM') && !timeStr.contains('PM')) {
      // 24-hour format like "09:00:00" or "09:00"
      final timeParts = timeStr.split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }

    // 12-hour format with AM/PM like "09:00 AM"
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final period = parts[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime12Hour(String timeStr) {
    final time = _parseTimeOfDay(timeStr);
    final hour12 = time.hour % 12;
    final displayHour = hour12 == 0 ? 12 : hour12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${displayHour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  bool _isCurrentlyOpen(TimeOfDay now, TimeOfDay open, TimeOfDay close) {
    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;

    if (closeMinutes < openMinutes) {
      return nowMinutes >= openMinutes || nowMinutes <= closeMinutes;
    }
    return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
  }

  _ScheduleState _resolveScheduleState({
    required List<OpeningHoursDTO> hours,
    required int currentDay,
    required TimeOfDay currentTime,
  }) {
    final todayHours = hours.firstWhere(
      (hour) => hour.dayOfWeek == currentDay,
      orElse:
          () => OpeningHoursDTO(
            id: '',
            dayOfWeek: currentDay,
            opensAt: '',
            closesAt: '',
            isClosed: true,
          ),
    );

    if (!todayHours.isClosed) {
      final openTime = _parseTimeOfDay(todayHours.opensAt);
      final closeTime = _parseTimeOfDay(todayHours.closesAt);
      final isCurrentlyOpen = _isCurrentlyOpen(
        currentTime,
        openTime,
        closeTime,
      );

      if (isCurrentlyOpen) {
        return _ScheduleState(
          title: 'Open now',
          subtitle: 'Closes at ${_formatTime12Hour(todayHours.closesAt)}',
          accentColor: Colors.green,
          icon: Icons.check_circle_rounded,
        );
      }

      if (currentTime.isBefore(openTime)) {
        return _ScheduleState(
          title: 'Closed now',
          subtitle: 'Opens today at ${_formatTime12Hour(todayHours.opensAt)}',
          accentColor: Colors.orange,
          icon: Icons.schedule_rounded,
        );
      }
    }

    final nextOpen = _findNextOpenSlot(
      hours: hours,
      currentDay: currentDay,
      currentTime: currentTime,
    );

    if (nextOpen == null) {
      return const _ScheduleState(
        title: 'Currently unavailable',
        subtitle: 'Opening hours are not available right now',
        accentColor: Colors.red,
        icon: Icons.lock_clock_rounded,
      );
    }

    final dayLabel =
        nextOpen.dayOffset == 0
            ? 'today'
            : nextOpen.dayOffset == 1
            ? 'tomorrow'
            : _getDayName(nextOpen.dayOfWeek);

    return _ScheduleState(
      title: 'Closed now',
      subtitle: 'Opens $dayLabel at ${_formatTime12Hour(nextOpen.opensAt)}',
      accentColor: Colors.red,
      icon: Icons.do_not_disturb_on_rounded,
    );
  }

  _OpeningHoursRowState _buildRowStatus({
    required OpeningHoursDTO hour,
    required int currentDay,
    required TimeOfDay currentTime,
    required bool isCurrentlyOpen,
    required OpeningHoursDTO todayHours,
    required List<OpeningHoursDTO> allHours,
  }) {
    if (hour.isClosed) {
      if (hour.dayOfWeek == currentDay) {
        final nextOpen = _findNextOpenSlot(
          hours: allHours,
          currentDay: currentDay,
          currentTime: currentTime,
        );
        final label =
            nextOpen == null
                ? 'Closed'
                : nextOpen.dayOffset == 1
                ? 'Opens tomorrow'
                : nextOpen.dayOffset == 0
                ? 'Opens later'
                : 'Closed';

        return _OpeningHoursRowState(
          label: label,
          icon: Icons.do_not_disturb_on_rounded,
          color: Colors.red,
        );
      }

      return _OpeningHoursRowState(
        label: 'Closed',
        icon: Icons.close_rounded,
        color: Colors.grey,
      );
    }

    if (hour.dayOfWeek == currentDay) {
      if (isCurrentlyOpen) {
        return _OpeningHoursRowState(
          label: 'Open',
          icon: Icons.check_circle_rounded,
          color: Colors.green,
        );
      }

      final openTime = _parseTimeOfDay(todayHours.opensAt);
      if (currentTime.isBefore(openTime)) {
        return _OpeningHoursRowState(
          label: 'Opens today',
          icon: Icons.schedule_rounded,
          color: Colors.orange,
        );
      }
    }

    return _OpeningHoursRowState(
      label: 'Scheduled',
      icon: Icons.calendar_today_rounded,
      color: Colors.blueGrey,
    );
  }

  _NextOpenSlot? _findNextOpenSlot({
    required List<OpeningHoursDTO> hours,
    required int currentDay,
    required TimeOfDay currentTime,
  }) {
    for (int offset = 0; offset <= 7; offset++) {
      final checkDay = ((currentDay - 1 + offset) % 7) + 1;
      final dayHours = hours.firstWhere(
        (h) => h.dayOfWeek == checkDay && !h.isClosed,
        orElse:
            () => OpeningHoursDTO(
              id: '',
              dayOfWeek: checkDay,
              opensAt: '',
              closesAt: '',
              isClosed: true,
            ),
      );

      if (dayHours.isClosed) continue;

      final openTime = _parseTimeOfDay(dayHours.opensAt);
      if (offset == 0 && !currentTime.isBefore(openTime)) continue;

      return _NextOpenSlot(
        dayOfWeek: checkDay,
        dayOffset: offset,
        opensAt: dayHours.opensAt,
      );
    }

    return null;
  }

  static String _getDayName(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dayOfWeek - 1];
  }
}

class _ScheduleStatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;

  const _ScheduleStatusCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.md.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.14),
            accentColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadiusTokens.lgAll,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: BorderWidthTokens.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadiusTokens.lgAll,
            ),
            child: Icon(icon, color: accentColor, size: 22.h),
          ),
          Gap(Spacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accentColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Gap(2.h),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                Gap(4.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningHoursBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _OpeningHoursBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BorderRadiusTokens.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.h, color: color),
          Gap(Spacing.xs.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleState {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;

  const _ScheduleState({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
  });
}

class _OpeningHoursRowState {
  final String label;
  final IconData icon;
  final Color color;

  const _OpeningHoursRowState({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _NextOpenSlot {
  final int dayOfWeek;
  final int dayOffset;
  final String opensAt;

  const _NextOpenSlot({
    required this.dayOfWeek,
    required this.dayOffset,
    required this.opensAt,
  });
}
