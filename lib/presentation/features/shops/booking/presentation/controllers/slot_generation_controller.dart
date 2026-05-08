// lib/features/booking/presentation/controllers/slot_generation_controller.dart

import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'slot_generation_controller.g.dart';

/// State class for slot generation
// lib/features/booking/presentation/controllers/slot_generation_controller.dart

/// State class for slot generation
class SlotGenerationState {
  final List<TimeSlotModel> slots;
  final bool isLoading;
  final String? error;
  final DateTime? lastGeneratedDate;

  const SlotGenerationState({
    required this.slots,
    required this.isLoading,
    this.error,
    this.lastGeneratedDate,
  });

  factory SlotGenerationState.initial() {
    return const SlotGenerationState(
      slots: [],
      isLoading: false,
      error: null,
      lastGeneratedDate: null,
    );
  }

  SlotGenerationState copyWith({
    List<TimeSlotModel>? slots,
    bool? isLoading,
    String? error,
    DateTime? lastGeneratedDate,
  }) {
    return SlotGenerationState(
      slots: slots ?? this.slots,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
    );
  }

  bool get hasSlots => slots.isNotEmpty;
  bool get hasError => error != null;
}

@riverpod
class SlotGenerationController extends _$SlotGenerationController {
  static const _debounceDuration = Duration(milliseconds: 500);
  int _requestCounter = 0;

  @override
  SlotGenerationState build() {
    final shopId = ref.watch(selectedShopIdProvider);
    final services = ref.watch(selectedServicesProvider);
    final workersData = ref.watch(selectedWorkersProvider); // New type
    final date = ref.watch(selectedDateProvider);
    final quantities = ref.watch(serviceQuantityProvider);

    if (shopId == null) {
      return SlotGenerationState.initial();
    }

    // Convert to IDs-only for listeners
    final workerIdsOnly = <String, List<String?>>{};
    workersData.forEach((serviceId, workerEntries) {
      workerIdsOnly[serviceId] =
          workerEntries.map((entry) => entry['id']).toList();
    });

    // Setup listeners
    ref.listen(selectedServicesProvider, (_, next) {
      _debouncedGenerate(shopId, next, workerIdsOnly, date, quantities);
    });
    ref.listen(selectedWorkersProvider, (_, next) {
      // Convert on the fly for the listener
      final nextIds = <String, List<String?>>{};
      next.forEach((serviceId, workerEntries) {
        nextIds[serviceId] = workerEntries.map((entry) => entry['id']).toList();
      });
      _debouncedGenerate(shopId, services, nextIds, date, quantities);
    });
    ref.listen(selectedDateProvider, (_, next) {
      _debouncedGenerate(shopId, services, workerIdsOnly, next, quantities);
    });
    ref.listen(serviceQuantityProvider, (_, next) {
      _debouncedGenerate(shopId, services, workerIdsOnly, date, next);
    });

    if (services.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _debouncedGenerate(shopId, services, workerIdsOnly, date, quantities);
      });
    }

    return SlotGenerationState.initial();
  }

  void _debouncedGenerate(
    String shopId,
    List<AppointmentSlotDTO> services,
    Map<String, List<String?>> workers,
    DateTime date,
    Map<String, int> quantities,
  ) {
    if (services.isEmpty) return;

    final requestId = ++_requestCounter;

    Future.delayed(_debounceDuration, () async {
      if (requestId == _requestCounter) {
        await _generateSlots(shopId, services, workers, date, quantities);
      }
    });
  }

  // In slot_generation_controller.dart

  Future<void> _generateSlots(
    String shopId,
    List<AppointmentSlotDTO> services,
    Map<String, List<String?>> workers,
    DateTime date,
    Map<String, int> quantities,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(bookingRepositoryProvider);

      // Prepare selected worker IDs (non-null) per service
      final selectedWorkerIds = <String, List<String>>{};
      workers.forEach((serviceId, workerList) {
        if (workerList != null) {
          final nonNullIds = workerList.whereType<String>().toList();
          if (nonNullIds.isNotEmpty) {
            selectedWorkerIds[serviceId] = nonNullIds;
          }
        }
      });

      // Call repository (we'll update it to accept quantities and selectedWorkerIds)
      final slots = await repository.generateTimeSlots(
        shopId: shopId,
        date: date,
        services: services,
        quantities: quantities,
        selectedWorkerIds: selectedWorkerIds,
      );

      // Filter slots based on quantities and worker selections
      final filteredSlots =
          slots.where((slot) {
            // Find the corresponding service
            final service = services.firstWhere((s) => s.id == slot.slotId);
            final quantity = quantities[service.id] ?? 1;

            // 1. Capacity check: remaining spots must be enough
            if (slot.remainingSpots != null &&
                slot.remainingSpots! < quantity) {
              return false;
            }

            // 2. If workers are selected for this service, they must all be available
            final selectedForService = selectedWorkerIds[service.id] ?? [];
            if (selectedForService.isNotEmpty) {
              final availableWorkerIds =
                  slot.availableWorkers.map((w) => w.id).toSet();
              if (!selectedForService.every(
                (id) => availableWorkerIds.contains(id),
              )) {
                return false;
              }
            }

            // 3. If no workers selected but service requires worker selection,
            //    we still show the slot if there are enough available workers
            if (service.selectPreferredWorker && selectedForService.isEmpty) {
              // Optionally require at least one worker? For now, allow.
            }

            return true;
          }).toList();

      state = state.copyWith(
        slots: filteredSlots,
        isLoading: false,
        lastGeneratedDate: date,
      );
    } catch (e, stack) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Unable to load available times. Please try again.${e.toString()}',
      );
    }
  }

  List<TimeSlotModel> _filterSlotsByWorkers(
    List<TimeSlotModel> slots,
    Map<String, List<String>> selectedWorkerIds,
    List<AppointmentSlotDTO> services,
  ) {
    // If no services require worker selection, return all slots
    if (services.every((s) => !s.selectPreferredWorker)) {
      return slots;
    }

    // For parallel booking, we need at least as many available workers as requested
    return slots.where((slot) {
      final service = services.firstWhere((s) => s.id == slot.slotId);
      if (!service.selectPreferredWorker) return true;

      final requestedWorkers = selectedWorkerIds[slot.slotId] ?? [];
      if (requestedWorkers.isEmpty) return true; // No workers selected yet

      // Check if ALL selected workers are available in this slot
      final availableWorkerIds = slot.availableWorkers.map((w) => w.id).toSet();
      return requestedWorkers.every((id) => availableWorkerIds.contains(id));
    }).toList();
  }

  Future<void> regenerate({
    required String shopId,
    required DateTime date,
    required List<AppointmentSlotDTO> services,
    required Map<String, List<String?>> workers,
  }) async {
    final quantities = ref.read(serviceQuantityProvider);
    _requestCounter++;
    await _generateSlots(shopId, services, workers, date, quantities);
  }

  void clearSlots() => state = SlotGenerationState.initial();

  Future<void> selectTimeSlot({
    required String serviceId,
    required TimeSlotModel slot,
  }) async {
    final isCombinedView = ref.read(isCombinedViewProvider);

    if (isCombinedView) {
      // In combined view, ignore the serviceId and select for all
      final services = ref.read(selectedServicesProvider);
      ref
          .read(selectedTimeSlotsProvider.notifier)
          .selectCombinedSlot(slot, services);
    } else {
      // In regular view, select only for this service
      ref
          .read(selectedTimeSlotsProvider.notifier)
          .selectSlotForService(serviceId, slot);
    }
  }
}
