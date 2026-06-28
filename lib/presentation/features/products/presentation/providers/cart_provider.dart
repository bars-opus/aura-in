import 'dart:convert';

import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cart_provider.g.dart';

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? error;

  const CartState({this.items = const [], this.isLoading = false, this.error});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  /// The shop the cart belongs to. Cart is enforced single-shop on `addItem`
  /// so this is always meaningful when [items] is non-empty.
  String? get singleShopId => items.isEmpty ? null : items.first.shopId;

  /// The cart is single-shop (addItem enforces it), so currency is uniform.
  String? get currencySymbol =>
      items.isEmpty ? null : items.first.currencySymbol;

  String? get currencyCode => items.isEmpty ? null : items.first.currencyCode;

  bool get hasMultipleShops =>
      items.map((item) => item.shopId).toSet().length > 1;

  List<String> getUniqueShopIds() =>
      items.map((item) => item.shopId).toSet().toList();

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Cart is **per-user**. Storage key is namespaced by `auth.uid()` so
/// signing out and back in as a different user on the same device does
/// not surface the previous user's cart. Sign-out triggers a rebuild
/// (via ref.watch on currentUserProvider) that re-loads from the new
/// (or guest) bucket.
///
/// keepAlive: the cart is app-wide state. Without it the autoDispose notifier
/// is torn down whenever no widget watches it (e.g. navigating away from
/// ProductDetailScreen back to Discover), so opening CartScreen rebuilds from
/// `const CartState()` and shows empty until the async storage reload resolves.
/// Keeping it alive preserves the in-memory cart and a correct badge count.
@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  String? _userId;

  String get _storageKey => 'shopping_cart:${_userId ?? 'guest'}';

  @override
  CartState build() {
    final user = ref.watch(currentUserProvider);
    _userId = user?.id;
    // Async load; updates state once SharedPreferences resolves.
    _loadCartFromStorage();
    return const CartState();
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_storageKey);
      if (cartJson != null) {
        final List<dynamic> decoded = json.decode(cartJson);
        final items =
            decoded
                .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
                .toList();
        state = state.copyWith(items: items, clearError: true);
      } else {
        state = const CartState();
      }
    } catch (e, stack) {
      MarketplaceLogger.warn('cart load failed', error: e, stack: stack);
      state = state.copyWith(error: 'Failed to load saved cart');
    }
  }

  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(state.items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, cartJson);
    } catch (e, stack) {
      MarketplaceLogger.warn('cart save failed', error: e, stack: stack);
    }
  }

  /// Adds an item. Throws [MultiShopCartException] if the cart already
  /// contains items from a different shop — the UI should catch this and
  /// offer to clear the cart before re-adding.
  Future<void> addItem(CartItemModel newItem) async {
    if (state.items.isNotEmpty && state.items.first.shopId != newItem.shopId) {
      throw MultiShopCartException();
    }

    final existingIndex = state.items.indexWhere(
      (item) => item.productId == newItem.productId,
    );

    List<CartItemModel> updatedItems;
    if (existingIndex != -1) {
      updatedItems = List.from(state.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + newItem.quantity,
      );
    } else {
      updatedItems = [...state.items, newItem];
    }

    state = state.copyWith(items: updatedItems, clearError: true);
    await _saveCartToStorage();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    final updated =
        state.items
            .map(
              (i) =>
                  i.productId == productId ? i.copyWith(quantity: quantity) : i,
            )
            .toList();
    state = state.copyWith(items: updated);
    await _saveCartToStorage();
  }

  Future<void> removeItem(String productId) async {
    final updated = state.items.where((i) => i.productId != productId).toList();
    state = state.copyWith(items: updated);
    await _saveCartToStorage();
  }

  Future<void> clearCart() async {
    state = state.copyWith(items: [], clearError: true);
    await _saveCartToStorage();
  }

  List<String> getUniqueShopIds() => state.getUniqueShopIds();
  bool get hasMultipleShops => state.hasMultipleShops;
}
