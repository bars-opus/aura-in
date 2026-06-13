// lib/features/booking/data/models/booking_flow_state.dart

import 'package:equatable/equatable.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';


/// Represents the temporary state during the multi-step booking flow.
///
/// This model holds the user's selections as they progress through:
/// 1. Service selection
/// 2. Worker selection (per service)
/// 3. Time slot selection
/// 4. Final confirmation
///
/// It is NOT persisted to database - only used in UI state management.
class BookingFlowState extends Equatable {
  /// Selected services with their slots
  final List<AppointmentSlotDTO> selectedServices;

  /// Map of serviceId -> selected worker (null if no worker needed)
  final Map<String, WorkerDTO?> selectedWorkers;

  /// Selected date for the booking
  final DateTime? selectedDate;

  /// Selected time slot (contains start/end times)
  final TimeSlotModel? selectedTimeSlot;

  /// Current step in the flow (0-3)
  final int currentStep;

  /// Whether the flow is complete and ready for submission
  final bool isComplete;

  const BookingFlowState({
    required this.selectedServices,
    required this.selectedWorkers,
    this.selectedDate,
    this.selectedTimeSlot,
    this.currentStep = 0,
    this.isComplete = false,
  });

  /// Initial empty state.
  factory BookingFlowState.initial() {
    return BookingFlowState(
      selectedServices: const [],
      selectedWorkers: const {},
      currentStep: 0,
      isComplete: false,
    );
  }

  /// Calculates total duration of all selected services.
  ///
  /// Parses the ISO 8601 duration strings from each service
  /// and sums them into a single Duration object.
  Duration get totalDuration {
    return selectedServices.fold<Duration>(
      Duration.zero,
      (sum, service) => sum + DurationUtils.parse(service.duration),
    );
  }

  /// Gets a human-readable string of the total duration.
  ///
  /// Example: "1h 30m"
  String get totalDurationDisplay {
    final duration = totalDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Phase 17: Calculates total price in int minor units (kobo for GHS).
  /// `AppointmentSlotDTO.price` is NUMERIC(12,2) major; we convert at the
  /// fold boundary.
  int get totalPriceMinor {
    return selectedServices.fold<int>(
      0,
      (sum, service) => sum + parseMoneyMinor(service.price),
    );
  }

  /// Checks if all required workers are selected.
  bool get hasAllWorkersSelected {
    for (final service in selectedServices) {
      if (service.selectPreferredWorker) {
        final worker = selectedWorkers[service.id];
        if (worker == null) return false;
      }
    }
    return true;
  }

  /// Checks if a specific service requires worker selection.
  bool serviceRequiresWorker(String serviceId) {
    final service = selectedServices.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => throw StateError('Service not found: $serviceId'),
    );
    return service.selectPreferredWorker;
  }

  /// Gets the selected worker for a service (if any).
  WorkerDTO? getWorkerForService(String serviceId) {
    return selectedWorkers[serviceId];
  }

  /// Creates a copy with updated fields.
  BookingFlowState copyWith({
    List<AppointmentSlotDTO>? selectedServices,
    Map<String, WorkerDTO?>? selectedWorkers,
    DateTime? selectedDate,
    TimeSlotModel? selectedTimeSlot,
    int? currentStep,
    bool? isComplete,
  }) {
    return BookingFlowState(
      selectedServices: selectedServices ?? this.selectedServices,
      selectedWorkers: selectedWorkers ?? this.selectedWorkers,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [
    selectedServices,
    selectedWorkers,
    selectedDate,
    selectedTimeSlot,
    currentStep,
    isComplete,
  ];
}
