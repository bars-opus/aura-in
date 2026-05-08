// lib/features/booking/presentation/widgets/time_slot/combined_slot_display.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// A specialized widget for displaying slots that accommodate multiple services.
///
/// When booking multiple services (e.g., haircut + beard trim), this widget
/// shows only slots where ALL services can be scheduled together.
///
/// ## Features
/// - Shows total duration of all services
/// - Highlights slots where all services fit
/// - Visual indication of which services can be booked together
///
/// ## Usage
/// ```dart
/// CombinedSlotDisplay(
///   slots: availableSlots,
///   selectedServices: selectedServices,
///   totalDuration: totalDuration,
///   onSlotSelected: (slot) => selectSlot(slot),
/// )
/// ```
class CombinedSlotDisplay extends ConsumerWidget {
  final List<TimeSlotModel> slots;
  final List<AppointmentSlotDTO> selectedServices;
  final Duration totalDuration;
  final Function(TimeSlotModel) onSlotSelected;
  final TimeSlotModel? selectedSlot;
  final String dayPeriod;

  const CombinedSlotDisplay({
    Key? key,
    required this.slots,
    required this.selectedServices,
    required this.totalDuration,
    required this.onSlotSelected,
    required this.dayPeriod,
    this.selectedSlot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (selectedServices.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          compact: true,
          subtitle: 'Select services to see available times',
        ),
      );
    }

    if (slots.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          compact: true,
          subtitle:
              'No time slots available\nTry adjusting your service selection or date',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(Spacing.lg),
        // Summary card
        SemanticContainerWidget(
          content:
              '${selectedServices.length} services selected\nTotal time: ${_formatDuration(totalDuration)}',
          icon: Icons.info_outline,
          title: '',
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          borderColor: colorScheme.primary,
          iconColor: colorScheme.primary,
          textTheme: theme.textTheme,
        ),
        Gap(Spacing.sm),

        // Slots list - REMOVE the fixed height!
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final isSelected =
                  selectedSlot?.slotId == slot.slotId &&
                  selectedSlot?.startTime == slot.startTime;

              return _CombinedSlotCard(
                slot: slot,
                isSelected: isSelected,
                dayPeriod: dayPeriod,
                onTap: () => onSlotSelected(slot),
                selectedServices: selectedServices,
              );
            },
          ),
        ),
      ],
    );
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
}

/// Internal card for combined slot display
class _CombinedSlotCard extends StatelessWidget {
  final TimeSlotModel slot;
  final bool isSelected;
  final VoidCallback onTap;
  final String dayPeriod;

  final List<AppointmentSlotDTO> selectedServices;

  const _CombinedSlotCard({
    Key? key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
    required this.dayPeriod,

    required this.selectedServices,
  }) : super(key: key);
  Color _getDayPeriosColor(String level) {
    switch (level) {
      case 'Morning':
        return Colors.green;
      case 'Afternoon':
        return Colors.amber.shade700;
      case 'Evening':
        return Colors.purple;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(0),
      color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
      elevation: .5,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),

      child: Padding(
        padding: EdgeInsets.all(Spacing.md.w),
        child: Column(
          children: [
            // Time and price row
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color:
                      isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onBackground,
                  size: IconSizes.md.w,
                ),
                Gap(Spacing.sm.w),
                Expanded(
                  child: Text(
                    slot.timeRangeDisplay,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onBackground,
                    ),
                  ),
                ),
                MiniContainerIndicator(
                  color: _getDayPeriosColor(dayPeriod),
                  text: dayPeriod[0].toUpperCase(),
                  fontSize: 12,
                ),
              ],
            ),
            Gap(Spacing.sm.h),

            // Worker assignments for each service
            ...selectedServices.map((service) {
              final hasWorker = slot.availableWorkers.isNotEmpty;

              return Padding(
                padding: EdgeInsets.only(bottom: Spacing.xs.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 4.sp,
                      color: colorScheme.onPrimary.withOpacity(0.3),
                    ),
                    Gap(Spacing.sm.w),
                    Expanded(
                      child: Text(
                        service.serviceName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onBackground,
                        ),
                      ),
                    ),
                    if (service.selectPreferredWorker)
                      Text(
                        hasWorker ? '✓ Worker available' : '✗ No workers',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              isSelected
                                  ? colorScheme.onBackground
                                  : hasWorker
                                  ? colorScheme.primary
                                  : colorScheme.error,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
