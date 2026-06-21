// lib/features/booking/presentation/controllers/slot_generation_controller.dart

import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_addons_provider.dart';
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
    // Re-generate when add-on selection changes — add-on minutes affect the
    // reserved slot length, so available times must be recomputed.
    ref.listen(selectedAddonsProvider, (_, __) {
      _debouncedGenerate(shopId, services, workerIdsOnly, date, quantities);
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

      // Per-service add-on minutes so the engine reserves the real appointment
      // length (e.g. a "+30 min" add-on must extend the slot end time).
      final addonsNotifier = ref.read(selectedAddonsProvider.notifier);
      final extraMinutesBySlot = <String, int>{
        for (final s in services)
          s.id: addonsNotifier
              .forSlot(s.id)
              .fold<int>(0, (sum, a) => sum + (a.durationMinutes ?? 0)),
      };

      // Call repository (we'll update it to accept quantities and selectedWorkerIds)
      final slots = await repository.generateTimeSlots(
        shopId: shopId,
        date: date,
        services: services,
        quantities: quantities,
        selectedWorkerIds: selectedWorkerIds,
        extraMinutesBySlot: extraMinutesBySlot,
      );

      // Filter slots based on group capacity only.
      // Worker availability is checked server-side in generate_available_slots
      // and enforced at booking creation time. Filtering slots here by
      // selected-worker membership was causing all slots to disappear when
      // available_workers is empty (slots with no assigned workers).
      final filteredSlots =
          slots.where((slot) {
            final service = services.firstWhere(
              (s) => s.id == slot.slotId,
              orElse: () => services.first,
            );
            final quantity = quantities[service.id] ?? 1;

            // Group capacity: remaining spots must cover the requested quantity.
            if (slot.remainingSpots != null &&
                slot.remainingSpots! < quantity) {
              return false;
            }

            return true;
          }).toList();

      state = state.copyWith(
        slots: filteredSlots,
        isLoading: false,
        lastGeneratedDate: date,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load available times. Please try again.',
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
