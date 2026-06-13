import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/service_templates_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_template_dto.dart';

final _serviceTemplatesRepoProvider = Provider<ServiceTemplatesRepository>((ref) {
  return ServiceTemplatesRepository(Supabase.instance.client);
});

/// Fetches templates for [shopType]. Returns empty list on network error (graceful degradation).
final serviceTemplatesProvider =
    FutureProvider.family<List<ServiceTemplateDTO>, String>((ref, shopType) async {
  return ref.read(_serviceTemplatesRepoProvider).fetchByShopType(shopType);
});
