import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_addon_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/template_addon_dto.dart';

class ServiceAddonsRepository {
  final SupabaseClient _client;

  ServiceAddonsRepository(this._client);

  /// Fetch all active add-ons for a slot (client booking flow + owner form).
  Future<List<ServiceAddonDTO>> fetchBySlotId(String slotId) async {
    try {
      final response = await _client
          .from('service_addons')
          .select()
          .eq('slot_id', slotId)
          .order('name');
      return (response as List)
          .map((r) => ServiceAddonDTO.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('ServiceAddonsRepository.fetchBySlotId error: $e');
      return const [];
    }
  }

  /// Upsert the full add-on list for a slot (replaces existing on publish/update).
  /// Throws on failure so callers can surface the error to the user.
  Future<void> replaceAddons(String slotId, List<ServiceAddonDTO> addons) async {
    await _client.from('service_addons').delete().eq('slot_id', slotId);
    if (addons.isEmpty) return;
    await _client.from('service_addons').insert(
          addons
              .map((a) => {
                    'id': a.id.isEmpty ? const Uuid().v4() : a.id,
                    'slot_id': slotId,
                    'name': a.name,
                    'price': a.priceMinor,
                    'duration_minutes': a.durationMinutes,
                    'is_active': true,
                  })
              .toList(),
        );
  }

  /// Fetch template add-ons for a template id (shown in ServiceTemplatesSheet).
  Future<List<TemplateAddonDTO>> fetchTemplateAddons(String templateId) async {
    try {
      final response = await _client
          .from('service_template_addons')
          .select()
          .eq('template_id', templateId)
          .order('name');
      return (response as List)
          .map((r) => TemplateAddonDTO.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('ServiceAddonsRepository.fetchTemplateAddons error: $e');
      return const [];
    }
  }
}
