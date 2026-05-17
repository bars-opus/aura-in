import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/order_repository.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/retry_policy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _supabase;

  SupabaseOrderRepository(this._supabase);

  /// Retry-safe ONLY if [idempotencyKey] is non-null — the server-side
  /// `create_order` RPC will replay the previous result for the same
  /// key. Without a key, a retry could create a duplicate order if the
  /// first request succeeded but the response was lost.
  @override
  Future<String> createOrder({
    required String userId,
    required String shopId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String deliveryAddress,
    required String customerPhone,
    required String customerNotes,
    String? idempotencyKey,
  }) async {
    try {
      Future<dynamic> call() => _supabase.rpc(
            'create_order',
            params: {
              'p_user_id': userId,
              'p_shop_id': shopId,
              'p_items': items,
              'p_total_amount': totalAmount,
              'p_delivery_address': deliveryAddress,
              'p_customer_phone': customerPhone,
              'p_customer_notes': customerNotes,
              if (idempotencyKey != null) 'p_idempotency_key': idempotencyKey,
            },
          );

      final response = idempotencyKey != null
          ? await RetryPolicy.run(call, operationName: 'create_order')
          : await call();

      return response.toString();
    } catch (e, stack) {
      MarketplaceLogger.error('createOrder failed', error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to create order');
    }
  }

  @override
  Future<List<OrderModel>> getShopOrders(
    String shopId, {
    int limit = 30,
    int page = 0,
    String? statusFilter,
  }) async {
    try {
      final response = await RetryPolicy.run(
        () {
          var query = _supabase
              .from('orders')
              .select('''
                *,
                profiles!user_id (
                  full_name,
                  email,
                  avatar_url
                )
              ''')
              .eq('shop_id', shopId);

          if (statusFilter != null && statusFilter.isNotEmpty) {
            query = query.eq('status', statusFilter);
          }

          final from = page * limit;
          return query
              .order('created_at', ascending: false)
              .range(from, from + limit - 1);
        },
        operationName: 'getShopOrders',
      );

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      MarketplaceLogger.error('getShopOrders failed', error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to load shop orders');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderWithItems(String orderId) async {
    try {
      final orderResponse = await RetryPolicy.run(
        () => _supabase
            .from('orders')
            .select('''
              *,
              profiles!user_id (
                full_name,
                email,
                avatar_url
              ),
              shops!inner (
                id,
                shop_name,
                verified,
                shop_logo_url
              )
            ''')
            .eq('id', orderId)
            .maybeSingle(),
        operationName: 'getOrderWithItems.order',
      );

      if (orderResponse == null) {
        throw OrderNotFoundException(orderId);
      }

      final itemsResponse = await RetryPolicy.run(
        () => _supabase
            .from('order_items')
            .select('''
              *,
              products (
                name,
                images
              )
            ''')
            .eq('order_id', orderId),
        operationName: 'getOrderWithItems.items',
      );

      final order = OrderModel.fromJson(orderResponse);
      final items = (itemsResponse as List)
          .map((json) => OrderItemModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return {'order': order, 'items': items};
    } on OrderNotFoundException {
      rethrow;
    } catch (e, stack) {
      MarketplaceLogger.error('getOrderWithItems failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to load order details');
    }
  }

  /// Retry-safe — the RPC has an explicit `(v_order.status = p_new_status)`
  /// no-op clause, so calling twice with the same target state is fine.
  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? shopNotes,
  }) async {
    try {
      await RetryPolicy.run(
        () => _supabase.rpc(
          'update_order_status',
          params: {
            'p_order_id': orderId,
            'p_new_status': newStatus,
            'p_shop_notes': shopNotes ?? '',
          },
        ),
        operationName: 'update_order_status',
      );
    } catch (e, stack) {
      MarketplaceLogger.error('updateOrderStatus failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to update order status');
    }
  }

  @override
  Future<void> cancelOrderByShop({
    required String orderId,
    required String reason,
  }) async {
    await updateOrderStatus(
      orderId: orderId,
      newStatus: 'cancelled',
      shopNotes: reason,
    );
  }

  /// NOT retried — the RPC errors after the first successful cancel
  /// because the order status would no longer be 'pending_confirmation'.
  /// A failed call could still have completed server-side; user retries
  /// via the UI and gets a clean "already cancelled" error path.
  @override
  Future<bool> cancelOrderByCustomer(String orderId) async {
    try {
      await _supabase.rpc('cancel_order', params: {'p_order_id': orderId});
      return true;
    } catch (e, stack) {
      MarketplaceLogger.error('cancelOrderByCustomer failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to cancel order');
    }
  }

  @override
  Future<List<OrderModel>> getCustomerOrders(
    String userId, {
    int limit = 30,
    int page = 0,
  }) async {
    try {
      final from = page * limit;
      final response = await RetryPolicy.run(
        () => _supabase
            .from('orders')
            .select('''
              *,
              shops!inner (
                id,
                shop_name,
                verified,
                shop_logo_url
              )
            ''')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .range(from, from + limit - 1),
        operationName: 'getCustomerOrders',
      );

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      MarketplaceLogger.error('getCustomerOrders failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to load your orders');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReorderItems(String orderId) async {
    try {
      final response = await RetryPolicy.run(
        () => _supabase
            .from('order_items')
            .select('''
              product_id,
              quantity,
              products (
                name,
                price,
                images,
                shop_id,
                is_active,
                stock_quantity,
                shops!inner (
                  shop_name
                )
              )
            ''')
            .eq('order_id', orderId),
        operationName: 'getReorderItems',
      );

      return (response as List).map((item) {
        final product = item['products'] as Map<String, dynamic>;
        final shop = product['shops'] as Map<String, dynamic>?;
        return {
          'product_id': item['product_id'],
          'product_name': product['name'],
          'price': (product['price'] as num).toDouble(),
          'image_url': (product['images'] as List?)?.cast<String>().firstOrNull,
          'quantity': item['quantity'],
          'shop_id': product['shop_id'],
          'shop_name': shop?['shop_name'] ?? '',
          'is_active': product['is_active'] ?? false,
          'stock_quantity': product['stock_quantity'] ?? 0,
        };
      }).toList();
    } catch (e, stack) {
      MarketplaceLogger.error('getReorderItems failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to get reorder items');
    }
  }

  /// NOT retried — would create duplicate dispute rows on replay.
  /// Server-side rate limit (3/day) would catch the second attempt
  /// but the customer would see a confusing "too many requests" message.
  @override
  Future<void> raiseDispute({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _supabase.rpc('raise_dispute', params: {
        'p_order_id': orderId,
        'p_reason': reason,
      });
    } catch (e, stack) {
      MarketplaceLogger.error('raiseDispute failed', error: e, stack: stack);
      if (e is OrderException) rethrow;
      throw mapToMarketplaceException(e, 'Failed to raise dispute');
    }
  }
}
