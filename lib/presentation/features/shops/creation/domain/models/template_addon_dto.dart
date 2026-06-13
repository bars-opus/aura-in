import 'package:equatable/equatable.dart';

/// An add-on seeded alongside a service template.
/// Not stored in `service_addons` (no slot_id yet) — used to pre-fill
/// the add-on list when the owner picks a template.
class TemplateAddonDTO extends Equatable {
  final String templateId; // FK → service_templates.id
  final String name;
  final int? suggestedPriceMinor;
  final int? durationMinutes;

  const TemplateAddonDTO({
    required this.templateId,
    required this.name,
    this.suggestedPriceMinor,
    this.durationMinutes,
  });

  factory TemplateAddonDTO.fromJson(Map<String, dynamic> json) {
    return TemplateAddonDTO(
      templateId: json['template_id'] as String,
      name: json['name'] as String,
      suggestedPriceMinor: json['suggested_price_minor'] as int?,
      durationMinutes: json['duration_minutes'] as int?,
    );
  }

  @override
  List<Object?> get props => [templateId, name, suggestedPriceMinor, durationMinutes];
}
