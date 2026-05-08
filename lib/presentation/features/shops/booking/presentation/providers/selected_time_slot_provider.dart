// lib/features/booking/presentation/providers/selected_time_slot_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';


part 'selected_time_slot_provider.g.dart';

/// Provider that holds the currently selected time slot.
///
/// Simple state provider that tracks which time slot the user has chosen.
/// Initializes to null (no selection).
///
/// ## Features
/// - Used in final booking creation
/// - Triggers flow completion when set
///
/// ## Usage
/// ```dart
/// final slot = ref.watch(selectedTimeSlotProvider);
/// ref.read(selectedTimeSlotProvider.notifier).state = timeSlot;
/// ```
@riverpod
class SelectedTimeSlots extends _$SelectedTimeSlots {
  @override
  Map<String, TimeSlotModel> build() => {};

  /// Select a slot for a specific service (regular view)
  void selectSlotForService(String serviceId, TimeSlotModel slot) {
    state = {...state, serviceId: slot};
  }

  /// Select a single slot for all services (combined view)
  void selectCombinedSlot(TimeSlotModel slot, List<AppointmentSlotDTO> services) {
    // Clear any previous selections and set the same slot for all services
    final newState = <String, TimeSlotModel>{};
    for (var service in services) {
      newState[service.id] = slot;
    }
    state = newState;
  }

  /// Get the selected slot for a specific service
  TimeSlotModel? getSlotForService(String serviceId) => state[serviceId];

  /// Check if all services have a slot selected
  bool areAllServicesSelected(List<AppointmentSlotDTO> services) {
    return services.every((service) => state.containsKey(service.id));
  }

  /// Clear all selections
  void clear() => state = {};

  /// Remove a specific service selection
  void removeService(String serviceId) {
    state = {...state}..remove(serviceId);
  }
}
