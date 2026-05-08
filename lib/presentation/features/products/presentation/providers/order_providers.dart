import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/supabase_order_repository.dart';

// ============================================
// Order Repository Provider
// ============================================
final orderRepositoryProvider = Provider<SupabaseOrderRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseOrderRepository(supabase);
});

// ============================================
// Shop Orders Provider
// ============================================
final shopOrdersProvider = FutureProvider.family<List<OrderModel>, String>((
  ref,
  shopId,
) async {
  final repository = ref.read(orderRepositoryProvider);
  return repository.getShopOrders(shopId);
});

// ============================================
// Order with Items Provider
// ============================================
final orderWithItemsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
      final repository = ref.read(orderRepositoryProvider);
      return repository.getOrderWithItems(orderId);
    });

// ============================================
// Order State
// ============================================
class OrderState {
  final bool isLoading;
  final String? error;
  final String? lastOrderId;

  const OrderState({this.isLoading = false, this.error, this.lastOrderId});

  OrderState copyWith({bool? isLoading, String? error, String? lastOrderId}) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastOrderId: lastOrderId ?? this.lastOrderId,
    );
  }
}

// ============================================
// Order Notifier (for creating orders)
// ============================================
class OrderNotifier extends StateNotifier<OrderState> {
  final Ref _ref;

  OrderNotifier(this._ref) : super(const OrderState());

  Future<String?> createOrder({
    required String shopId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String deliveryAddress,
    required String customerPhone,
    required String customerNotes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not logged in');
      }

      final repository = _ref.read(orderRepositoryProvider);
      final orderId = await repository.createOrder(
        userId: user.id,
        shopId: shopId,
        items: items,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        customerPhone: customerPhone,
        customerNotes: customerNotes,
      );

      state = state.copyWith(isLoading: false, lastOrderId: orderId);
      return orderId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const OrderState();
  }
}

// ============================================
// Order Notifier Provider
// ============================================
final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  return OrderNotifier(ref);
});

// ============================================
// Customer Orders Provider (Add this)
// ============================================
final customerOrdersProvider = FutureProvider.family<List<OrderModel>, String>((
  ref,
  userId,
) async {
  final repository = ref.read(orderRepositoryProvider);
  return repository.getCustomerOrders(userId);
});

// ============================================
// Cancel Order Provider (Add this)
// ============================================
final cancelOrderProvider = FutureProvider.family<bool, String>((
  ref,
  orderId,
) async {
  final repository = ref.read(orderRepositoryProvider);
  return repository.cancelOrderByCustomer(orderId);
});
