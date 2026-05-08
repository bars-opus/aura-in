// lib/features/shop/creation/presentation/screens/set_hours_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/hours_provider.dart';

class SetHoursScreen extends ConsumerStatefulWidget {
  const SetHoursScreen({super.key});

  @override
  ConsumerState<SetHoursScreen> createState() => _SetHoursScreenState();
}

class _SetHoursScreenState extends ConsumerState<SetHoursScreen> {
  // Master time values (12-hour format)
  String _masterOpenTime = '09:00 AM';
  String _masterCloseTime = '05:00 PM';
  bool _applyDefaultHours = false; // Toggle for default hours

  // Track which days have custom times
  final Set<int> _customDays = {};

  // Local copy of hours for UI
  List<OpeningHoursDraft> _localHours = [];

  @override
  void initState() {
    super.initState();
    _initializeLocalHours();
  }

  void _initializeLocalHours() {
    // Get current hours from provider
    final hours = ref.read(hoursProvider);
    _localHours = List.from(hours);

    // Check if any weekdays are open
    final anyWeekdayOpen = _localHours.any(
      (h) => h.dayOfWeek <= 5 && !h.isClosed,
    );

    _applyDefaultHours = anyWeekdayOpen;

    // If no hours set, keep all closed
    if (hours.isEmpty) {
      _localHours = _createAllClosedHours();
      _applyDefaultHours = false;
    } else {
      // Find the first open weekday to set master times
      final openWeekday = _localHours.firstWhere(
        (h) => h.dayOfWeek <= 5 && !h.isClosed,
        orElse:
            () => OpeningHoursDraft(
              dayOfWeek: 1,
              opensAt: '09:00 AM',
              closesAt: '05:00 PM',
              isClosed: true,
            ),
      );

      if (!openWeekday.isClosed) {
        _masterOpenTime = openWeekday.opensAt;
        _masterCloseTime = openWeekday.closesAt;
      }

      // Check for custom days
      for (final hour in _localHours) {
        if (hour.dayOfWeek <= 5 && !hour.isClosed) {
          if (hour.opensAt != _masterOpenTime ||
              hour.closesAt != _masterCloseTime) {
            _customDays.add(hour.dayOfWeek);
          }
        }
      }
    }
  }

  List<OpeningHoursDraft> _createAllClosedHours() {
    return List.generate(7, (index) {
      final day = index + 1;
      return OpeningHoursDraft(
        dayOfWeek: day,
        opensAt: '09:00 AM',
        closesAt: '05:00 PM',
        isClosed: true,
      );
    });
  }

