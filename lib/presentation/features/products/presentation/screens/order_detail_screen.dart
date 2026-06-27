// lib/features/orders/presentation/screens/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/services/business_chat_launcher.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String shopId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.shopId,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isUpdating = false;

  /// Optimistic override — set immediately on tap so the badge flips
  /// before the RPC returns. Cleared on success (the invalidate then
  /// fetches the canonical state) or on failure (revert to server state).
  OrderStatus? _optimisticStatus;

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
      _optimisticStatus = OrderStatusExtension.fromString(newStatus);
    });

    try {
      final repository = ref.read(orderRepositoryProvider);
      await repository.updateOrderStatus(
        orderId: widget.orderId,
        newStatus: newStatus,
      );

      // Refresh order details — canonical server state will overwrite
      // the optimistic override on the next build.
      ref.invalidate(orderWithItemsProvider(widget.orderId));
      ref.invalidate(shopOrdersProvider(widget.shopId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${_getStatusAction(newStatus)}')),
        );
      }
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('updateStatus rejected', error: e, stack: stack);
      if (mounted) {
        setState(() => _optimisticStatus = null); // revert
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e, stack) {
      MarketplaceLogger.error('updateStatus failed', error: e, stack: stack);
      if (mounted) {
        setState(() => _optimisticStatus = null); // revert
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
          // Successful path: keep optimistic until the refetch lands; if
          // the refetched data agrees, no visual flicker. If it disagrees
          // (rare), the next build uses the real value.
        });
      }
    }
  }

  /// Effective status for rendering — optimistic wins until the RPC
  /// resolves and the cache refetches.
  OrderStatus _effectiveStatus(OrderModel order) =>
      _optimisticStatus ?? order.status;

  String _getStatusAction(String status) {
    switch (status) {
      case 'confirmed':
        return 'confirmed';
      case 'out_for_delivery':
        return 'marked as out for delivery';
      case 'delivered':
        return 'marked as delivered';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'updated';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderDataAsync = ref.watch(orderWithItemsProvider(widget.orderId));
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.orderId.substring(0, 8)}',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: orderDataAsync.when(
        data: (data) {
          final order = data['order'] as OrderModel;
          final items = data['items'] as List<OrderItemModel>;

          return CustomScrollView(
            slivers: [
              // Customer info section
              SliverToBoxAdapter(child: _buildInfoSection(order, theme)),

              // Order items section
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return _buildOrderItem(item, theme, order.currencySymbol);
                  }, childCount: items.length),
                ),
              ),

              // Delivery address section
              SliverToBoxAdapter(child: _buildAddressSection(order, theme)),

              // Status update buttons (if not delivered or cancelled)
              if (_effectiveStatus(order) != OrderStatus.delivered &&
                  _effectiveStatus(order) != OrderStatus.cancelled)
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverToBoxAdapter(
                    child: _buildActionButtons(order, theme),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          );
        },
        loading: () => Center(child: const CircularLoadingIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.w),
                  SizedBox(height: 16.h),
                  Text('Failed to load order details'),
                  SizedBox(height: 8.h),
                  Text(error.toString(), style: textTheme.bodySmall),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(orderWithItemsProvider(widget.orderId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
      bottomNavigationBar:
          _isUpdating
              ? Container(
                height: 50.h,
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(child: CircularProgressIndicator()),
              )
              : null,
    );
  }

  Widget _buildInfoSection(OrderModel order, ThemeData theme) {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage:
                      order.customerAvatarUrl != null
                          ? NetworkImage(order.customerAvatarUrl!)
                          : null,
                  child:
                      order.customerAvatarUrl == null
                          ? Icon(Icons.person, size: 24.w)
                          : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName ?? 'Customer',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        order.customerEmail ?? 'No email',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        order.customerPhone,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Message customer',
                  onPressed:
                      order.userId == null || order.userId!.isEmpty
                          ? null
                          : () => BusinessChatLauncher.openForOrder(
                            context,
                            ref,
                            order,
                            isShopOwner: true,
                          ),
                  icon: const Icon(Icons.message_outlined),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Date:'),
                Text(_formatDateTime(order.orderDate)),
              ],
            ),
            if (order.confirmedAt != null) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Confirmed:'),
                  Text(_formatDateTime(order.confirmedAt!)),
                ],
              ),
            ],
            if (order.dispatchedAt != null) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dispatched:'),
                  Text(_formatDateTime(order.dispatchedAt!)),
                ],
              ),
            ],
            if (order.deliveredAt != null) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivered:'),
                  Text(_formatDateTime(order.deliveredAt!)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    OrderItemModel item,
    ThemeData theme,
    String? currencySymbol,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 60.w,
                height: 60.w,
                color: Colors.grey.shade200,
                child:
                    item.productImage != null
                        ? Image.network(
                          item.productImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_outlined, size: 24.w);
                          },
                        )
                        : Icon(Icons.image_outlined, size: 24.w),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${item.quantity} x ${Currency.formatWithSymbol(item.unitPrice, currencySymbol)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              Currency.formatWithSymbol(item.subtotal, currencySymbol),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(OrderModel order, ThemeData theme) {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(order.deliveryAddress),
            if (order.customerNotes != null &&
                order.customerNotes!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                'Customer Notes:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(order.customerNotes!),
            ],
            if (order.shopNotes != null && order.shopNotes!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                'Shop Notes:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(order.shopNotes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, ThemeData theme) {
    final List<Widget> buttons = [];

    // Show different buttons based on current status
    switch (_effectiveStatus(order)) {
      case OrderStatus.pending_confirmation:
        buttons.add(
          Expanded(
            child: AppButton(
              label: 'Confirm Order',
              onPressed: () => _updateStatus('confirmed'),
              // backgroundColor: Colors.green,
            ),
          ),
        );
        buttons.add(SizedBox(width: 12.w));
        buttons.add(
          Expanded(
            child: AppButton(
              label: 'Cancel Order',
              onPressed: () => _showCancelDialog(),
              // backgroundColor: Colors.red,
            ),
          ),
        );
        break;

      case OrderStatus.confirmed:
        buttons.add(
          Expanded(
            child: AppButton(
              label: 'Mark as Out for Delivery',
              onPressed: () => _updateStatus('out_for_delivery'),
              // backgroundColor: Colors.orange,
            ),
          ),
        );
        break;

      case OrderStatus.out_for_delivery:
        buttons.add(
          Expanded(
            child: AppButton(
              label: 'Mark as Delivered',
              onPressed: () => _updateStatus('delivered'),
              // backgroundColor: Colors.green,
            ),
          ),
        );
        break;

      default:
        break;
    }

    return Row(children: buttons);
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Order'),
            content: const Text('Are you sure you want to cancel this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus('cancelled');
                },
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
