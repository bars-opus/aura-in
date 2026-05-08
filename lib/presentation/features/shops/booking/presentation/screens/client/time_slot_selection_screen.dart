// lib/features/booking/presentation/screens/time_slot_selection_screen.dart
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

class TimeSlotSelectionScreen extends ConsumerStatefulWidget {
  final bool isFreelancer;

  const TimeSlotSelectionScreen({Key? key, this.isFreelancer = false})
    : super(key: key);

  @override
  ConsumerState<TimeSlotSelectionScreen> createState() =>
      _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState
    extends ConsumerState<TimeSlotSelectionScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    // Trigger initial slot generation when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSlots();
    });
  }

  // In SlotGenerationController, add this wrapper method
  Future<void> _generateSlots() async {
    final shopId = ref.read(selectedShopIdProvider);
    final services = ref.read(selectedServicesProvider);
    final workersData = ref.read(selectedWorkersProvider); // New type
    final date = ref.read(selectedDateProvider);
    final quantities = ref.read(serviceQuantityProvider);

    if (shopId == null || services.isEmpty) return;

    // Convert to the format slot generation expects (just IDs)
    final workerIdsOnly = <String, List<String?>>{};
    workersData.forEach((serviceId, workerEntries) {
      workerIdsOnly[serviceId] =
          workerEntries.map((entry) => entry['id']).toList();
    });

    await ref
        .read(slotGenerationControllerProvider.notifier)
        .regenerate(
          shopId: shopId,
          date: date,
          services: services,
          workers: workerIdsOnly, // Pass just the IDs
        );
  }

  @override
  bool get wantKeepAlive => true;
  // In time_slot_selection_screen.dart

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedServices = ref.watch(selectedServicesProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeSlot = ref.watch(selectedTimeSlotsProvider);
    final selectedWorkers = ref.watch(selectedWorkersProvider);
    final slotState = ref.watch(slotGenerationControllerProvider);

    final isMultiService = selectedServices.length > 1;
    final canContinue = selectedTimeSlot != null;

    final isCombinedView = ref.watch(isCombinedViewProvider);

    // Group slots by time period
    final morningSlots =
        slotState.slots
            .where((s) => _getTimePeriod(s.startTime) == 'Morning')
            .toList();
    final afternoonSlots =
        slotState.slots
            .where((s) => _getTimePeriod(s.startTime) == 'Afternoon')
            .toList();
    final eveningSlots =
        slotState.slots
            .where((s) => _getTimePeriod(s.startTime) == 'Evening')
            .toList();

    // Create tab content based on view mode
    List<AppTabItem> timeTabs = [
      AppTabItem(
        label: 'Morning',
        // icon: Icons.wb_sunny,
        content: _buildTimeSlotContent(
          slots: morningSlots,
          dayPeriod: 'Morning',
          isCombined: isCombinedView && isMultiService,
          selectedServices: selectedServices,
          totalDuration: _calculateTotalDuration(selectedServices),
        ),
      ),
      AppTabItem(
        label: 'Afternoon',
        // icon: Icons.wb_cloudy,
        content: _buildTimeSlotContent(
          slots: afternoonSlots,
          dayPeriod: 'Afternoon',
          isCombined: isCombinedView && isMultiService,
          selectedServices: selectedServices,
          totalDuration: _calculateTotalDuration(selectedServices),
        ),
      ),
      AppTabItem(
        label: 'Evening',
        // icon: Icons.nights_stay,
        content: _buildTimeSlotContent(
          slots: eveningSlots,
          dayPeriod: 'Evening',
          isCombined: isCombinedView && isMultiService,
          selectedServices: selectedServices,
          totalDuration: _calculateTotalDuration(selectedServices),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        // physics: const NeverScrollableScrollPhysics(),
        children: [
          // Worker assignment summary (if multi-service)
          if (isMultiService)
            Column(
              children: [
                // AppDivider(),
                InfoRowWidget(
                  showDivider: false,
                  iconSize: 0,
                  iconColor: Colors.transparent,
                  subtitle:
                      'See time slots where all your selected workers are available together',
                  title: 'Show combined slots',
                  icon: Icons.group_work,
                  toggleValue: isCombinedView,
                  isToggleItem: true,
                  // disableTrailing: true,
                  showAvatar: false,
                  onToggleChanged: (value) {
                    // Directly set the provider based on the toggle value
                    if (value) {
                      ref.read(isCombinedViewProvider.notifier).enable();
                    } else {
                      ref.read(isCombinedViewProvider.notifier).disable();
                    }
                  },
                ),
                Gap(5),

                AppDivider(), Gap(10),
              ],
            ),

          // Calendar picker
          SlotCalendarPicker(
            selectedDate: selectedDate,
            onDateSelected: (date) {
              ref.read(selectedDateProvider.notifier).selectDate(date);
              _generateSlots();
            },
            availabilityMap: _generateAvailabilityMap(slotState.slots),
          ),

          // Error display
          if (slotState.hasError)
            ErrorStateWidget(
              showDetails: true,
              compact: true,
              errorDetails: slotState.error!,
              type: ErrorStateType.genericError,
              onPrimaryAction: _generateSlots,
            ),

          // Time slots with tabs
          SizedBox(
            height: slotState.slots.length * 300,
            child: TabsWithContent(
              useNestedScrollMode: false,

              tabs: timeTabs,
              initialIndex: 0,
              scrollable: false,
              showContent: true,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to safely find a slot

  Widget _buildTimeSlotContent({
    required List<TimeSlotModel> slots,
    required bool isCombined, // This can be derived from provider instead
    required List<AppointmentSlotDTO> selectedServices,
    required Duration totalDuration,
    required String dayPeriod,
  }) {
    // Use the provider instead of the parameter
    final isCombinedView = ref.watch(isCombinedViewProvider);

    final combinedSlots = generateCombinedSlots(slots, selectedServices);

    if (isCombinedView) {
      return CombinedSlotDisplay(
        slots: combinedSlots,
        dayPeriod: dayPeriod,
        selectedServices: selectedServices,
        totalDuration: totalDuration,
        onSlotSelected: (slot) {
          ref
              .read(selectedTimeSlotsProvider.notifier)
              .selectCombinedSlot(slot, selectedServices);
        },
        selectedSlot: ref.watch(selectedTimeSlotsProvider).values.firstOrNull,
      );
    } else {
      return TimeSlotGrid(
        slots: slots,
        selectedSlots: ref.watch(selectedTimeSlotsProvider),
        onSlotSelected: (serviceId, slot) {
          ref
              .read(selectedTimeSlotsProvider.notifier)
              .selectSlotForService(serviceId, slot);
        },
        currency: 'GHS',
        selectedServices: selectedServices,
      );
    }
  }

  String _getTimePeriod(DateTime time) {
    final hour = time.hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Map<DateTime, bool> _generateAvailabilityMap(List<TimeSlotModel> slots) {
    final availabilityMap = <DateTime, bool>{};

    for (var slot in slots) {
      final date = DateTime(
        slot.startTime.year,
        slot.startTime.month,
        slot.startTime.day,
      );
      availabilityMap[date] = true;
    }

    return availabilityMap;
  }

  Duration _calculateTotalDuration(List<AppointmentSlotDTO> services) {
    return services.fold<Duration>(
      Duration.zero,
      (sum, service) => sum + DurationUtils.parse(service.duration),
    );
  }
}
