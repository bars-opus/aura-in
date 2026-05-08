// lib/features/booking/presentation/screens/worker_selection_screen.dart
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

class WorkerSelectionScreen extends ConsumerStatefulWidget {
  const WorkerSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkerSelectionScreen> createState() =>
      _WorkerSelectionScreenState();
}

class _WorkerSelectionScreenState extends ConsumerState<WorkerSelectionScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    // Initialize worker lists for services based on quantities
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWorkerLists();
      // _setupQuantityListener();
    });
  }

  void _initializeWorkerLists() {
    final services = ref.read(selectedServicesProvider);
    final quantities = ref.read(serviceQuantityProvider);
    final workersNotifier = ref.read(selectedWorkersProvider.notifier);

    for (final service in services) {
      if (service.selectPreferredWorker) {
        final qty = quantities[service.id] ?? 1;
        workersNotifier.resizeService(service.id, qty);
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedServices = ref.watch(selectedServicesProvider);
    final selectedWorkersMap = ref.watch(selectedWorkersProvider);
    final quantities = ref.watch(serviceQuantityProvider);
    final shopId = ref.watch(selectedShopIdProvider);

    // Add this listener in build
    ref.listen(serviceQuantityProvider, (prev, next) {
      final services = ref.read(selectedServicesProvider);
      final workersNotifier = ref.read(selectedWorkersProvider.notifier);
      for (final service in services) {
        if (service.selectPreferredWorker) {
          final newQty = next[service.id] ?? 1;
          workersNotifier.resizeService(service.id, newQty);
        }
      }
    });

    // Filter services that require worker selection
    final servicesRequiringWorkers =
        selectedServices.where((s) => s.selectPreferredWorker).toList();

    final allWorkersSelected = ref
        .read(selectedWorkersProvider.notifier)
        .areAllRequiredServicesComplete(selectedServices);

    // If no services require workers, show empty state
    if (servicesRequiringWorkers.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          type: EmptyStateType.noWorker,
          title: '',
          subtitle: 'No worker selection needed\nContinue to Time Selection',
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: Spacing.md.w),
              itemCount: servicesRequiringWorkers.length,
              itemBuilder: (context, index) {
                final service = servicesRequiringWorkers[index];
                final quantity = quantities[service.id] ?? 1;
                final selectedWorkerIds =
                    selectedWorkersMap[service.id] ?? List.filled(quantity, {});

                // Fetch workers for this service
                final workersAsync = ref.watch(
                  workersForSlotProvider(shopId: shopId!, slotId: service.id),
                );

                return CardInkWell(
                  elevation: .8,
                  padding: EdgeInsets.all(Spacing.md.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service header
                      Text(
                        service.serviceName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      if (quantity > 1)
                        Padding(
                          padding: EdgeInsets.only(top: Spacing.xs.h),
                          child: Text(
                            'Select a worker for each person',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      Gap(Spacing.md.h),

                      // List of worker selection chips for each person
                      ...List.generate(quantity, (personIndex) {
                        final selectedWorkerId =
                            selectedWorkerIds[personIndex]?['id'];

                        return Padding(
                          padding: EdgeInsets.only(bottom: Spacing.sm.h),
                          child: _buildPersonWorkerSelector(
                            context,
                            service,
                            personIndex,
                            selectedWorkerId,
                            workersAsync,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonWorkerSelector(
    BuildContext context,
    AppointmentSlotDTO service,
    int personIndex,
    String? selectedWorkerId,
    AsyncValue<List<WorkerDTO>> workersAsync,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (service.selectPreferredWorker && personIndex == 0)
          Padding(
            padding: EdgeInsets.only(bottom: Spacing.xs.h),
            child: Text(
              'Person ${personIndex + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        workersAsync.when(
          data: (workers) {
            WorkerDTO? foundWorker;
            if (selectedWorkerId != null) {
              try {
                foundWorker = workers.firstWhere(
                  (w) => w.id == selectedWorkerId,
                );
              } catch (e) {
                foundWorker = null;
              }
            }

            if (foundWorker != null) {
              return WorkerAvatarChip(
                isSelecting: false,
                worker: foundWorker,
                isSelected: true,
                isAvailable: true,
                onTap:
                    () => _openWorkerSelectionSheet(
                      context,
                      service,
                      workers,
                      personIndex,
                      selectedWorkerId,
                    ),
              );
            } else {
              return AppButton(
                elevation: 0,
                label: 'Choose Person ${personIndex + 1}',
                onPressed:
                    () => _openWorkerSelectionSheet(
                      context,
                      service,
                      workers,
                      personIndex,
                      null,
                    ),
                size: ButtonSize.small,
                width: double.infinity,
                padding: Spacing.horizontalMd,
                height: 40.h,
              );
            }
          },
          loading: () => ShopSchimmerSkeleton(height: 50),
          error:
              (error, stack) =>
                  ErrorStateWidget(subtitle: 'Error loading workers'),
        ),
      ],
    );
  }

  void _openWorkerSelectionSheet(
    BuildContext context,
    AppointmentSlotDTO service,
    List<WorkerDTO> workers,
    int personIndex,
    String? selectedWorkerId,
  ) {
    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 600.h,
      context: context,
      widget: WorkerSelectionSheet(
        service: service,
        workers: workers,
        selectedWorkerId: selectedWorkerId,
        onWorkerSelected: (worker) {
          // Store the ID in selectedWorkersProvider (as before)
          ref
              .read(selectedWorkersProvider.notifier)
              .selectWorker(
                service.id,
                personIndex,
                worker.id,
                worker.name, // ← Now passing the name!
              );

          // ALSO store the worker's name in the new provider

          // ref
          //     .read(selectedWorkersProvider.notifier)
          //     .selectWorker(service.id, personIndex, worker.id);
        },
        workerAvailability: {}, // TODO: Pass actual availability
      ),
    );
  }
}
