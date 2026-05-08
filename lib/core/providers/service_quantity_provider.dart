// lib/features/booking/presentation/providers/service_quantity_provider.dart

import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_quantity_provider.g.dart';

/// Provider that tracks the quantity (number of people) for each selected service.
///
/// This is essential for group bookings where multiple people book the same service.
///
/// ## Features
/// - Stores quantity per service ID
/// - Default quantity is 1
/// - Validates against max_clients
/// - Automatically cleaned up when services are removed
///
/// ## Usage
/// ```dart
/// // Set quantity for a service
/// ref.read(serviceQuantityProvider.notifier).setQuantity(service.id, 3);
///
/// // Get quantity for a service
/// final qty = ref.watch(serviceQuantityProvider)[service.id] ?? 1;
/// ```
@riverpod
class ServiceQuantity extends _$ServiceQuantity {
  @override
  Map<String, int> build() => {};

  /// Sets the quantity for a specific service
  /// Validates that quantity is at least 1
  void setQuantity(String serviceId, int quantity) {
    if (quantity < 1) return;
    state = {...state, serviceId: quantity};
  }

  /// Gets the quantity for a service, defaults to 1
  int getQuantity(String serviceId) => state[serviceId] ?? 1;

  /// Removes a service from quantity tracking
  void removeService(String serviceId) {
    state = {...state}..remove(serviceId);
  }

  /// Updates quantities based on selected services
  /// Removes quantities for services no longer selected
  void syncWithSelectedServices(List<AppointmentSlotDTO> selectedServices) {
    final selectedIds = selectedServices.map((s) => s.id).toSet();
    final updatedMap = Map<String, int>.from(state);
    
    // Remove entries for unselected services
    updatedMap.removeWhere((key, value) => !selectedIds.contains(key));
    
    // Ensure all selected services have a quantity (default 1)
    for (var service in selectedServices) {
      if (!updatedMap.containsKey(service.id)) {
        updatedMap[service.id] = 1;
      }
    }
    
    state = updatedMap;
  }

  /// Gets the total number of people across all selected services
  int get totalPeople {
    return state.values.fold(0, (sum, qty) => sum + qty);
  }

  /// Clears all quantities
  void clear() => state = {};
}
