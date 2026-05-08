// lib/features/shops/presentation/providers/selected_luxury_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_luxury_provider.g.dart';

@riverpod
class SelectedLuxuryLevel extends _$SelectedLuxuryLevel {
  @override
  String? build() {
    return null; // null = All
  }

  void selectLuxury(String? level) {
    state = level;
  }
}
