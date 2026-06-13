import 'package:equatable/equatable.dart';

class ServiceAddonDTO extends Equatable {
  final String id;
  final String slotId;
  final String name;
  final int priceMinor; // kobo / cents
  final int? durationMinutes; // null = no extra time
  final bool isActive;

  const ServiceAddonDTO({
    required this.id,
    required this.slotId,
    required this.name,
    required this.priceMinor,
    this.durationMinutes,
    this.isActive = true,
  });

  factory ServiceAddonDTO.fromJson(Map<String, dynamic> json) {
    return ServiceAddonDTO(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      name: json['name'] as String,
      priceMinor: (json['price'] as num).round(),
      durationMinutes: json['duration_minutes'] as int?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slot_id': slotId,
        'name': name,
        'price': priceMinor,
        'duration_minutes': durationMinutes,
        'is_active': isActive,
      };

  ServiceAddonDTO copyWith({
    String? id,
    String? slotId,
    String? name,
    int? priceMinor,
    int? durationMinutes,
    bool? isActive,
  }) =>
      ServiceAddonDTO(
        id: id ?? this.id,
        slotId: slotId ?? this.slotId,
        name: name ?? this.name,
        priceMinor: priceMinor ?? this.priceMinor,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        isActive: isActive ?? this.isActive,
      );

  @override
  List<Object?> get props => [id, slotId, name, priceMinor, durationMinutes, isActive];
}
