// lib/features/booking/presentation/controllers/worker_selection_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'booking_repository_provider.dart';

part 'worker_selection_controller.g.dart';

/// State class for worker availability
class WorkerAvailabilityState {
  final Map<String, List<WorkerDTO>> availableWorkers;
  final Map<String, bool> isLoading;
  final Map<String, String?> errors;

  const WorkerAvailabilityState({
    required this.availableWorkers,
    required this.isLoading,
    required this.errors,
  });

  factory WorkerAvailabilityState.initial() {
    return WorkerAvailabilityState(
      availableWorkers: {},
      isLoading: {},
      errors: {},
    );
  }

  WorkerAvailabilityState copyWith({
    Map<String, List<WorkerDTO>>? availableWorkers,
    Map<String, bool>? isLoading,
    Map<String, String?>? errors,
  }) {
    return WorkerAvailabilityState(
      availableWorkers: availableWorkers ?? this.availableWorkers,
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
    );
  }

  bool get hasAnyLoading => isLoading.values.contains(true);

  List<WorkerDTO> getWorkersForService(String serviceId) {
    return availableWorkers[serviceId] ?? [];
  }

  bool isLoadingForService(String serviceId) {
    return isLoading[serviceId] ?? false;
  }

  String? getErrorForService(String serviceId) {
    return errors[serviceId];
  }
}

/// Controller responsible for worker selection and availability.
///
/// Handles loading available workers for each service and managing
/// the selection state for parallel group bookings.
@riverpod
class WorkerSelectionController extends _$WorkerSelectionController {
  @override
  WorkerAvailabilityState build() {
    return WorkerAvailabilityState.initial();
  }

  /// Loads available workers for a specific service and time
  Future<void> loadAvailableWorkers({
    required String serviceId,
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    state = state.copyWith(
      isLoading: {...state.isLoading, serviceId: true},
      errors: {...state.errors, serviceId: null},
    );

    try {
      final repository = ref.read(bookingRepositoryProvider);

      // Get all workers for this slot
      final workers = await repository.getAvailableWorkers(
        slotId: slotId,
        startTime: startTime,
        endTime: endTime,
      );

      // If no workers, return empty list
      if (workers.isEmpty) {
        state = state.copyWith(
          availableWorkers: {...state.availableWorkers, serviceId: []},
          isLoading: {...state.isLoading, serviceId: false},
        );
        return;
      }

      // Fetch unavailability for ALL workers in parallel
      final unavailabilityFutures = workers.map((worker) async {
        final unavailability = await repository.getWorkerUnavailability(
          worker.id,
          startTime,
          endTime,
        );
        return MapEntry(worker.id, unavailability);
      });

      final unavailabilityResults = await Future.wait(unavailabilityFutures);
      final unavailabilityMap = Map.fromEntries(unavailabilityResults);

      // Filter workers based on unavailability
      final availableWorkers =
          workers.where((worker) {
            final workerUnavailability = unavailabilityMap[worker.id] ?? [];

            // Check if worker has any unavailability that overlaps with requested time
            final isUnavailable = workerUnavailability.any(
              (period) => period.overlaps(startTime, endTime),
            );

            return !isUnavailable;
          }).toList();

      state = state.copyWith(
        availableWorkers: {
          ...state.availableWorkers,
          serviceId: availableWorkers,
        },
        isLoading: {...state.isLoading, serviceId: false},
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: {...state.isLoading, serviceId: false},
        errors: {...state.errors, serviceId: e.toString()},
      );
    }
  }

  /// Selects a worker for a specific service and person index
  void selectWorker({
    required String serviceId,
    required int personIndex,
    required WorkerDTO worker,
  }) {
    final selectedWorkers = ref.read(selectedWorkersProvider.notifier);
    selectedWorkers.selectWorker(
      serviceId,
      personIndex,
      worker.id,
      worker.name,
    );

    // Check if all required workers are selected
    _checkAllWorkersSelected();
  }

  /// Clears a worker selection for a specific service and person
  void clearWorker({required String serviceId, required int personIndex}) {
    final selectedWorkers = ref.read(selectedWorkersProvider.notifier);
    selectedWorkers.clearPerson(serviceId, personIndex);
  }

  /// Checks if all required workers are selected and advances flow if needed
  void _checkAllWorkersSelected() {
    final services = ref.read(selectedServicesProvider);
    final quantities = ref.read(serviceQuantityProvider);
    final selectedWorkersMap = ref.read(selectedWorkersProvider);

    // Filter services that require worker selection
    final servicesRequiringWorkers =
        services.where((s) => s.selectPreferredWorker).toList();

    if (servicesRequiringWorkers.isEmpty) return;

    bool allComplete = true;

    for (final service in servicesRequiringWorkers) {
      final workerList = selectedWorkersMap[service.id];
      final quantity = quantities[service.id] ?? 1;

      // Check if list exists, has correct length, and no nulls
      if (workerList == null ||
          workerList.length != quantity ||
          workerList.any((id) => id == null)) {
        allComplete = false;
        break;
      }
    }

    // Auto-advance to next step if configured
    // if (allComplete) {
    //   ref.read(bookingFlowStepProvider.notifier).next();
    // }
  }

  /// Clears all loaded worker data
  void clear() {
    state = WorkerAvailabilityState.initial();
  }

  /// Refreshes workers for all selected services
  Future<void> refreshAllWorkers(DateTime date) async {
    final services = ref.read(selectedServicesProvider);

    for (final service in services) {
      if (service.selectPreferredWorker) {
        // You'll need to determine the time range based on service duration
        final duration = _parseDuration(service.duration);
        await loadAvailableWorkers(
          serviceId: service.id,
          slotId: service.id,
          startTime: date,
          endTime: date.add(duration),
        );
      }
    }
  }

  Duration _parseDuration(String durationString) {
    if (durationString.startsWith('PT')) {
      final hours = _extractNumber(durationString, 'H');
      final minutes = _extractNumber(durationString, 'M');
      return Duration(hours: hours, minutes: minutes);
    }
    return Duration.zero;
  }

  int _extractNumber(String input, String unit) {
    final regex = RegExp('(\\d+)$unit');
    final match = regex.firstMatch(input);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }
}
