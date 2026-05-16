import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _supabase;

  SupabaseOrderRepository(this._supabase);

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
      final response = await _supabase.rpc(
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
      return response.toString();
    } catch (e) {
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
      final response = await query
          .order('created_at', ascending: false)
          .range(from, from + limit - 1);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapToMarketplaceException(e, 'Failed to load shop orders');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderWithItems(String orderId) async {
    try {
      final orderResponse = await _supabase
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
          .maybeSingle();

      if (orderResponse == null) {
        throw OrderNotFoundException(orderId);
      }

      final itemsResponse = await _supabase
          .from('order_items')
          .select('''
            *,
            products (
              name,
              images
            )
          ''')
          .eq('order_id', orderId);

      final order = OrderModel.fromJson(orderResponse);
      final items = (itemsResponse as List)
          .map((json) => OrderItemModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return {'order': order, 'items': items};
    } on OrderNotFoundException {
      rethrow;
    } catch (e) {
      throw mapToMarketplaceException(e, 'Failed to load order details');
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? shopNotes,
  }) async {
    try {
      await _supabase.rpc(
        'update_order_status',
        params: {
          'p_order_id': orderId,
          'p_new_status': newStatus,
          'p_shop_notes': shopNotes ?? '',
        },
      );
    } catch (e) {
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

  @override
  Future<bool> cancelOrderByCustomer(String orderId) async {
    try {
      await _supabase.rpc('cancel_order', params: {'p_order_id': orderId});
      return true;
    } catch (e) {
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
      final response = await _supabase
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
          .range(from, from + limit - 1);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapToMarketplaceException(e, 'Failed to load your orders');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReorderItems(String orderId) async {
    try {
      final response = await _supabase
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
          .eq('order_id', orderId);

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
    } catch (e) {
      throw mapToMarketplaceException(e, 'Failed to get reorder items');
    }
  }

  @override
  Future<void> raiseDispute({
    required String orderId,
    required String reason,
  }) async {
    try {
      // Hardening migration introduces a SECURITY DEFINER RPC that
      // rate-limits, validates, audits, and atomically inserts the
      // dispute row + flips the order to 'disputed' in one call.
      await _supabase.rpc('raise_dispute', params: {
        'p_order_id': orderId,
        'p_reason': reason,
      });
    } catch (e) {
      if (e is OrderException) rethrow;
      throw mapToMarketplaceException(e, 'Failed to raise dispute');
    }
  }
}
