// lib/features/booking/presentation/providers/booking_data_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_logger.dart';

part 'booking_data_providers.g.dart';

/// Provider for fetching appointment slots for the selected shop
@riverpod
Future<List<AppointmentSlotDTO>> shopAppointmentSlots(
  ShopAppointmentSlotsRef ref, {
  required String shopId,
}) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository
      .getAppointmentSlots(shopId)
      .then((slots) => slots.cast<AppointmentSlotDTO>().toList());
}

/// Provider for fetching all workers for the selected shop
/// Provider for fetching all workers for the selected shop
@riverpod
Future<List<WorkerDTO>> shopWorkers(
  ShopWorkersRef ref, {
  required String shopId,
}) {
  final repository = ref.watch(
    shopRepositoryProvider,
  ); // ← This should return List<WorkerDTO>
  return repository
      .getWorkers(shopId) // ← This must return List<WorkerDTO>
      .then((workers) => workers.cast<WorkerDTO>().toList());
}

/// Provider for fetching slot-worker assignments for the selected shop
@riverpod
Future<Map<String, List<String>>> slotWorkerAssignments(
  SlotWorkerAssignmentsRef ref, {
  required String shopId,
}) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getSlotWorkerAssignments(shopId);
}

/// Combined provider that returns workers for a specific slot
/// This combines shopWorkers and slotWorkerAssignments
@riverpod
/// Combined provider that returns workers for a specific slot
@riverpod
Future<List<WorkerDTO>> workersForSlot(
  WorkersForSlotRef ref, {
  required String shopId,
  required String slotId,
}) async {
  BookingLogger.debug(
    'workersForSlot.start shopId=$shopId slotId=$slotId',
  );

  final workers = await ref.watch(shopWorkersProvider(shopId: shopId).future);
  final assignments = await ref.watch(
    slotWorkerAssignmentsProvider(shopId: shopId).future,
  );

  final workerIds = assignments[slotId] ?? const <String>[];
  final result = workers.where((w) => workerIds.contains(w.id)).toList();

  BookingLogger.debug(
    'workersForSlot.done shopId=$shopId slotId=$slotId '
    'totalWorkers=${workers.length} matched=${result.length}',
  );

  return result;
}

// NEW: Combined provider with both parameters - CORRECTED SYNTAX
final workersForSlotWithShopProvider =
    FutureProvider.family<List<WorkerDTO>, ({String shopId, String slotId})>((
      ref,
      params,
    ) async {
      // Store parameters in variables for clarity
      final shopId = params.shopId;
      final slotId = params.slotId;

      // Get the providers with parameters
      final workersProvider = shopWorkersProvider(shopId: shopId);
      final assignmentsProvider = slotWorkerAssignmentsProvider(shopId: shopId);

      // Watch their futures
      final workers = await ref.watch(workersProvider.future);
      final assignments = await ref.watch(assignmentsProvider.future);

      final workerIds = assignments[slotId] ?? [];
      return workers.where((w) => workerIds.contains(w.id)).toList();
    });
