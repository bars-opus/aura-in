// lib/features/shop/workers/providers/workers_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_appointment_worker_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Simple provider - no code generation needed
final workersProvider = FutureProvider.family<List<WorkerDTO>, String>((
  ref,
  shopId,
) async {
  final repository = ref.read(workerRepositoryProvider);
  return repository.getActiveWorkersForShop(shopId); // Use the correct method
});

final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  final client = Supabase.instance.client;
  return WorkerRepository(client);
});
