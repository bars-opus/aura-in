// lib/features/booking/presentation/widgets/shared/booking_summary_card.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// A beautiful card displaying a complete booking summary.
///
/// Shows all selected services, allWorkers, time, and price breakdown.
/// Used in the confirmation screen and possibly in success screens.
///
/// ## Features
/// - Service list with prices
/// - Worker assignments
/// - Date and time display
/// - Price breakdown with total
/// - Clean, professional design
///
/// ## Usage
/// ```dart
/// BookingSummaryCard(
///   services: selectedServices,
///   allWorkers: selectedWorkers,
///   date: selectedDate,
///   timeSlot: selectedTimeSlot,
///   totalDuration: totalDuration,
///   totalPrice: totalPrice,
///   currency: 'GHS',
/// )
/// ```

class BookingSummaryCard extends ConsumerWidget {
  // Changed to ConsumerWidget
  final List<AppointmentSlotDTO> services;
  final List<WorkerDTO> allWorkers;
  final Map<String, List<String?>> workers; // Updated type

  final DateTime date;
  final Map<String, TimeSlotModel> timeSlots;
  final bool isCombinedView;
  final Duration totalDuration;
  final double totalPrice;
  final String shopCurrency;
  final VoidCallback payOnPressed;
  final bool isProcessing;
  final String reference;

  const BookingSummaryCard({
    Key? key,
    required this.services,
    required this.allWorkers,
    required this.date,
    required this.timeSlots, // ← Changed
    required this.isCombinedView, // ← New    required this.totalDuration,
    required this.totalPrice,
    required this.shopCurrency,
    required this.workers,
    required this.isProcessing,
    required this.payOnPressed,
    required this.reference,
    required this.totalDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Now you can use ref here
    final quantities = ref.watch(serviceQuantityProvider);

    return Column(
      children: [
        Gap(Spacing.md.h),

        // Show time slots based on view mode
        if (isCombinedView && timeSlots.isNotEmpty)
          TimeslotDurationWidget(
            startTime: timeSlots.values.first.startTime,
            endTime: timeSlots.values.first.endTime,
          )
        else
          // For regular view, show a summary or the first slot
          TimeslotDurationWidget(
            startTime:
                timeSlots.values.isNotEmpty
                    ? timeSlots.values.first.startTime
                    : DateTime.now(),
            endTime:
                timeSlots.values.isNotEmpty
                    ? timeSlots.values.first.endTime
                    : DateTime.now(),
          ),

        Gap(Spacing.lg.h),
        CardInkWell(
          padding: EdgeInsets.all(Spacing.sm),

          borderRadius: BorderRadius.circular(10),
          elevation: 5,

          child: Column(
            children: [
              Gap(Spacing.md.h),
              ...services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;
                final quantity = quantities[service.id] ?? 1;

                // Get the time slot for this specific service
                final timeSlot = timeSlots[service.id];

                // Get the worker IDs for this service
                final workerIds = workers[service.id] ?? [];
                final firstWorkerId =
                    workerIds.isNotEmpty ? workerIds.first : null;

                // Find the worker object
                WorkerDTO? worker;
                if (firstWorkerId != null) {
                  try {
                    worker = allWorkers.firstWhere(
                      (w) => w.id == firstWorkerId,
                    );
                  } catch (e) {
                    worker = null;
                  }
                }

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                  child: ClientServiceTable(
                    rows: [
                      TableRowData(
                        leftLabel: 'Service',
                        leftValue:
                            quantity > 1
                                ? '${service.serviceName} x$quantity'
                                : service.serviceName,
                        rightLabel: 'Worker',
                        rightValue: worker != null ? worker.name : '',
                      ),
                      TableRowData(
                        leftLabel:
                            '$shopCurrency ${(service.price * quantity / 100).toStringAsFixed(2)}',
                        leftValue: '',
                        rightLabel: _getTimeDisplay(
                          timeSlot,
                          isCombinedView,
                          service.serviceName,
                        ),
                        rightValue: '',
                      ),
                    ],
                  ),
                );
              }).toList(),

              BookingPriceBreakdown(
                buttonText: 'Confirm appointment',
                isProcessing: isProcessing,
                totalAmount: totalPrice,
                depositAmount: totalPrice * 0.3,
                platformFee: 2,
                payOnPressed: payOnPressed,
                reference: reference,
                shopCurrency: shopCurrency,
                isShopOwner: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTimeDisplay(
    TimeSlotModel? timeSlot,
    bool isCombinedView,
    String serviceName,
  ) {
    if (timeSlot == null) return 'Time not selected';

    if (isCombinedView) {
      // In combined view, all services share the same time
      return MyDateFormat.toTime(timeSlot.startTime);
    } else {
      // In regular view, show service-specific time
      return '${MyDateFormat.toTime(timeSlot.startTime)}';
    }
  }
}
