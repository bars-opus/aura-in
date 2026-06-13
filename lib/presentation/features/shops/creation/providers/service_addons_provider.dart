import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/service_addons_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_addon_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/template_addon_dto.dart';

final serviceAddonsRepoProvider = Provider<ServiceAddonsRepository>((ref) {
  return ServiceAddonsRepository(Supabase.instance.client);
});

/// Fetches persisted add-ons for a slot. Used by the owner form (edit mode)
/// and the client booking add-on picker.
final slotAddonsProvider =
    FutureProvider.family<List<ServiceAddonDTO>, String>((ref, slotId) async {
  if (slotId.isEmpty) return const [];
  return ref.read(serviceAddonsRepoProvider).fetchBySlotId(slotId);
});

/// Fetches template add-ons for a template id.
final templateAddonsProvider =
    FutureProvider.family<List<TemplateAddonDTO>, String>((ref, templateId) async {
  return ref.read(serviceAddonsRepoProvider).fetchTemplateAddons(templateId);
});

/// Tracks which add-ons the client has selected during booking.
/// Key = slot id, Value = list of selected add-on DTOs.
final selectedAddonsProvider =
    StateNotifierProvider<SelectedAddonsNotifier, Map<String, List<ServiceAddonDTO>>>(
  (ref) => SelectedAddonsNotifier(),
);

class SelectedAddonsNotifier
    extends StateNotifier<Map<String, List<ServiceAddonDTO>>> {
  SelectedAddonsNotifier() : super({});

  void toggle(String slotId, ServiceAddonDTO addon) {
    final current = List<ServiceAddonDTO>.from(state[slotId] ?? []);
    final idx = current.indexWhere((a) => a.id == addon.id);
    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.add(addon);
    }
    state = {...state, slotId: current};
  }

  List<ServiceAddonDTO> forSlot(String slotId) => state[slotId] ?? [];

  int totalExtraMinor() => state.values
      .expand((addons) => addons)
      .fold(0, (sum, a) => sum + a.priceMinor);

  int totalExtraDurationMinutes() => state.values
      .expand((addons) => addons)
      .fold(0, (sum, a) => sum + (a.durationMinutes ?? 0));

  void clearSlot(String slotId) => state = {...state}..remove(slotId);

  void clearAll() => state = {};
}
