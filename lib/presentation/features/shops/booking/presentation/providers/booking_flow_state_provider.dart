// lib/features/booking/presentation/providers/booking_flow_state_provider.dart
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';


part 'booking_flow_state_provider.g.dart';

/// Provider that combines all booking flow states into a single cohesive state.
///
/// This provider watches the individual providers and combines them
/// into a [BookingFlowState] object for easy consumption by UI components.
///
/// ## Features
/// - Automatically updates when any dependent provider changes
/// - Calculates derived values (total duration, price, completion status)
/// - Provides a single source of truth for the booking flow
///
/// ## Usage
/// ```dart
/// final flowState = ref.watch(bookingFlowStateProvider);
/// if (flowState.isComplete) {
///   // Proceed to payment
/// }

/// Represents the complete state of the booking flow.
///
/// This class combines all selections into a single immutable object
/// for easy consumption by UI components.
class BookingFlowState extends Equatable {
  final List<AppointmentSlotDTO> selectedServices;
  final Map<String, List<String?>> selectedWorkers; // Updated type
  final DateTime? selectedDate;
  final int currentStep;
  final bool isComplete;
  final int totalPeople;

  /// Phase 17: int minor units (kobo for GHS). Folded by the booking flow
  /// from `TimeSlotModel.priceMinor` / `AppointmentSlotDTO.priceMinor`.
  final int totalPriceMinor;

  final Duration totalDuration;
  final Map<String, TimeSlotModel> selectedTimeSlots; // ← Changed
  final bool isCombinedView; // ← New

  const BookingFlowState({
    required this.selectedServices,
    required this.selectedWorkers,
    required this.selectedDate,
    required this.selectedTimeSlots,
    required this.isCombinedView, // ← New
    required this.currentStep,
    required this.isComplete,
    required this.totalPeople,
    required this.totalPriceMinor,
    required this.totalDuration,
  });

  /// Creates an initial empty state.
  factory BookingFlowState.initial() {
    return BookingFlowState(
      selectedServices: const [],
      selectedWorkers: const {},
      selectedDate: null,
      selectedTimeSlots: const {},
      currentStep: 0,
      isComplete: false,
      totalPeople: 0,
      totalPriceMinor: 0,
      totalDuration: Duration.zero,
      isCombinedView: false,
    );
  }

