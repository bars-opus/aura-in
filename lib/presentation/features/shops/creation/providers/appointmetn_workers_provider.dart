// lib/features/shop/workers/providers/workers_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/worker_unavailability_model.dart';
import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_appointment_worker_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/worker_invite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repository provider
final appointmentWorkerRepositoryProvider = Provider<WorkerRepository>((ref) {
  final client = Supabase.instance.client;
  return WorkerRepository(client);
});

// Active workers for a shop
final shopActiveWorkersProvider =
    FutureProvider.family<List<WorkerDTO>, String>((ref, shopId) async {
      final repository = ref.read(appointmentWorkerRepositoryProvider);
      return repository.getActiveWorkersForShop(shopId);
    });

// Pending invites for a shop
final shopPendingInvitesProvider =
    FutureProvider.family<List<WorkerInvite>, String>((ref, shopId) async {
      final repository = ref.read(appointmentWorkerRepositoryProvider);
      return repository.getPendingInvites(shopId);
    });

// Single worker by ID
final workerByIdProvider = FutureProvider.family<WorkerDTO?, String>((
  ref,
  workerId,
) async {
  final repository = ref.read(appointmentWorkerRepositoryProvider);
  try {
    final allWorkers = await repository.getAllWorkers();
    return allWorkers.firstWhere((w) => w.id == workerId);
  } catch (e) {
    return null;
  }
});

// Worker unavailability for a date range
final workerUnavailabilityProvider = FutureProvider.family<
  List<WorkerUnavailabilityModel>,
  ({String workerId, DateTime startDate, DateTime endDate})
>((ref, params) async {
  final repository = ref.read(appointmentWorkerRepositoryProvider);
  return repository.getWorkerUnavailability(
    workerId: params.workerId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});
