// lib/features/booking/presentation/widgets/worker_selection/worker_assignment_indicator.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// A compact indicator showing which worker is assigned to which service.
///
/// Used in the booking summary and time slot selection to show
/// the current worker assignments for each selected service.
///
/// ## Features
/// - Shows worker avatar/initials per service
/// - Visual indication of unassigned services
/// - Tappable to open worker selection
/// - Compact design for limited space
///
/// ## Usage
/// ```dart
/// WorkerAssignmentIndicator(
///   services: selectedServices,
///   workers: selectedWorkers,
///   onTapService: (service) => openWorkerSheet(service),
/// )
/// ```
class WorkerAssignmentIndicator extends StatelessWidget {
  final List<AppointmentSlotDTO> services;
  final Map<String, WorkerDTO?> workers;
  final Function(AppointmentSlotDTO)? onTapService;
  final bool compact;

  const WorkerAssignmentIndicator({
    Key? key,
    required this.services,
    required this.workers,
    this.onTapService,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (services.isEmpty) return const SizedBox.shrink();

    return CardInkWell(
      elevation: compact ? 0 : 1,
      borderColor: Colors.transparent,
      padding: compact ? EdgeInsets.all(0) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Icon(
          //       Icons.people,
          //       size: IconSizes.sm.w,
          //       color: colorScheme.primary,
          //     ),
          //     Gap(Spacing.md.w),
          //     Text(
          //       'Worker Assignments',
          //       style: theme.textTheme.titleSmall?.copyWith(
          //         fontWeight: FontWeight.w600,
          //         color: colorScheme.onBackground,
          //       ),
          //     ),
          //   ],
          // ),
          // Gap(Spacing.sm.h),
          _buildServiceTable(context),
        ],
      ),
    );
  }

  Widget _buildServiceTable(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Filter services that require worker selection
    final servicesRequiringWorkers =
        services.where((s) => s.selectPreferredWorker).toList();

    if (servicesRequiringWorkers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2), // Service name
            1: FlexColumnWidth(2), // Worker name
            2: IntrinsicColumnWidth(), // Action indicator
          },
          border: TableBorder(
            horizontalInside: BorderSide(
              color: colorScheme.outlineVariant,
              width: 0.5,
            ),
            top: BorderSide.none,
            bottom: BorderSide.none,
            left: BorderSide.none,
            right: BorderSide.none,
          ),
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(Spacing.sm.w),
                  child: Text(
                    'Service',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Spacing.sm.w),
                  child: Text(
                    'Assigned Worker',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Spacing.sm.w),
                  child: Text('', style: textTheme.bodySmall),
                ),
              ],
            ),

            // Data rows
            ...servicesRequiringWorkers.map((service) {
              final worker = workers[service.id];
              final isAssigned = worker != null;

              return TableRow(
                children: [
                  // Service name
                  Padding(
                    padding: EdgeInsets.all(Spacing.sm.w),
                    child: Text(
                      service.serviceName,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // Worker info
                  Padding(
                    padding: EdgeInsets.all(Spacing.sm.w),
                    child: Text(
                      isAssigned ? worker!.name : 'Not assigned',
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            isAssigned
                                ? colorScheme.onSurface
                                : colorScheme.error,
                        fontStyle: isAssigned ? null : FontStyle.italic,
                      ),
                    ),
                  ),

                  // Action indicator
                  if (onTapService != null)
                    Padding(
                      padding: EdgeInsets.all(Spacing.sm.w),
                      child: Icon(
                        Icons.chevron_right,
                        size: IconSizes.sm.w,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
