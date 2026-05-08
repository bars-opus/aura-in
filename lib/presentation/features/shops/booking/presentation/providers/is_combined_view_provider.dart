// lib/features/booking/presentation/providers/is_combined_view_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'is_combined_view_provider.g.dart';

/// Provider that tracks whether the user is viewing combined slots or regular slots
@riverpod
class IsCombinedView extends _$IsCombinedView {
  @override
  bool build() => false; // Default to regular view

  /// Enable combined view
  void enable() => state = true;

  /// Disable combined view (regular view)
  void disable() => state = false;

  /// Toggle between views
  void toggle() => state = !state;
}
