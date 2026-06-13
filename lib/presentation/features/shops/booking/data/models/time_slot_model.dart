// lib/features/booking/data/models/time_slot_model.dart
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/core/utils/timezone_utils.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';



/// Represents a generated available time slot for display in the UI.
///
/// This is NOT a database model - it's generated on-the-fly based on
/// appointment_slot templates, shop hours, and existing bookings.
///
/// ## Example
/// ```dart
/// final slot = TimeSlotModel(
///   startTime: DateTime(2024, 2, 1, 9, 0),
///   endTime: DateTime(2024, 2, 1, 10, 0),
///   slotId: 'slot_haircut',
///   serviceName: 'Haircut',
///   availableWorkers: [worker1, worker2],
///   remainingSpots: 2,
/// );

class TimeSlotModel extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final String slotId;
  final String serviceName;

  /// Effective (post-override) price in minor units (kobo for GHS).
  /// This is what the client pays. Pre-Phase 15 this was the slot's
  /// base price; from Phase 15 the server applies any matching
  /// pricing_override and emits the adjusted value here.
  ///
  /// Phase 17: int minor units. The server returns NUMERIC(12,2) major
  /// units; `parseMoneyMinor` converts at the fromJson boundary.
  final int priceMinor;

  /// Phase 15: pre-override base price (unmodified `slot.price`).
  /// Null when the RPC predates Phase 15 (back-compat shim — the chip
  /// silently does not render). When non-null and `basePriceMinor != priceMinor`,
  /// the slot card surfaces a "Discount" or "Surcharge" chip.
  ///
  /// Phase 17: int minor units. NULL when the server doesn't emit it.
  final int? basePriceMinor;

  final List<WorkerDTO> availableWorkers;
  final int? remainingSpots; // For group slots with max_clients > 1
  final bool requiresWorkerSelection;
  final int bufferMinutes; // Add this
  final DateTime actualEndTime; // Add this - includes buffer

  const TimeSlotModel({
    required this.startTime,
    required this.endTime,
    required this.slotId,
    required this.serviceName,
    required this.actualEndTime, // New field
    required this.priceMinor,
    this.basePriceMinor, // Phase 15
    required this.availableWorkers,
    this.remainingSpots,
    required this.requiresWorkerSelection,
    required this.bufferMinutes, // New field
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      slotId: json['slot_id'] as String,
      actualEndTime: DateTime.parse(json['actual_end_time'] as String),
      serviceName: json['service_name'] as String,
      // Phase 17: server returns NUMERIC(12,2) major units; boundary-convert.
      priceMinor: parseMoneyMinor(json['price'] as num),
      basePriceMinor: json['base_price'] == null
          ? null
          : parseMoneyMinor(json['base_price'] as num),
      availableWorkers:
          (json['available_workers'] as List<dynamic>)
              .map(
                (workerJson) =>
                    WorkerDTO.fromJson(workerJson as Map<String, dynamic>),
              )
              .toList(),
      remainingSpots: json['remaining_spots'] as int?,
      requiresWorkerSelection: json['requires_worker_selection'] as bool,
      bufferMinutes: json['buffer_minutes'] as int? ?? 0,
    );
  }

  /// Phase 15: true when this slot's effective price differs from its
  /// base (an override applied). Drives the "Discount" / "Surcharge"
  /// chip in the time-picker card.
  bool get hasAdjustedPrice =>
      basePriceMinor != null && basePriceMinor! != priceMinor;

  /// Phase 15: true when this slot is discounted.
  bool get isDiscounted => hasAdjustedPrice && priceMinor < basePriceMinor!;

  /// Phase 15: true when this slot is surcharged.
  bool get isSurcharged => hasAdjustedPrice && priceMinor > basePriceMinor!;

  /// Creates a display-friendly time range string.
  ///
  /// Uses a consistent time format throughout the app.
  /// Example: "9:00 AM - 10:00 AM"
  String get timeRangeDisplay {
    // Using DateFormat from intl package (already in Flutter)
    // final format = TimeOfDayFormat(); // You might have a custom formatter

    // Option 1: Using your existing DateUtils if available
    // return '${formatTime(startTime)} - ${formatTime(endTime)}';

    // Option 2: Using MaterialLocalizations (recommended for locale-aware)
    // But requires context, so not suitable here

    // Option 3: Simple implementation using intl package
    final timeFormat = DateFormat.jm(); // Returns "9:00 AM" format
    return TimezoneUtils.formatTimeRange(startTime, endTime);
    // '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}';
  }

  /// Display time in device's local timezone
  String get localTimeRangeDisplay =>
      TimezoneUtils.formatTimeRange(startTime, endTime);

  /// Display with timezone indicator
  String get timeRangeWithTimezone =>
      TimezoneUtils.formatTimeRangeWithTimezone(startTime, endTime);

  /// Display time range with buffer (for shop/worker view)
  String get timeRangeWithBufferDisplay {
    return '${_formatTime(startTime)} - ${_formatTime(actualEndTime)} (inc. ${bufferMinutes}min buffer)';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  @override
  List<Object?> get props => [
    startTime,
    endTime,
    actualEndTime,
    slotId,
    serviceName,
    priceMinor,
    basePriceMinor,
    availableWorkers,
    remainingSpots,
    requiresWorkerSelection,
    bufferMinutes,
  ];

  /// Alternative: If you have a custom TimeOfDayFormat helper
  String get timeRangeDisplayCustom {
    // Assuming you have a helper method in core/utils
    final start = _formatTimeOfDay(startTime);
    final end = _formatTimeOfDay(endTime);
    return '$start - $end';
  }

  // Private helper if needed
  String _formatTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  /// Checks if this slot has any available workers.
  bool get hasAvailableWorkers => availableWorkers.isNotEmpty;

  /// Checks if this is a group slot with capacity.
  bool get isGroupSlot => remainingSpots != null && remainingSpots! > 1;

  /// Returns the appropriate display text for availability.
  String get availabilityDisplay {
    if (isGroupSlot) {
      return '$remainingSpots spots available';
    }
    if (requiresWorkerSelection) {
      return '${availableWorkers.length} workers available';
    }
    return 'Available';
  }
}
