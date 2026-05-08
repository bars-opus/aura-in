// lib/features/booking/presentation/providers/selected_services_provider.dart

import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_services_provider.g.dart';

/// Provider that holds the currently selected services in the booking flow.
///
/// This is a simple [StateProvider] because it just holds a list of selected
/// services without complex business logic.
///
/// ## Features
/// - Tracks multiple service selections
/// - Maintains order of selection
/// - Used to calculate total duration and price
///
/// ## Usage
/// ```dart
/// // Read current value
/// final selected = ref.watch(selectedServicesProvider);
///
/// // Update value
/// ref.read(selectedServicesProvider.notifier).state = newList;
/// ```
@riverpod
class SelectedServices extends _$SelectedServices {
  @override
  List<AppointmentSlotDTO> build() => [];

  /// Adds a service to the selection if not already present
  void addService(AppointmentSlotDTO service) {
    if (!state.any((s) => s.id == service.id)) {
      state = [...state, service];
    }
  }

  /// Removes a service from the selection
  void removeService(String serviceId) {
    state = state.where((s) => s.id != serviceId).toList();
  }

  /// Toggles a service selection
  void toggleService(AppointmentSlotDTO service) {
    if (state.any((s) => s.id == service.id)) {
      removeService(service.id);
    } else {
      addService(service);
    }
  }

  /// Clears all selected services
  void clear() => state = [];
}
