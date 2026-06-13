import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_template_dto.dart';

class ServiceTemplatesRepository {
  final SupabaseClient _client;

  ServiceTemplatesRepository(this._client);

  Future<List<ServiceTemplateDTO>> fetchByShopType(String shopType) async {
    try {
      final response = await _client
          .from('service_templates')
          .select()
          .eq('shop_type', shopType)
          .order('service_name');

      return (response as List)
          .map((row) => ServiceTemplateDTO.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (e) {
      debugPrint('ServiceTemplatesRepository.fetchByShopType error: $e');
      return const [];
    }
  }
}
