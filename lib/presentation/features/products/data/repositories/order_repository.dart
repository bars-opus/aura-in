// Abstract order repository. Implementations live alongside in
// supabase_order_repository.dart.

import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';

abstract class OrderRepository {
  Future<String> createOrder({
    required String userId,
    required String shopId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String deliveryAddress,
    required String customerPhone,
    required String customerNotes,
    String? idempotencyKey,
  });

  Future<List<OrderModel>> getShopOrders(
    String shopId, {
    int limit = 30,
    int page = 0,
    String? statusFilter,
  });

  Future<Map<String, dynamic>> getOrderWithItems(String orderId);

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? shopNotes,
  });

  Future<void> cancelOrderByShop({
    required String orderId,
    required String reason,
  });

  Future<bool> cancelOrderByCustomer(String orderId);

  Future<List<OrderModel>> getCustomerOrders(
    String userId, {
    int limit = 30,
    int page = 0,
  });

  Future<List<Map<String, dynamic>>> getReorderItems(String orderId);

  /// Customer-facing dispute creation. Marks the order as 'disputed' and
  /// inserts an order_disputes row. Authorization enforced by RLS.
  Future<void> raiseDispute({
    required String orderId,
    required String reason,
  });
}
