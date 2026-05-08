// lib/features/booking/presentation/providers/selected_shop_id_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'selected_shop_id_provider.g.dart';

/// Provider that holds the ID of the shop currently being booked.
///
/// This is set when entering the booking flow from a shop page
/// and persists throughout the booking process.
///
/// ## Features
/// - Required for slot generation and booking creation
/// - Used in repository calls to filter by shop
/// - Should be reset when leaving the booking flow
///
/// ## Usage
/// ```dart
/// // Set when entering booking flow
/// ref.read(selectedShopIdProvider.notifier).setShopId('shop_123');
///
/// // Read current shop ID
/// final shopId = ref.watch(selectedShopIdProvider);
/// if (shopId == null) {
///   // Redirect to shop selection
/// }
/// ```
@riverpod
class SelectedShopId extends _$SelectedShopId {
  @override
  String? build() => null;

  /// Sets the selected shop ID
  void setShopId(String shopId) {
    state = shopId;
  }

  /// Clears the selected shop ID (when leaving booking flow)
  void clear() {
    state = null;
  }
}
