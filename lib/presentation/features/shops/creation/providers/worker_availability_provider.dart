// lib/features/shop/workers/providers/worker_availability_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/worker_unavailability_model.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/appointment_slot_add_workers_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/appointmetn_workers_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_appointment_worker_repository.dart';

// Provider for worker unavailability within a date range
final workerUnavailabilityProvider = FutureProvider.family<
  List<WorkerUnavailabilityModel>,
  ({
    String workerId,
    DateTime startDate,
    DateTime endDate
  })
>((ref, params) async {
  final repository = ref.read(workerRepositoryProvider);
  return repository.getWorkerUnavailability(
    workerId: params.workerId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

// Notifier for managing unavailability state
class WorkerAvailabilityNotifier extends StateNotifier<AsyncValue<List<WorkerUnavailabilityModel>>> {
  final WorkerRepository _repository;
  final String _workerId;

  WorkerAvailabilityNotifier({
    required WorkerRepository repository,
    required String workerId,
  }) : _repository = repository,
       _workerId = workerId,
       super(const AsyncValue.loading()) {
    _loadUnavailability();
  }

  Future<void> _loadUnavailability() async {
    try {
      // Load for next 90 days
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: 90));
      final data = await _repository.getWorkerUnavailability(
        workerId: _workerId,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addUnavailability({
    required DateTime startTime,
    required DateTime endTime,
    String? reason,
  }) async {
    try {
      await _repository.addUnavailability(
        workerId: _workerId,
        startTime: startTime,
        endTime: endTime,
        reason: reason,
      );
      await _loadUnavailability();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeUnavailability(String unavailabilityId) async {
    try {
      await _repository.removeUnavailability(unavailabilityId);
      await _loadUnavailability();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUnavailability({
    required String unavailabilityId,
    required DateTime startTime,
    required DateTime endTime,
    String? reason,
  }) async {
    try {
      await _repository.updateUnavailability(
        unavailabilityId: unavailabilityId,
        startTime: startTime,
        endTime: endTime,
        reason: reason,
      );
      await _loadUnavailability();
    } catch (e) {
      rethrow;
    }
  }

  void refresh() {
    _loadUnavailability();
  }
}

final workerAvailabilityProvider = StateNotifierProvider.family<
  WorkerAvailabilityNotifier,
  AsyncValue<List<WorkerUnavailabilityModel>>,
  String
>((ref, workerId) {
  final repository = ref.read(workerRepositoryProvider);
  return WorkerAvailabilityNotifier(
    repository: repository,
    workerId: workerId,
  );
});
