// Update lib/features/orders/data/repositories/supabase_order_repository.dart

import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrderRepository {
  final SupabaseClient _supabase;

  SupabaseOrderRepository(this._supabase);

  // Create order (existing)
  Future<String> createOrder({
    required String userId,
    required String shopId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String deliveryAddress,
    required String customerPhone,
    required String customerNotes,
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
        },
      );
      return response.toString();
    } catch (e) {
      throw AuthException('Failed to create order: $e');
    }
  }

  // Get orders for a shop
  Future<List<OrderModel>> getShopOrders(String shopId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            profiles!user_id (
              full_name,
              email,
              avatar_url
            )
          ''')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;
        return OrderModel.fromJson({
          ...json,
          'customer_name': profile?['full_name'],
          'customer_email': profile?['email'],
          'customer_avatar_url': profile?['avatar_url'],
        });
      }).toList();
    } catch (e) {
      throw AuthException('Failed to load shop orders: $e');
    }
  }

  // Get single order with items
  Future<Map<String, dynamic>> getOrderWithItems(String orderId) async {
    try {
      // Get order details
      final orderResponse =
          await _supabase
              .from('orders')
              .select('''
            *,
            profiles!user_id (
              full_name,
              email,
              avatar_url
            )
          ''')
              .eq('id', orderId)
              .single();

      // Get order items
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

      final profile = orderResponse['profiles'] as Map<String, dynamic>?;
      final order = OrderModel.fromJson({
        ...orderResponse,
        'customer_name': profile?['full_name'],
        'customer_email': profile?['email'],
        'customer_avatar_url': profile?['avatar_url'],
      });

      final items =
          (itemsResponse as List).map((json) {
            final product = json['products'] as Map<String, dynamic>;
            return OrderItemModel.fromJson({
              ...json,
              'product_name': product['name'],
              'product_image': (product['images'] as List?)?.firstOrNull,
            });
          }).toList();

      return {'order': order, 'items': items};
    } catch (e) {
      throw AuthException('Failed to load order details: $e');
    }
  }

  // Update order status
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
      throw AuthException('Failed to update order status: $e');
    }
  }

  // Cancel order (shop side) - Renamed for clarity
  Future<void> cancelOrderByShop({
    required String orderId,
    required String reason,
  }) async {
    try {
      await updateOrderStatus(
        orderId: orderId,
        newStatus: 'cancelled',
        shopNotes: reason,
      );
    } catch (e) {
      throw AuthException('Failed to cancel order: $e');
    }
  }

  // Cancel order (customer side) - Renamed for clarity
  Future<bool> cancelOrderByCustomer(String orderId) async {
    try {
      await _supabase.rpc('cancel_order', params: {'p_order_id': orderId});
      return true;
    } catch (e) {
      throw AuthException('Failed to cancel order: $e');
    }
  }

  // Get orders for a customer
  Future<List<OrderModel>> getCustomerOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
          *,
          shops!inner (
            id,
            shop_name,
            verified,
            logo_url
          )
        ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final shop = json['shops'] as Map<String, dynamic>;
        return OrderModel.fromJson({
          ...json,
          'shop_name': shop['shop_name'],
          'shop_verified': shop['verified'],
          'shop_logo': shop['logo_url'],
        });
      }).toList();
    } catch (e) {
      throw AuthException('Failed to load your orders: $e');
    }
  }

  // Reorder (get cart items from previous order)
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
            shop_id
          )
        ''')
          .eq('order_id', orderId);

      return (response as List).map((item) {
        final product = item['products'] as Map<String, dynamic>;
        return {
          'product_id': item['product_id'],
          'product_name': product['name'],
          'price': product['price'],
          'image_url': (product['images'] as List?)?.firstOrNull,
          'quantity': item['quantity'],
          'shop_id': product['shop_id'],
        };
      }).toList();
    } catch (e) {
      throw AuthException('Failed to get reorder items: $e');
    }
  }
}
