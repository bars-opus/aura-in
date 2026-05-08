import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cart_provider.g.dart';

// Cart state class
class CartState {
  final List<CartItemModel> items;
  final bool isLoading;

  const CartState({this.items = const [], this.isLoading = false});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  // Add this getter
  bool get hasMultipleShops {
    final uniqueShops = items.map((item) => item.shopId).toSet();
    return uniqueShops.length > 1;
  }

  // Add this method to get unique shop IDs
  List<String> getUniqueShopIds() {
    return items.map((item) => item.shopId).toSet().toList();
  }

  CartState copyWith({List<CartItemModel>? items, bool? isLoading}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Cart notifier
@riverpod
class CartNotifier extends _$CartNotifier {
  static const String _cartStorageKey = 'shopping_cart';

  @override
  CartState build() {
    _loadCartFromStorage();
    return const CartState();
  }



  // Load cart from local storage
  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartStorageKey);

      if (cartJson != null) {
        final List<dynamic> decoded = json.decode(cartJson);
        final items =
            decoded
                .map(
                  (item) =>
                      CartItemModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();

        state = state.copyWith(items: items);
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  // Save cart to local storage
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(
        state.items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_cartStorageKey, cartJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Add item to cart
  Future<void> addItem(CartItemModel newItem) async {
    final existingIndex = state.items.indexWhere(
      (item) => item.productId == newItem.productId,
    );

    List<CartItemModel> updatedItems;

    if (existingIndex != -1) {
      // Update existing item
      updatedItems = List.from(state.items);
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + newItem.quantity,
      );
    } else {
      // Add new item
      updatedItems = [...state.items, newItem];
    }

    state = state.copyWith(items: updatedItems);
    await _saveCartToStorage();
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    final updatedItems =
        state.items.map((item) {
          if (item.productId == productId) {
            return item.copyWith(quantity: quantity);
          }
          return item;
        }).toList();

    state = state.copyWith(items: updatedItems);
    await _saveCartToStorage();
  }

  // Remove item from cart
  Future<void> removeItem(String productId) async {
    final updatedItems =
        state.items.where((item) => item.productId != productId).toList();

    state = state.copyWith(items: updatedItems);
    await _saveCartToStorage();
  }

  // Clear entire cart
  Future<void> clearCart() async {
    state = state.copyWith(items: []);
    await _saveCartToStorage();
  }

  // Get unique shops in cart (for checkout)
  List<String> getUniqueShopIds() {
    return state.items.map((item) => item.shopId).toSet().toList();
  }

  // Check if cart has items from multiple shops
  bool get hasMultipleShops => getUniqueShopIds().length > 1;
}
