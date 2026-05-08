// lib/features/booking/presentation/providers/selected_workers_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

part 'selected_workers_provider.g.dart';

/// Provider that maps service IDs to selected workers.
///
/// This maintains the relationship between each selected service
/// and the worker chosen to perform it (if any).
///
/// ## Features
/// - Null values indicate no worker selected (for services that don't require one)
/// - Automatically cleans up when services are removed
/// - Used for worker availability checks
///
/// ## Usage
/// ```dart
/// // Get worker for a specific service
/// final worker = ref.watch(selectedWorkersProvider)[serviceId];
///
/// // Select a worker for a service
/// ref.read(selectedWorkersProvider.notifier).selectWorker(serviceId, worker);

@riverpod
class SelectedWorkers extends _$SelectedWorkers {
  // Store map of serviceId -> list of worker data (id and name)
  @override
  Map<String, List<Map<String, String?>>> build() => {};

  /// Initializes the list for a service based on quantity
  void initializeService(String serviceId, int quantity) {
    final current = Map<String, List<Map<String, String?>>>.from(state);
    // Create a list of null entries with the given length
    current[serviceId] = List.generate(
      quantity,
      (_) => {'id': null, 'name': null},
    );
    state = current;
  }

  /// Selects a worker for a specific person index in a service
  void selectWorker(
    String serviceId,
    int personIndex,
    String workerId,
    String workerName,
  ) {
    final current = Map<String, List<Map<String, String?>>>.from(state);
    final list = current[serviceId] ?? [];

    // Ensure list is long enough
    while (list.length <= personIndex) {
      list.add({'id': null, 'name': null});
    }

    list[personIndex] = {'id': workerId, 'name': workerName};
    current[serviceId] = list;
    state = current;
  }

  /// Resizes the list for a service when quantity changes
  void resizeService(String serviceId, int newQuantity) {
    final current = Map<String, List<Map<String, String?>>>.from(state);
    final existing = current[serviceId] ?? [];

    if (newQuantity > existing.length) {
      // Add null entries
      current[serviceId] = [
        ...existing,
        ...List.generate(
          newQuantity - existing.length,
          (_) => {'id': null, 'name': null},
        ),
      ];
    } else if (newQuantity < existing.length) {
      // Truncate
      current[serviceId] = existing.sublist(0, newQuantity);
    }
    // If no existing list, initialize with nulls
    else if (!current.containsKey(serviceId)) {
      current[serviceId] = List.generate(
        newQuantity,
        (_) => {'id': null, 'name': null},
      );
    }

    state = current;
  }

  /// Gets worker data for a specific person
  Map<String, String?>? getWorker(String serviceId, int personIndex) {
    final list = state[serviceId];
    if (list != null && personIndex >= 0 && personIndex < list.length) {
      return list[personIndex];
    }
    return null;
  }

  /// Gets worker ID for a specific person
  String? getWorkerId(String serviceId, int personIndex) {
    return getWorker(serviceId, personIndex)?['id'];
  }

  /// Gets worker name for a specific person
  String? getWorkerName(String serviceId, int personIndex) {
    return getWorker(serviceId, personIndex)?['name'];
  }

  /// Clears a specific person's selection
  void clearPerson(String serviceId, int personIndex) {
    final current = Map<String, List<Map<String, String?>>>.from(state);
    final list = current[serviceId];
    if (list != null && personIndex >= 0 && personIndex < list.length) {
      list[personIndex] = {'id': null, 'name': null};
      state = current;
    }
  }

  /// Removes a service entirely (when service is deselected)
  void removeService(String serviceId) {
    final current = Map<String, List<Map<String, String?>>>.from(state);
    current.remove(serviceId);
    state = current;
  }

  /// Checks if all persons for a service have a selected worker
  bool isServiceComplete(String serviceId) {
    final list = state[serviceId];
    if (list == null) return false;
    return list.every((entry) => entry['id'] != null);
  }

  /// Checks if all services that require workers have all persons selected
  bool areAllRequiredServicesComplete(List<AppointmentSlotDTO> services) {
    for (final service in services) {
      if (service.selectPreferredWorker) {
        if (!isServiceComplete(service.id)) return false;
      }
    }
    return true;
  }

  /// Clears all selections
  void clear() => state = {};
}
