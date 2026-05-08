// lib/presentation/features/shops/creation/providers/hours_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/draft_context_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart'
    show freelancerCreationProvider;

class HoursNotifier extends StateNotifier<List<OpeningHoursDraft>> {
  final Ref _ref;

  HoursNotifier({required Ref ref, List<OpeningHoursDraft>? initialHours})
    : _ref = ref,
      super(initialHours ?? createDefaultHours());

  static List<OpeningHoursDraft> createDefaultHours() {
    return List.generate(7, (index) {
      final day = index + 1;
      if (day <= 5) {
        return OpeningHoursDraft(
          dayOfWeek: day,
          opensAt: '09:00 AM',
          closesAt: '05:00 PM',
          isClosed: true,
        );
      } else if (day == 6) {
        return OpeningHoursDraft(
          dayOfWeek: day,
          opensAt: '10:00 AM',
          closesAt: '03:00 PM',
          isClosed: true,
        );
      } else {
        return OpeningHoursDraft(
          dayOfWeek: day,
          opensAt: '00:00',
          closesAt: '00:00',
          isClosed: true,
        );
      }
    });
  }

  void updateDayHours({
    required int dayOfWeek,
    required String opensAt,
    required String closesAt,
    required bool isClosed,
  }) {
    final index = state.indexWhere((h) => h.dayOfWeek == dayOfWeek);
    final updatedHour = OpeningHoursDraft(
      dayOfWeek: dayOfWeek,
      opensAt: opensAt,
      closesAt: closesAt,
      isClosed: isClosed,
    );

    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        updatedHour,
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, updatedHour];
    }

    _updateDraft();
  }

  void setAllHours(List<OpeningHoursDraft> hours) {
    state = List.from(hours);
    _updateDraft();
  }

  void _updateDraft() {
    if (_ref.read(draftContextProvider) == DraftContext.freelancer) {
      _ref.read(freelancerCreationProvider.notifier).setOpeningHours(state);
    } else {
      _ref.read(shopCreationProvider.notifier).setOpeningHours(state);
    }
  }
}

final hoursProvider =
    StateNotifierProvider<HoursNotifier, List<OpeningHoursDraft>>((ref) {
      final draftContext = ref.watch(draftContextProvider);
      if (draftContext == DraftContext.freelancer) {
        // Read once — avoid watching freelancerCreationProvider to prevent
        // re-creation loops when _updateDraft() writes back to it.
        final hours = ref.read(freelancerCreationProvider).openingHours;
        return HoursNotifier(
          ref: ref,
          initialHours: hours.isEmpty ? null : hours,
        );
      }
      final draft = ref.watch(shopCreationProvider);
      return HoursNotifier(ref: ref, initialHours: draft.openingHours);
    });
