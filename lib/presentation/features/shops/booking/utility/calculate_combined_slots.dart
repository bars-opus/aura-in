// Helper function to group slots by start time

import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

Map<String, List<TimeSlotModel>> _groupSlotsByStartTime(
  List<TimeSlotModel> slots,
) {
  final Map<String, List<TimeSlotModel>> slotsByStartTime = {};

  for (var slot in slots) {
    final timeKey = '${slot.startTime.hour}:${slot.startTime.minute}';
    slotsByStartTime.putIfAbsent(timeKey, () => []).add(slot);
  }

  return slotsByStartTime;
}

// Helper function to check if all services have slots at a given start time
bool _allServicesHaveSlotsAtTime(
  List<TimeSlotModel> timeSlots,
  List<AppointmentSlotDTO> selectedServices,
  Map<String, TimeSlotModel> serviceSlotMap,
) {
  for (var service in selectedServices) {
    TimeSlotModel? foundSlot;

    for (var slot in timeSlots) {
      if (slot.slotId == service.id) {
        foundSlot = slot;

        break;
      }
    }

    if (foundSlot == null) {
      return false;
    }

    serviceSlotMap[service.id] = foundSlot;
  }

  return true;
}

// Helper function to calculate the latest end time from a list of slots
DateTime _getLatestEndTime(List<TimeSlotModel> slots) {
  DateTime latestEndTime = slots.first.endTime;

  for (var slot in slots) {
    if (slot.endTime.isAfter(latestEndTime)) {
      latestEndTime = slot.endTime;
    }
  }
  return latestEndTime;
}

// Phase 17: Helper to fold the combined slot price in int kobo.
// AppointmentSlotDTO.price is NUMERIC major; boundary-convert each fold.
int _calculateCombinedPriceMinor(List<AppointmentSlotDTO> services) {
  return services.fold<int>(
    0,
    (sum, service) => sum + parseMoneyMinor(service.price),
  );
}

// Helper function to create a combined slot

TimeSlotModel _createCombinedSlot(
  DateTime startTime,
  DateTime endTime,
  List<AppointmentSlotDTO> services,
  List<WorkerDTO>? availableWorkers,
  Map<String, TimeSlotModel> serviceSlotMap, // Add this to get buffer info
) {
  // Calculate total buffer needed for combined service
  // When booking multiple services together, you need buffer AFTER each service
  // For example: Service1 (60 min) + buffer + Service2 (90 min) + buffer
  // Total buffer = (number of services) × max(buffer per service)

  // Get the maximum buffer from all services
  int maxBuffer = 0;
  Duration totalBufferDuration = Duration.zero;

  for (var service in services) {
    final slot = serviceSlotMap[service.id];
    if (slot != null && slot.bufferMinutes != null) {
      if (slot.bufferMinutes! > maxBuffer) {
        maxBuffer = slot.bufferMinutes!;
      }
      // Each service needs its own buffer after it
      totalBufferDuration += Duration(minutes: slot.bufferMinutes ?? 0);
    }
  }

  // If no buffer info, use default 5 minutes per service
  if (maxBuffer == 0) {
    maxBuffer = 5;
    totalBufferDuration = Duration(minutes: 5 * services.length);
  }
  // Calculate actual end time including all buffers
  final actualEndTime = endTime.add(totalBufferDuration);

  return TimeSlotModel(
    startTime: startTime,
    endTime: endTime, // Service time only
    actualEndTime: actualEndTime, // Include all buffers
    slotId: 'combined_${startTime.toIso8601String()}',
    serviceName: 'Combined Services',
    priceMinor: _calculateCombinedPriceMinor(services),
    availableWorkers: availableWorkers ?? [],
    remainingSpots: 1,
    requiresWorkerSelection: false,
    bufferMinutes: maxBuffer, // Store the max buffer per service
  );
}
// TimeSlotModel _createCombinedSlot(
//   DateTime startTime,
//   DateTime endTime,
//   List<AppointmentSlotDTO> services,
//   List<WorkerDTO>? availableWorkers,
// ) {
//   // print(
//   //   '✨ Creating combined slot: ${startTime.hour}:${startTime.minute} - ${endTime.hour}:${endTime.minute}',
//   // );

//   return TimeSlotModel(
//     startTime: startTime,
//     endTime: endTime,
//     slotId: 'combined_${startTime.toIso8601String()}',
//     serviceName: 'Combined Services',
//     priceMinor: _calculateCombinedPriceMinor(services),
//     availableWorkers: availableWorkers ?? [],
//     remainingSpots: 1,
//     requiresWorkerSelection: false,
//     actualEndTime: null,
//     bufferMinutes: null,
//   );
// }

// Helper function to filter and create combined slots
// Helper function to filter and create combined slots
List<TimeSlotModel> generateCombinedSlots(
  List<TimeSlotModel> slots,
  List<AppointmentSlotDTO> selectedServices,
) {

  // Group slots by start time
  final slotsByStartTime = _groupSlotsByStartTime(slots);
  final List<TimeSlotModel> combinedSlots = [];

  // Process each start time group
  slotsByStartTime.forEach((timeKey, timeSlots) {

    final Map<String, TimeSlotModel> serviceSlotMap = {};

    // Check if all services have slots at this time
    if (_allServicesHaveSlotsAtTime(
      timeSlots,
      selectedServices,
      serviceSlotMap,
    )) {
      // Calculate TOTAL duration by ADDING all service durations
      Duration totalDuration = Duration.zero;
      for (var service in selectedServices) {
        final slot = serviceSlotMap[service.id]!;
        final slotDuration = slot.endTime.difference(slot.startTime);
        totalDuration += slotDuration;
      }
      // Create combined slot with start time and end time = start + totalDuration
      final startTime = timeSlots.first.startTime;
      final endTime = startTime.add(totalDuration);

      // Get available workers (you might want to combine from all slots)
      final availableWorkers = timeSlots.first.availableWorkers;

      // Create and add the combined slot
      final combinedSlot = _createCombinedSlot(
        startTime,
        endTime,
        selectedServices,
        availableWorkers,
        serviceSlotMap,
      );

      combinedSlots.add(combinedSlot);
    } else {
    }
  });

  // Sort combined slots by start time
  combinedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));


  return combinedSlots;
}
