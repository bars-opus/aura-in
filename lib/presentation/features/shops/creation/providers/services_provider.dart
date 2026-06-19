// lib/features/shop/creation/presentation/providers/services_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/draft_context_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/utils/undo_service.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:uuid/uuid.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart'
    show freelancerCreationProvider;
import 'shop_creation_provider.dart';

/// Holds the last successfully saved service so the next "Add service" form
/// can be pre-filled with operational values (price, duration, buffers, etc.).
final lastSavedServiceProvider =
    StateProvider<AppointmentSlotDTO?>((ref) => null);

class ServicesNotifier extends StateNotifier<List<AppointmentSlotDTO>>
    with UndoCapability<List<AppointmentSlotDTO>> {
  final Ref _ref;

  ServicesNotifier({
    required Ref ref,
    List<AppointmentSlotDTO>? initialServices,
  }) : _ref = ref,
       super(initialServices ?? []);

  void addService(AppointmentSlotDTO service) {
    final s = service.id.isEmpty
        ? service.copyWith(id: const Uuid().v4())
        : service;
    state = [...state, s];
    _ref.read(lastSavedServiceProvider.notifier).state = s;
    _updateDraft();
  }

  void updateService(int index, AppointmentSlotDTO service) {
    final updated = List<AppointmentSlotDTO>.from(state);
    updated[index] = service;
    state = updated;
    _updateDraft();
  }

  void removeService(int index) {
    saveSnapshot();
    final updated = List<AppointmentSlotDTO>.from(state)..removeAt(index);
    state = updated;
    _updateDraft();
  }

  void updateServiceById(String id, AppointmentSlotDTO service) {
    final idx = state.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final updated = List<AppointmentSlotDTO>.from(state);
    updated[idx] = service;
    state = updated;
    _updateDraft();
  }

  void removeServiceById(String id) {
    saveSnapshot();
    state = state.where((s) => s.id != id).toList();
    _updateDraft();
  }

  void reorderServices(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final services = List<AppointmentSlotDTO>.from(state);
    final item = services.removeAt(oldIndex);
    services.insert(newIndex, item);
    state = services;
    _updateDraft();
  }

  void updateAllServices(List<AppointmentSlotDTO> newServices) {
    state = newServices;
    _updateDraft();
  }

  void _updateDraft() {
    if (_ref.read(draftContextProvider) == DraftContext.freelancer) {
      _ref.read(freelancerCreationProvider.notifier).updateServices(state);
    } else {
      _ref.read(shopCreationProvider.notifier).updateServices(state);
    }
  }
}

final servicesProvider =
    StateNotifierProvider<ServicesNotifier, List<AppointmentSlotDTO>>((ref) {
      final draftContext = ref.watch(draftContextProvider);
      if (draftContext == DraftContext.freelancer) {
        final services = ref.read(freelancerCreationProvider).services;
        return ServicesNotifier(ref: ref, initialServices: services);
      }
      final draft = ref.watch(shopCreationProvider);
      return ServicesNotifier(ref: ref, initialServices: draft.services);
    });
