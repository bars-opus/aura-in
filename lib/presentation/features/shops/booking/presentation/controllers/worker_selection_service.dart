// lib/features/booking/domain/services/worker_selection_service.dart


import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';

/// Service class for worker selection logic
/// This replaces the old WorkerSelectionHelper
class WorkerSelectionService {
  /// Get available workers for a specific slot
  static List<WorkerDTO> filterWorkersForSlot(
    List<WorkerDTO> allWorkers,
    Map<String, List<String>> assignments,
    String slotId,
  ) {
    final workerIds = assignments[slotId] ?? [];
    return allWorkers.where((w) => workerIds.contains(w.id)).toList();
  }

  /// Check if a worker can perform a specific slot
  static bool canWorkerPerformSlot(
    String workerId,
    String slotId,
    Map<String, List<String>> assignments,
  ) {
    final workerIds = assignments[slotId] ?? [];
    return workerIds.contains(workerId);
  }

  /// Get worker by ID
  static WorkerDTO? getWorkerById(
    List<WorkerDTO> workers,
    String workerId,
  ) {
    try {
      return workers.firstWhere((w) => w.id == workerId);
    } catch (e) {
      return null;
    }
  }

  /// Format worker display name with specialty
  static String getWorkerDisplayName(WorkerDTO worker) {
    if (worker.specialties.isEmpty) return worker.name;
    return '${worker.name} (${worker.specialties.first})';
  }

  /// Group workers by their specialties
  static Map<String, List<WorkerDTO>> groupWorkersBySpecialty(
    List<WorkerDTO> workers,
  ) {
    final Map<String, List<WorkerDTO>> grouped = {};
    for (var worker in workers) {
      for (var specialty in worker.specialties) {
        grouped.putIfAbsent(specialty, () => []).add(worker);
      }
    }
    return grouped;
  }
}