  /// Creates a copy of this state with optional new values.
  BookingFlowState copyWith({
    List<AppointmentSlotDTO>? selectedServices,
    Map<String, List<String?>>? selectedWorkers, // Updated type
    DateTime? selectedDate,
    Map<String, TimeSlotModel>? selectedTimeSlots,
    int? currentStep,
    bool? isComplete,
    int? totalPeople,
    int? totalPriceMinor,
    Duration? totalDuration,
    bool? isCombinedView,
  }) {
    return BookingFlowState(
      selectedServices: selectedServices ?? this.selectedServices,
      selectedWorkers:
          selectedWorkers ?? this.selectedWorkers, // This line is now correct
      selectedDate: selectedDate ?? this.selectedDate,
      isCombinedView: isCombinedView ?? this.isCombinedView,
      selectedTimeSlots: selectedTimeSlots ?? this.selectedTimeSlots,
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
      totalPeople: totalPeople ?? this.totalPeople,
      totalPriceMinor: totalPriceMinor ?? this.totalPriceMinor,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  @override
  List<Object?> get props => [
    selectedServices,
    selectedWorkers,
    selectedDate,
    selectedTimeSlots,
    isCombinedView,
    currentStep,
    isComplete,
    totalPeople,
    totalPriceMinor,
    totalDuration,
  ];
}

/// Provider that combines all booking flow states into a single cohesive state.
///
/// This provider watches the individual providers and combines them
/// into a [BookingFlowState] object for easy consumption by UI components.
///
/// ## Features
/// - Automatically updates when any dependent provider changes
/// - Calculates derived values (total duration, price, people, completion status)
/// - Provides a single source of truth for the booking flow
///
/// ## Usage
/// ```dart
/// final flowState = ref.watch(bookingFlowStateProvider);
/// if (flowState.isComplete) {
///   // Proceed to payment
/// }
/// ```

@riverpod
BookingFlowState bookingFlowState(BookingFlowStateRef ref) {
  // Watch all dependent providers
  final services = ref.watch(selectedServicesProvider);
  final workersData = ref.watch(
    selectedWorkersProvider,
  ); // Map<String, List<Map<String, String?>>>
  final date = ref.watch(selectedDateProvider);
  final timeSlots = ref.watch(
    selectedTimeSlotsProvider,
  ); // Map<String, TimeSlotModel>
  final isCombinedView = ref.watch(isCombinedViewProvider);
  final quantities = ref.watch(serviceQuantityProvider);

  // Convert workers to IDs only for step calculation
  final selectedWorkerIdsOnly = <String, List<String?>>{};
  workersData.forEach((serviceId, workerEntries) {
    selectedWorkerIdsOnly[serviceId] =
        workerEntries.map((entry) => entry['id']).toList();
  });

  // Check if all required workers are selected
  final workersSelected = _areAllWorkersSelected(services, workersData);

  // Check if all slots are selected (based on view mode)
  final allSlotsSelected =
      isCombinedView
          ? timeSlots
              .isNotEmpty // Combined view: at least one slot
          : services.every(
            (s) => timeSlots.containsKey(s.id),
          ); // Regular view: slot per service

  // Calculate derived values
  final totalPeople = _calculateTotalPeople(services, quantities);
  // Phase 17: fold in int kobo. `_calculateTotalPriceMinor` converts each
  // service's NUMERIC price at the boundary via `parseMoneyMinor`.
  final totalPriceMinor = _calculateTotalPriceMinor(services, quantities);
  final totalDuration = _calculateTotalDuration(services, quantities);

  final currentStep = _calculateCurrentStep(
    services,
    selectedWorkerIdsOnly,
    timeSlots, // ← Pass timeSlots, not timeSlot
    quantities,
    isCombinedView, // ← Add this
  );

  final isComplete = _isFlowComplete(
    services,
    selectedWorkerIdsOnly,
    timeSlots, // ← Pass timeSlots, not timeSlot
    quantities,
    isCombinedView, // ← Add this
  );

  return BookingFlowState(
    selectedServices: services,
    selectedWorkers: selectedWorkerIdsOnly,
    selectedDate: date,
    selectedTimeSlots: timeSlots, // ← Changed from selectedTimeSlot
    isCombinedView: isCombinedView, // ← Add this to state
    currentStep: currentStep,
    isComplete: isComplete,
    totalPeople: totalPeople,
    totalPriceMinor: totalPriceMinor,
    totalDuration: totalDuration,
  );
}

/// Helper to determine if all required workers are selected
bool _areAllWorkersSelected(
  List<AppointmentSlotDTO> services,
  Map<String, List<Map<String, String?>>> workersData,
) {
  for (final service in services) {
    if (service.selectPreferredWorker) {
      final workerList = workersData[service.id];
      if (workerList == null) return false;
      // All entries must have non-null IDs
      if (workerList.any((entry) => entry['id'] == null)) return false;
    }
  }
  return true;
}

/// Helper to determine current step based on selections
int _calculateCurrentStep(
  List<AppointmentSlotDTO> services,
  Map<String, List<String?>> workers,
  Map<String, TimeSlotModel> timeSlots,
  Map<String, int> quantities,
  bool isCombinedView,
) {
  if (services.isEmpty) return 0;

  // Check if any service that requires workers is missing selections
  for (final service in services) {
    if (service.selectPreferredWorker) {
      final workerList = workers[service.id];
      final quantity = quantities[service.id] ?? 1;

      // If list doesn't exist or has wrong length or has nulls
      if (workerList == null ||
          workerList.length != quantity ||
          workerList.any((id) => id == null)) {
        return 1; // Still on worker selection step
      }
    }
  }

  // Check time slot selection based on view mode
  if (isCombinedView) {
    if (timeSlots.isEmpty) return 2; // No slot selected in combined view
  } else {
    if (!services.every((s) => timeSlots.containsKey(s.id)))
      return 2; // Missing some slots
  }

  return 3; // Ready for confirmation
}

/// Helper to determine if flow is complete
bool _isFlowComplete(
  List<AppointmentSlotDTO> services,
  Map<String, List<String?>> workers,
  Map<String, TimeSlotModel> timeSlots,
  Map<String, int> quantities,
  bool isCombinedView,
) {
  if (services.isEmpty) return false;

  // Check all required workers are selected
  for (final service in services) {
    if (service.selectPreferredWorker) {
      final workerList = workers[service.id];
      final quantity = quantities[service.id] ?? 1;

      if (workerList == null ||
          workerList.length != quantity ||
          workerList.any((id) => id == null)) {
        return false;
      }
    }
  }

  // Check time slots based on view mode
  if (isCombinedView) {
    if (timeSlots.isEmpty) return false;
  } else {
    if (!services.every((s) => timeSlots.containsKey(s.id))) return false;
  }

  // Verify quantities don't exceed max_clients
  for (final service in services) {
    final requestedQty = quantities[service.id] ?? 1;
    if (requestedQty > service.maxClients) return false;
  }

  return true;
}

/// Calculates the total duration across all selected services with quantities
/// Note: For group bookings, duration is multiplied by quantity (sequential service)
Duration _calculateTotalDuration(
  List<AppointmentSlotDTO> services,
  Map<String, int> quantities,
) {
  return services.fold<Duration>(Duration.zero, (sum, service) {
    final serviceDuration = _parseDuration(service.duration);
    final quantity = quantities[service.id] ?? 1;
    return sum + (serviceDuration * quantity);
  });
}

/// Incremented by BookingFlowScreen when the user presses "Book" on the
/// Confirm tab. BookingConfirmationScreen listens and opens the payment dialog.
final bookingPaymentTriggerProvider = StateProvider<int>((ref) => 0);

/// Provider that gives just the total number of people
final totalPeopleProvider = Provider<int>((ref) {
  final services = ref.watch(selectedServicesProvider);
  final quantities = ref.watch(serviceQuantityProvider);
  return _calculateTotalPeople(services, quantities);
});

/// Phase 17: provider that gives just the total price in int minor units (kobo).
/// Old name `totalPriceProvider` is renamed to make the unit explicit.
final totalPriceMinorProvider = Provider<int>((ref) {
  final services = ref.watch(selectedServicesProvider);
  final quantities = ref.watch(serviceQuantityProvider);
  return _calculateTotalPriceMinor(services, quantities);
});

/// Provider that gives just the total duration
final totalDurationProvider = Provider<Duration>((ref) {
  final services = ref.watch(selectedServicesProvider);
  final quantities = ref.watch(serviceQuantityProvider);
  return _calculateTotalDuration(services, quantities);
});

/// Calculates the total number of people across all selected services
int _calculateTotalPeople(
  List<AppointmentSlotDTO> services,
  Map<String, int> quantities,
) {
  return services.fold<int>(
    0,
    (sum, service) => sum + (quantities[service.id] ?? 1),
  );
}

/// Phase 17: Calculates the total price in int minor units (kobo for GHS).
/// `AppointmentSlotDTO.price` is NUMERIC(12,2) major units; we convert at the
/// boundary via `parseMoneyMinor` and fold in int.
int _calculateTotalPriceMinor(
  List<AppointmentSlotDTO> services,
  Map<String, int> quantities,
) {
  return services.fold<int>(
    0,
    (sum, service) =>
        sum + parseMoneyMinor(service.price) * (quantities[service.id] ?? 1),
  );
}

/// Helper to parse duration string to Duration
Duration _parseDuration(String durationString) {
  // Simple parser - in production use DurationUtils
  if (durationString.startsWith('PT')) {
    final hours = _extractNumber(durationString, 'H');
    final minutes = _extractNumber(durationString, 'M');
    return Duration(hours: hours, minutes: minutes);
  }
  return Duration.zero;
}

int _extractNumber(String input, String unit) {
  final regex = RegExp('(\\d+)$unit');
  final match = regex.firstMatch(input);
  if (match != null) {
    return int.parse(match.group(1)!);
  }
  return 0;
}