  // ✅ This method shows the bottom sheet with the time picker
  void _showTimePickerBottomSheet({
    required bool isOpen,
    required Function(String) onSelected,
  }) {
    final initialTime = isOpen ? _masterOpenTime : _masterCloseTime;
    final initialTimeOfDay = _parseTime12Hour(initialTime);

    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 320.h,
      context: context,
      widget: Column(
        children: [
          AppTextButton(text: 'Done'),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime(
                2000,
                1,
                1,
                initialTimeOfDay.hour,
                initialTimeOfDay.minute,
              ),
              use24hFormat: false,
              onDateTimeChanged: (dateTime) {
                final period = dateTime.hour >= 12 ? 'PM' : 'AM';
                int hour12 = dateTime.hour % 12;
                if (hour12 == 0) hour12 = 12;
                final timeString =
                    '${hour12.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
                onSelected(timeString);
              },
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTime12Hour(String time) {
    // Check if time is in 24-hour format (contains no AM/PM)
    if (!time.contains('AM') && !time.contains('PM')) {
      // 24-hour format like "09:00:00" or "09:00"
      final timeParts = time.split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    }

    // 12-hour format with AM/PM like "09:00 AM"
    final parts = time.split(' ');
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

  void _applyDefaultHoursToWeekdays() {
    final updatedHours = List<OpeningHoursDraft>.from(_localHours);

    // Keep weekends and any customized weekdays
    final preservedDays =
        updatedHours.where((hour) {
          // Keep weekends
          if (hour.dayOfWeek >= 6) return true;
          // Keep weekdays that were manually customized
          return _customDays.contains(hour.dayOfWeek);
        }).toList();

    // Add the new default hours for weekdays that aren't customized
    for (int day = 1; day <= 5; day++) {
      if (!_customDays.contains(day)) {
        preservedDays.add(
          OpeningHoursDraft(
            dayOfWeek: day,
            opensAt: _masterOpenTime,
            closesAt: _masterCloseTime,
            isClosed: false,
          ),
        );
      }
    }

    setState(() {
      _localHours = preservedDays;
    });

    if (mounted) {
      ref.read(hoursProvider.notifier).setAllHours(_localHours);
    }
  }

  void _removeDefaultHours() {
    // Remove ALL days that were added by default (Mon-Fri)
    // Only keep days that were manually customized
    final filteredHours =
        _localHours.where((hour) {
          // Only keep days that are in the custom set
          return _customDays.contains(hour.dayOfWeek);
        }).toList();

    setState(() {
      _localHours = filteredHours;
      // Don't clear _customDays if we want to keep weekend customizations
    });

    if (mounted) {
      ref.read(hoursProvider.notifier).setAllHours(_localHours);
    }
  }

  // When a day is ever modified (opened, closed, times changed), mark it as set
  void _updateDay({
    required int day,
    required String opensAt,
    required String closesAt,
    required bool isClosed,
  }) {
    final index = _localHours.indexWhere((h) => h.dayOfWeek == day);
    final updatedHour = OpeningHoursDraft(
      dayOfWeek: day,
      opensAt: opensAt,
      closesAt: closesAt,
      isClosed: isClosed,
      isSet: true, // ✅ Mark as set when modified
    );

    setState(() {
      if (index >= 0) {
        _localHours[index] = updatedHour;
      } else {
        _localHours.add(updatedHour);
      }
    });

    if (mounted) {
      ref.read(hoursProvider.notifier).setAllHours(_localHours);
    }
  }

  void _applyMasterToDay(int day) {
    _updateDay(
      day: day,
      opensAt: _masterOpenTime,
      closesAt: _masterCloseTime,
      isClosed: false,
    );
    setState(() {
      _customDays.remove(day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
        child: ListView(
          children: [
            SemanticContainerWidget(
              content:
                  'Set your regular business hours. Enable default hours for Mon-Fri, or customize each day.',
              icon: Icons.schedule_sharp,
              title: 'Opening Hours',
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              borderColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              textTheme: theme.textTheme,
            ),

            Gap(Spacing.md.h),

            // Default Hours Toggle Card
            // Default Hours Toggle Card - Updated Version
            CardInkWell(
              // margin: const EdgeInsets.only(bottom: Spacing.sm),
              child: Padding(
                padding: EdgeInsets.all(Spacing.md.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Default Hours (Mon-Fri)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onBackground,
                            ),
                          ),
                        ),

                        AppToggleSwitch(
                          toggleValue: _applyDefaultHours,
                          onToggleChanged: (value) {
                            setState(() {
                              _applyDefaultHours = value;
                            });
                            if (value) {
                              _applyDefaultHoursToWeekdays();
                            } else {
                              _removeDefaultHours();
                            }
                            HapticFeedback.mediumImpact();
                          },
                        ),
                      ],
                    ),

                    // Always show time pickers, regardless of switch state
                    // SizedBox(height: Spacing.sm.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMasterTimePicker(
                            label: 'Opens',
                            value: _masterOpenTime,
                            onChanged: (time) {
                              setState(() {
                                _masterOpenTime = time;
                              });
                              // Only apply if the switch is ON
                              if (_applyDefaultHours) {
                                _applyDefaultHoursToWeekdays();
                              }
                            },
                          ),
                        ),
                        Gap(Spacing.md.w),
                        Expanded(
                          child: _buildMasterTimePicker(
                            label: 'Closes',
                            value: _masterCloseTime,
                            onChanged: (time) {
                              setState(() {
                                _masterCloseTime = time;
                              });
                              // Only apply if the switch is ON
                              if (_applyDefaultHours) {
                                _applyDefaultHoursToWeekdays();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Gap(Spacing.sm.h),
                    // Show which days it applies to
                    Text(
                      _applyDefaultHours
                          ? 'Monday - Friday\n(currently applied)'
                          : 'Monday - Friday\n(toggle to apply)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            _applyDefaultHours
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Individual Days List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = index + 1;
                final dayHours = _localHours.firstWhere(
                  (h) => h.dayOfWeek == day,
                  orElse:
                      () => OpeningHoursDraft(
                        dayOfWeek: day,
                        opensAt: '09:00 AM',
                        closesAt: '05:00 PM',
                        isClosed: true,
                      ),
                );

                return _buildDayTile(
                  day: day,
                  hours: dayHours,
                  theme: theme,
                  canApplyMaster: day <= 5 && _applyDefaultHours,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _localHours.any((h) => !h.isClosed)
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to appointment service slots',
                    center: false,
                    iconData: Icons.content_cut,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,
                    onPressed: _saveAndContinue,
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildMasterTimePicker({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: () {
        _showTimePickerBottomSheet(
          isOpen: label == 'Opens',
          onSelected: onChanged,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: .2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onBackground),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTile({
    required int day,
    required OpeningHoursDraft hours,
    required ThemeData theme,
    required bool canApplyMaster,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = dayNames[day - 1];
    final isCustomized = _customDays.contains(day);
    final isWeekend = day > 5;
    return CardInkWell(
      margin: const EdgeInsets.all(0),
      elevation: 1,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  // fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                ),
              ),
              Gap(Spacing.sm),
              if (isCustomized && !isWeekend)
                MiniContainerIndicator(
                  color: theme.colorScheme.primary,
                  text: 'Custom',
                ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    hours.isClosed ? 'Closed' : 'Open',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  AppToggleSwitch(
                    toggleValue: !hours.isClosed,
                    onToggleChanged: (value) {
                      final newIsClosed = !value;
                      final newOpenTime =
                          newIsClosed
                              ? '09:00 AM'
                              : (canApplyMaster
                                  ? _masterOpenTime
                                  : hours.opensAt);
                      final newCloseTime =
                          newIsClosed
                              ? '05:00 PM'
                              : (canApplyMaster
                                  ? _masterCloseTime
                                  : hours.closesAt);

                      _updateDay(
                        day: day,
                        opensAt: newOpenTime,
                        closesAt: newCloseTime,
                        isClosed: newIsClosed,
                      );

                      if (!newIsClosed && canApplyMaster) {
                        setState(() {
                          _customDays.remove(day);
                        });
                      }
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ),
            ],
          ),

          if (!hours.isClosed) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerTile(
                    label: 'Opens',
                    value: hours.opensAt,
                    onChanged: (time) {
                      _updateDay(
                        day: day,
                        opensAt: time,
                        closesAt: hours.closesAt,
                        isClosed: hours.isClosed,
                      );
                      if (canApplyMaster && time != _masterOpenTime) {
                        setState(() {
                          _customDays.add(day);
                        });
                      }
                    },
                  ),
                ),
                Gap(Spacing.md.w),
                Expanded(
                  child: _buildTimePickerTile(
                    label: 'Closes',
                    value: hours.closesAt,
                    onChanged: (time) {
                      _updateDay(
                        day: day,
                        opensAt: hours.opensAt,
                        closesAt: time,
                        isClosed: hours.isClosed,
                      );
                      if (canApplyMaster && time != _masterCloseTime) {
                        setState(() {
                          _customDays.add(day);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            if (canApplyMaster && isCustomized)
              Padding(
                padding: EdgeInsets.only(top: Spacing.sm.h),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _applyMasterToDay(day),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.sm.w,
                        vertical: 4.h,
                      ),
                    ),
                    child: Text(
                      'Apply default hours',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap:
          () => _showTimePickerBottomSheet(
            isOpen: label == 'Opens',
            onSelected: onChanged,
          ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: .2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onBackground),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/manageServices');
  }
}
