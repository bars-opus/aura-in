// all_workers_for_shop_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';

final allWorkersForShopProvider = FutureProvider.family<List<WorkerDTO>, String>((ref, shopId) async {
  final repository = ref.read(shopRepositoryProvider);
  return repository.getAllWorkersForShop(shopId);
});
