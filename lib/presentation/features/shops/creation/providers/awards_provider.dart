// lib/features/shop/creation/presentation/providers/awards_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';
import './shop_creation_provider.dart';

class AwardsNotifier extends StateNotifier<List<AwardDTO>> {
  final Ref _ref;

  AwardsNotifier({
    required Ref ref,
    List<AwardDTO>? initialAwards,
  }) : _ref = ref,
       super(initialAwards ?? []);

  void addAward(AwardDTO award) {
    state = [...state, award];
    _updateDraft();
  }

  void updateAward(int index, AwardDTO award) {
    final updated = List<AwardDTO>.from(state);
    updated[index] = award;
    state = updated;
    _updateDraft();
  }

  void removeAward(int index) {
    final updated = List<AwardDTO>.from(state)..removeAt(index);
    state = updated;
    _updateDraft();
  }

  void reorderAwards(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final awards = List<AwardDTO>.from(state);
    final item = awards.removeAt(oldIndex);
    awards.insert(newIndex, item);
    state = awards;
    _updateDraft();
  }

  void _updateDraft() {
    _ref.read(shopCreationProvider.notifier).updateAwards(state);
  }
}

final awardsProvider = StateNotifierProvider<AwardsNotifier, List<AwardDTO>>((ref) {
  final draft = ref.watch(shopCreationProvider);
  
  return AwardsNotifier(
    ref: ref,
    initialAwards: draft.awards,
  );
});
