// lib/features/booking/presentation/widgets/time_slot/time_slot_grid.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// A grid display of available time slots.
///
/// Shows time slots in a scrollable list with grouping by time of day
/// (morning, afternoon, evening) for better organization.
///
/// ## Features
/// - Groups slots by time period
/// - Shows loading state
/// - Empty state when no slots available
/// - Handles slot selection
///
/// ## Usage
/// ```dart
/// TimeSlotGrid(
///   slots: availableSlots,
///   selectedSlot: selectedSlot,
///   onSlotSelected: (slot) => selectSlot(slot),
///   currency: 'GHS',
///   isLoading: isLoading,
/// )
/// ```

class TimeSlotGrid extends StatelessWidget {
  final List<TimeSlotModel> slots;
  final Map<String, TimeSlotModel> selectedSlots; // ← Add this
  final Function(String serviceId, TimeSlotModel slot)
  onSlotSelected; // ← Change this
  final String currency;
  final bool isLoading;
  final DateTime? selectedDate;
  final List<AppointmentSlotDTO> selectedServices; // Add this

  const TimeSlotGrid({
    Key? key,
    required this.slots,
    required this.onSlotSelected, // Now takes serviceId + slot
    required this.selectedSlots,
    required this.currency,
    this.isLoading = false,
    this.selectedDate,
    required this.selectedServices, // Make it required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (slots.isEmpty) {
      return _buildEmptyState();
    }

    // Group slots by service ID with debug print
    final Map<String, List<TimeSlotModel>> slotsByService = {};
    for (var slot in slots) {
      slotsByService.putIfAbsent(slot.slotId, () => []).add(slot);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm.w),
      itemCount: selectedServices.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, serviceIndex) {
        final service = selectedServices[serviceIndex];
        final serviceSlots = slotsByService[service.id] ?? [];

        if (serviceSlots.isEmpty) {
          return const SizedBox.shrink();
        }

        // Sort slots by start time
        serviceSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
        final groupedSlots = _groupSlotsByPeriod(serviceSlots);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(Spacing.md),
            // Service header
            Padding(
              padding: EdgeInsets.only(
                // left: Spacing.md.w,
                // right: Spacing.md.w,
                top: serviceIndex == 0 ? 0 : Spacing.lg.h,
                bottom: Spacing.sm.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  if (service.selectPreferredWorker)
                    Text(
                      'Choose your preferred worker',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            // Slots grouped by period
            ...groupedSlots.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildPeriodHeader(entry.key, context),
                  ...entry.value.map(
                    (slot) => TimeSlotChip(
                      slot: slot,
                      isSelected: selectedSlots[service.id] == slot,
                      onTap: () => onSlotSelected(service.id, slot),
                      currency: currency,
                      isPast: _isPastSlot(slot),
                      dayPeriod: entry.key,
                    ),
                  ),
                ],
              );
            }).toList(),

            if (serviceIndex < selectedServices.length - 1)
              Divider(
                height: Spacing.xl.h,
                thickness: 8,
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
          ],
        );
      },
    );
  }

  Map<String, List<TimeSlotModel>> _groupSlotsByPeriod(
    List<TimeSlotModel> slots,
  ) {
    final grouped = <String, List<TimeSlotModel>>{};

    for (var slot in slots) {
      final hour = slot.startTime.hour;
      String period;

      if (hour < 12) {
        period = 'Morning';
      } else if (hour < 17) {
        period = 'Afternoon';
      } else {
        period = 'Evening';
      }

      grouped.putIfAbsent(period, () => []).add(slot);
    }

    // Sort slots within each period by time
    grouped.forEach((key, slots) {
      slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    return grouped;
  }

  // Widget _buildPeriodHeader(String period, BuildContext context) {
  //   final theme = Theme.of(context);
  //   final colorScheme = theme.colorScheme;

  //   return Padding(
  //     padding: EdgeInsets.only(bottom: Spacing.sm.h, top: Spacing.md.h),
  //     child: Text(
  //       period,
  //       style: theme.textTheme.titleMedium?.copyWith(
  //         fontWeight: FontWeight.w600,
  //         color: colorScheme.onBackground,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularLoadingIndicator(),
          SizedBox(height: Spacing.md.h),
          Text(AppLocalizations.of(context)!.bookingFindingAvailableTimes),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      // icon: Icons.access_time,
      title:
          selectedDate != null
              ? 'No slots available on ${_formatDate(selectedDate!)}'
              : 'No slots available',
      subtitle:
          selectedDate != null
              ? 'Try selecting a different date'
              : 'Please select a date to see available times',
    );
  }

  bool _isPastSlot(TimeSlotModel slot) {
    return slot.startTime.isBefore(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
