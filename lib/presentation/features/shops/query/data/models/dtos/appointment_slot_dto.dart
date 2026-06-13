// lib/features/shops/data/dtos/appointment_slot_dto.dart

// ignore: depend_on_referenced_packages
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_addon_dto.dart';

class AppointmentSlotDTO {
  final String id;
  final String serviceName;
  final String? serviceType;
  final String? description;
  final String duration; // ISO 8601 duration string
  final int price; // minor units (e.g. kobo, cents)
  final String slotType;
  final int maxClients;
  final List<int> daysOfWeek;
  final bool selectPreferredWorker;
  final List<String> workerIds;
  final int bufferMinutes;
  final int bufferBeforeMinutes;
  final bool isOnlineBookingEnabled;
  /// Transient — not stored in this row; persisted to service_addons table.
  final List<ServiceAddonDTO> pendingAddons;

  AppointmentSlotDTO({
    required this.id,
    required this.serviceName,
    required this.serviceType,
    this.description,
    required this.duration,
    required this.price,
    required this.slotType,
    required this.maxClients,
    required this.daysOfWeek,
    required this.selectPreferredWorker,
    required this.workerIds,
    required this.bufferMinutes,
    this.bufferBeforeMinutes = 0,
    this.isOnlineBookingEnabled = true,
    this.pendingAddons = const [],
  });

  factory AppointmentSlotDTO.fromJson(Map<String, dynamic> json) {
    return AppointmentSlotDTO(
      id: json['id'] as String,
      serviceName: json['service_name'] as String,
      serviceType: json['service_type'] as String?,
      description: json['description'] as String?,
      duration: json['duration'] as String,
      // After DB migration price is already in minor units; .round() guards
      // against any lingering float representation from Postgres numeric type.
      price: (json['price'] as num).round(),
      slotType: json['slot_type'] as String,
      maxClients: json['max_clients'] as int? ?? 1,
      bufferMinutes: json['buffer_minutes'] as int? ?? 0,
      bufferBeforeMinutes: json['buffer_before_minutes'] as int? ?? 0,
      isOnlineBookingEnabled: json['is_online_booking_enabled'] as bool? ?? true,
      daysOfWeek:
          (json['days_of_week'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      selectPreferredWorker: json['select_preferred_worker'] as bool? ?? false,
      workerIds:
          (json['worker_ids'] as List<dynamic>?)
              ?.map((w) => w as String)
              .toList() ??
          [], // Fixed the key name
    );
  }

  // Method to convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'description': description,
      'duration': duration,
      'price': price,
      'slot_type': slotType,
      'max_clients': maxClients, 'service_type': serviceType,
      'days_of_week': daysOfWeek,
      'select_preferred_worker': selectPreferredWorker,
      'worker_ids': workerIds,
      'buffer_minutes': bufferMinutes,
      'buffer_before_minutes': bufferBeforeMinutes,
      'is_online_booking_enabled': isOnlineBookingEnabled,
    };
  }
}
