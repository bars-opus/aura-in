// lib/features/booking/presentation/widgets/worker_selection/worker_selection_sheet.dart

import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';



import 'worker_avatar_chip.dart';

/// A modal bottom sheet for selecting a worker for a specific service.
///
/// Displays all available workers for the selected service with
/// their availability status and specialties.
///
/// ## Features
/// - Beautiful bottom sheet design with drag handle
/// - Shows service name and required duration
/// - Lists all workers with availability
/// - Smooth selection flow
///
/// ## Usage
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => WorkerSelectionSheet(
///     service: service,
///     workers: availableWorkers,
///     selectedWorkerId: currentWorkerId,
///     onWorkerSelected: (worker) => selectWorker(worker),
///   ),
/// );
/// ```
class WorkerSelectionSheet extends StatelessWidget {
  final AppointmentSlotDTO service;
  final List<WorkerDTO> workers;
  final String? selectedWorkerId;
  final Function(WorkerDTO) onWorkerSelected;
  final Map<String, bool>? workerAvailability;

  const WorkerSelectionSheet({
    Key? key,
    required this.service,
    required this.workers,
    this.selectedWorkerId,
    required this.onWorkerSelected,
    this.workerAvailability,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CircularDocumentationContainer(
      padding: 0,
      child: ListView(
        // mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a worker',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    Gap(Spacing.xs.h),
                    Text(
                      service.serviceName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                icon: Icons.close,
                onPressed: () => Navigator.pop(context),
                iconSize: IconSizes.md.w,
                // size: 40.h,
              ),
            ],
          ),
          Gap(Spacing.lg.h),
          // Worker list
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                final isSelected = worker.id == selectedWorkerId;
                final isAvailable = workerAvailability?[worker.id] ?? true;

                return WorkerAvatarChip(
                  isSelecting: true,
                  worker: worker,
                  isSelected: isSelected,
                  isAvailable: isAvailable,
                  onTap: () {
                    onWorkerSelected(worker);
                    Navigator.pop(context);
                  },
                  showSpecialty: true,
                );
              },
            ),
          ),
          Gap(Spacing.lg.h),
          SemanticContainerWidget(
            content:
                'Slots woould be generated based on the availability of the selected worker. You can change the worker later if they become unavailable',
            icon: Icons.info_outline,
            title: '',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}
