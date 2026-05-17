import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/order_repository.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/supabase_order_repository.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';

// Abstract interface so consumers don't depend on the Supabase impl.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseOrderRepository(supabase);
});

/// Shop-side order list. Default page size 30 (pagination ready in the
/// repository if a UI needs to drive it).
final shopOrdersProvider = FutureProvider.family<List<OrderModel>, String>(
  (ref, shopId) async {
    final repository = ref.read(orderRepositoryProvider);
    return repository.getShopOrders(shopId);
  },
);

final orderWithItemsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final repository = ref.read(orderRepositoryProvider);
  return repository.getOrderWithItems(orderId);
});

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
    String? idempotencyKey,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw OrderUnauthorizedException();
      }

      final orderId =
          await _ref.read(orderRepositoryProvider).createOrder(
                userId: user.id,
                shopId: shopId,
                items: items,
                totalAmount: totalAmount,
                deliveryAddress: deliveryAddress,
                customerPhone: customerPhone,
                customerNotes: customerNotes,
                idempotencyKey: idempotencyKey,
              );

      state = state.copyWith(isLoading: false, lastOrderId: orderId);
      return orderId;
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('OrderNotifier.createOrder rejected',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e, stack) {
      MarketplaceLogger.error('OrderNotifier.createOrder failed',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> raiseDispute({
    required String orderId,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(orderRepositoryProvider).raiseDispute(
            orderId: orderId,
            reason: reason,
          );
      state = state.copyWith(isLoading: false);
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('OrderNotifier.raiseDispute rejected',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e, stack) {
      MarketplaceLogger.error('OrderNotifier.raiseDispute failed',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void reset() => state = const OrderState();
}

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref);
});

final customerOrdersProvider =
    FutureProvider.family<List<OrderModel>, String>((ref, userId) async {
  final repository = ref.read(orderRepositoryProvider);
  return repository.getCustomerOrders(userId);
});

// ── Paginated providers (infinite scroll) ────────────────────

class CustomerOrdersPagedNotifier extends PagedListNotifier<OrderModel> {
  final Ref _ref;
  final String _userId;
  CustomerOrdersPagedNotifier(this._ref, this._userId);

  @override
  Future<List<OrderModel>> fetchPage(int page, int limit) =>
      _ref.read(orderRepositoryProvider).getCustomerOrders(
            _userId,
            limit: limit,
            page: page,
          );
}

final customerOrdersPagedProvider = StateNotifierProvider.autoDispose
    .family<CustomerOrdersPagedNotifier, PagedListState<OrderModel>, String>(
  (ref, userId) => CustomerOrdersPagedNotifier(ref, userId),
);

class ShopOrdersPagedNotifier extends PagedListNotifier<OrderModel> {
  final Ref _ref;
  final String _shopId;
  ShopOrdersPagedNotifier(this._ref, this._shopId);

  @override
  Future<List<OrderModel>> fetchPage(int page, int limit) =>
      _ref.read(orderRepositoryProvider).getShopOrders(
            _shopId,
            limit: limit,
            page: page,
          );
}

final shopOrdersPagedProvider = StateNotifierProvider.autoDispose
    .family<ShopOrdersPagedNotifier, PagedListState<OrderModel>, String>(
  (ref, shopId) => ShopOrdersPagedNotifier(ref, shopId),
);

final cancelOrderProvider =
    FutureProvider.family<bool, String>((ref, orderId) async {
  final repository = ref.read(orderRepositoryProvider);
  return repository.cancelOrderByCustomer(orderId);
});
