import 'package:equatable/equatable.dart';

class ServiceTemplateDTO extends Equatable {
  final String id;
  final String shopType;
  final String serviceName;
  final String serviceType;
  final int durationMinutes;
  final int? suggestedPriceMinor;
  final String? description;

  const ServiceTemplateDTO({
    required this.id,
    required this.shopType,
    required this.serviceName,
    required this.serviceType,
    required this.durationMinutes,
    this.suggestedPriceMinor,
    this.description,
  });

  factory ServiceTemplateDTO.fromJson(Map<String, dynamic> json) {
    return ServiceTemplateDTO(
      id: json['id'] as String,
      shopType: json['shop_type'] as String,
      serviceName: json['service_name'] as String,
      serviceType: json['service_type'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      suggestedPriceMinor: json['suggested_price_minor'] as int?,
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, shopType, serviceName, serviceType, durationMinutes];
}
