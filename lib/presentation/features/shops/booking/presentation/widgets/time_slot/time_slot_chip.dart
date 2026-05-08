// lib/features/booking/presentation/widgets/time_slot/time_slot_chip.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
/// A beautiful chip for displaying individual time slots.
///
/// Shows time range, price, and availability status.
/// Supports different states: available, selected, full, unavailable.
///
/// ## Features
/// - Time range display (e.g., "9:00 AM - 10:00 AM")
/// - Price indicator
/// - Visual states (available, selected, full, past)
/// - Worker count indicator for slots with multiple workers
/// - Smooth animations on selection
///
/// ## Usage
/// ```dart
/// TimeSlotChip(
///   slot: timeSlot,
///   isSelected: isSelected,
///   onTap: () => selectSlot(timeSlot),
///   currency: 'GHS',
/// )
/// ```
// lib/features/booking/presentation/widgets/time_slot/time_slot_chip.dart

class TimeSlotChip extends ConsumerWidget {
  final TimeSlotModel slot;
  final bool isSelected;
  final VoidCallback onTap;
  final String currency;
  final String dayPeriod;

  final bool isPast;

  const TimeSlotChip({
    Key? key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
    required this.dayPeriod,
    required this.currency,
    this.isPast = false,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get total requested quantity for this slot's service
    final requestedQuantity =
        ref.watch(serviceQuantityProvider)[slot.slotId] ?? 1;
    final hasEnoughSpots =
        slot.remainingSpots == null ||
        slot.remainingSpots! >= requestedQuantity;
    final isAvailable = hasEnoughSpots && !isPast;

    return Opacity(
      opacity: isPast || !isAvailable ? 0.3 : 1.0,
      child: CardInkWell(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(0),
        color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
        elevation: .5,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(Spacing.md.w),
          child: Row(
            children: [
              // Time icon
              Icon(
                Icons.access_time,
                size: IconSizes.md.w,
                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
              ),
              Gap(Spacing.md.w),

              // Time and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          slot.timeRangeDisplay,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                          ),
                        ),
                        MiniContainerIndicator(
                          color: _getDayPeriosColor(dayPeriod),
                          text: dayPeriod[0].toUpperCase(),
                          fontSize: 12,
                        ),
                      ],
                    ),

                    // Show subtle buffer indicator
                    // Icon(Icons.timer, size: 12, color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (slot.bufferMinutes > 0)
                          Text(
                            '${slot.bufferMinutes}min buffer',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color:
                                  isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onBackground,
                            ),
                          ),

                        // Text(
                        //   '$currency ${slot.price.toStringAsFixed(2)}',
                        // style: theme.textTheme.titleSmall?.copyWith(
                        //   fontWeight: FontWeight.w700,
                        //   color:
                        //       isSelected
                        //           ? colorScheme.onPrimary
                        //           : colorScheme.primary,
                        // ),
                        // ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (slot.remainingSpots != null)
                          Text(
                            _getSpotsText(
                              context,
                              slot.remainingSpots!,
                              requestedQuantity,
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getSpotsColor(
                                slot.remainingSpots!,
                                requestedQuantity,
                                colorScheme,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        _buildAvailabilityText(
                          context,
                          colorScheme,
                          requestedQuantity,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityText(
    BuildContext context,
    ColorScheme colorScheme,
    int requestedQuantity,
  ) {
    if (slot.isGroupSlot && slot.remainingSpots != null) {
      if (slot.remainingSpots! < requestedQuantity) {
        return Text(
          'Only ${slot.remainingSpots} spot${slot.remainingSpots! > 1 ? 's' : ''} left',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colorScheme.error),
        );
      }
      return Text(
        '${slot.remainingSpots} spot${slot.remainingSpots! > 1 ? 's' : ''} available',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: colorScheme.tertiary),
      );
    }

    if (slot.requiresWorkerSelection) {
      final workerCount = slot.availableWorkers.length;
      return Text(
        workerCount == 1
            ? '1 worker available'
            : '$workerCount workers available',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color:
              isSelected
                  ? colorScheme.onPrimary.withOpacity(0.7)
                  : colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    return Text(
      'Available',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color:
            isSelected
                ? colorScheme.onPrimary.withOpacity(0.7)
                : colorScheme.primary,
      ),
    );
  }

  String _getSpotsText(BuildContext context, int remaining, int requested) {
    if (remaining < requested) {
      return 'Insufficient spots';
    }
    return '$remaining spot${remaining > 1 ? 's' : ''} left';
  }

  Color _getSpotsColor(int remaining, int requested, ColorScheme colorScheme) {
    if (remaining < requested) return colorScheme.error;
    if (remaining <= 2) return colorScheme.tertiary;
    return colorScheme.primary;
  }
}
