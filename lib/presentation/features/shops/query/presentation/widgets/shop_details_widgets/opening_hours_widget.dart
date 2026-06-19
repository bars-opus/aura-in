import 'dart:async';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/opening_hours_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';

class OpeningHoursWidget extends StatefulWidget {
  final List<OpeningHoursDTO> openingHours;
  const OpeningHoursWidget({super.key, required this.openingHours});

  @override
  State<OpeningHoursWidget> createState() => _OpeningHoursWidgetState();
}

class _OpeningHoursWidgetState extends State<OpeningHoursWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = TimeOfDay.fromDateTime(now);

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

    return ShopDetailsSection(
      title: 'Opening hours',
      seeAllOnperssed: null,
      widget: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.openingHours.isNotEmpty) ...[
            ...widget.openingHours.map((hour) {
              final isToday = hour.dayOfWeek == currentDay;
              final isOpen = !hour.isClosed;

              final openTime = _parseTimeOfDay(hour.opensAt);
              final closeTime = _parseTimeOfDay(hour.closesAt);

              // // Calculate duration for this day
              // final duration = _calculateDuration(openTime, closeTime);
              // final durationText = _formatDuration(duration);

              // Build subtitle with day name and duration
              final subtitleText =
                  isOpen
                      ? dayNames[hour.dayOfWeek - 1]
                      : dayNames[hour.dayOfWeek - 1];

              // Determine if currently open
              bool isCurrentlyOpen = false;
              Duration? timeUntilClose;
              Duration? timeUntilOpen;

              if (isToday && isOpen) {
                isCurrentlyOpen = _isCurrentlyOpen(
                  currentTime,
                  openTime,
                  closeTime,
                );
                if (isCurrentlyOpen) {
                  timeUntilClose = _getTimeUntil(currentTime, closeTime);
                } else if (currentTime.isBefore(openTime)) {
                  timeUntilOpen = _getTimeUntil(currentTime, openTime);
                }
              } else if (isToday && !isOpen) {
                timeUntilOpen = _getTimeUntilNextOpen(
                  widget.openingHours,
                  currentDay,
                  currentTime,
                );
              } else if (!isToday && isOpen && currentTime.isAfter(closeTime)) {
                timeUntilOpen = _getTimeUntilNextOpen(
                  widget.openingHours,
                  currentDay,
                  currentTime,
                );
              }

              // Determine if there's anything to show in the bottom row
              final hasDetailedChips =
                  (isToday &&
                      isOpen &&
                      (isCurrentlyOpen && timeUntilClose != null)) ||
                  (isToday &&
                      isOpen &&
                      (!isCurrentlyOpen && timeUntilOpen != null)) ||
                  (isToday && !isOpen && timeUntilOpen != null);

              final hasStatusChips =
                  (isToday && isOpen && isCurrentlyOpen) ||
                  (isToday && !isOpen) ||
                  (!isToday &&
                      timeUntilOpen != null &&
                      timeUntilOpen.inDays <= 7);

              final hasDivider =
                  hour.dayOfWeek != widget.openingHours.last.dayOfWeek;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // InfoRowWidget with trailing chips
                  InfoRowWidget(
                    subtitle: subtitleText,
                    title:
                        isOpen
                            ? '${_formatTime12Hour(hour.opensAt)} - ${_formatTime12Hour(hour.closesAt)}'
                            : 'Closed',
                    icon: dayIcons[hour.dayOfWeek] ?? FontAwesomeIcons.clock,
                    iconSize: 20.h,
                    onTap: () {},
                    showAvatar: false,
                    showTrailingArrow: false,
                    showDivider: false,
                    trailing: const SizedBox.shrink(),
                  ),

                  // Only show the Row if there's content to display
                  if (hasDetailedChips || hasStatusChips)
                    Padding(
                      padding: EdgeInsets.only(left: Spacing.xl),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Detailed chips below the InfoRowWidget
                          if (isToday && isOpen) ...[
                            if (isCurrentlyOpen && timeUntilClose != null)
                              _buildCountdownChip(
                                duration: timeUntilClose,
                                label: 'Closes in',
                                color: Colors.red,
                              ),
                            if (!isCurrentlyOpen && timeUntilOpen != null)
                              _buildCountdownChip(
                                duration: timeUntilOpen,
                                label: 'Opens in',
                                color: Colors.orange,
                              ),
                          ] else if (isToday &&
                              !isOpen &&
                              timeUntilOpen != null) ...[
                            _buildCountdownChip(
                              duration: timeUntilOpen,
                              label: 'Opens in',
                              color: Colors.orange,
                            ),
                          ],

                          // Today's status chips
                          if (isToday && isOpen && isCurrentlyOpen)
                            _buildStatusChip(
                              icon: Icons.check_circle,
                              label: 'Open',
                              color: Colors.green,
                            ),
                          if (isToday && !isOpen)
                            _buildStatusChip(
                              icon: Icons.close,
                              label: 'Closed today',
                              color: Colors.red,
                            ),
                          if (!isToday &&
                              timeUntilOpen != null &&
                              timeUntilOpen.inDays <= 7)
                            _buildCountdownChip(
                              duration: timeUntilOpen,
                              label: _getShortDayName(hour.dayOfWeek),
                              color: Colors.blue,
                            ),
                        ],
                      ),
                    ),

                  // Optional divider between days
                  if (hasDivider)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                      child: AppDivider(),
                    ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Duration _calculateDuration(TimeOfDay open, TimeOfDay close) {
    int openMinutes = open.hour * 60 + open.minute;
    int closeMinutes = close.hour * 60 + close.minute;

    if (closeMinutes < openMinutes) {
      // Passes midnight (e.g., open 9 PM to 2 AM)
      closeMinutes += 24 * 60;
    }

    return Duration(minutes: closeMinutes - openMinutes);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.xs.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownChip({
    required Duration duration,
    required String label,
    required Color color,
  }) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    String timeString;
    if (hours > 0) {
      timeString = '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      timeString = '${minutes}m ${seconds}s';
    } else {
      timeString = '${seconds}s';
    }

    return MiniContainerIndicator(
      color: color,
      fontSize: 10,
      text: '$label $timeString',
    );
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
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

  Duration _getTimeUntil(TimeOfDay from, TimeOfDay to) {
    int fromMinutes = from.hour * 60 + from.minute;
    int toMinutes = to.hour * 60 + to.minute;

    if (toMinutes < fromMinutes) {
      toMinutes += 24 * 60;
    }

    final diffMinutes = toMinutes - fromMinutes;
    return Duration(minutes: diffMinutes);
  }

  Duration? _getTimeUntilNextOpen(
    List<OpeningHoursDTO> hours,
    int currentDay,
    TimeOfDay currentTime,
  ) {
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

      if (!dayHours.isClosed) {
        final openTime = _parseTimeOfDay(dayHours.opensAt);
        int totalMinutes = offset * 24 * 60;

        if (offset == 0) {
          totalMinutes += _getTimeUntil(currentTime, openTime).inMinutes;
        } else {
          totalMinutes += openTime.hour * 60 + openTime.minute;
        }

        if (totalMinutes > 0) {
          return Duration(minutes: totalMinutes);
        }
      }
    }
    return null;
  }

  String _getShortDayName(int dayOfWeek) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayOfWeek - 1];
  }
}
