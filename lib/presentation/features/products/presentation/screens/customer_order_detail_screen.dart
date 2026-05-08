import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/providers/product_review_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/product_review_bottom_sheet.dart';

class CustomerOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const CustomerOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<CustomerOrderDetailScreen> createState() =>
      _CustomerOrderDetailScreenState();
}

class _CustomerOrderDetailScreenState
    extends ConsumerState<CustomerOrderDetailScreen> {
  bool _isReordering = false;

  Future<void> _reorder() async {
    setState(() => _isReordering = true);

    try {
      final repository = ref.read(orderRepositoryProvider);
      final items = await repository.getReorderItems(widget.orderId);

      final cartNotifier = ref.read(cartNotifierProvider.notifier);

      // Add each item to cart
      for (final item in items) {
        await cartNotifier.addItem(
          CartItemModel(
            productId: item['product_id'],
            productName: item['product_name'],
            price: item['price'],
            imageUrl: item['image_url'],
            quantity: item['quantity'],
            shopId: item['shop_id'],
            shopName: '', // Will be fetched, but we can update later
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Items added to cart')));
        Navigator.pushNamed(context, '/cart');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to reorder: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isReordering = false);
      }
    }
  }

  // Add this method
  Widget _buildReviewSection(OrderModel order, List<OrderItemModel> items) {
    final canReviewProvider = ref.watch(
      canReviewProductProvider(items.first.productId),
    );

    return canReviewProvider.when(
      data: (canReview) {
        if (!canReview) return const SizedBox();

        return Container(
          margin: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Your Purchase',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              ...items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder:
                            (context) => ProductReviewBottomSheet(
                              orderId: order.id,
                              productId: item.productId,
                              productName: item.productName,
                              onReviewSubmitted: () {
                                ref.invalidate(
                                  productReviewsProvider(item.productId),
                                );
                              },
                            ),
                      );
                    },
                    icon: Icon(Icons.rate_review_outlined),
                    label: Text('Review ${item.productName}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 45.h),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (error, stack) => const SizedBox(),
    );
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
              // Order Status Timeline
              SliverToBoxAdapter(child: _buildStatusTimeline(order, theme)),

              // Shop info
              SliverToBoxAdapter(child: _buildShopInfo(order, theme)),

              // Order items
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return _buildOrderItem(item, theme);
                  }, childCount: items.length),
                ),
              ),

              // Delivery info
              SliverToBoxAdapter(child: _buildDeliveryInfo(order, theme)),

              // Reorder button (if delivered)
              if (order.status == OrderStatus.delivered)
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverToBoxAdapter(
                    child: AppButton(
                      label:
                          _isReordering ? 'Adding to Cart...' : 'Reorder Items',
                      onPressed: _isReordering ? null : _reorder,
                      width: double.infinity,
                    ),
                  ),
                ),

              // Cancel button (if pending)
              if (order.status == OrderStatus.pending_confirmation)
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverToBoxAdapter(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        minimumSize: Size(double.infinity, 45.h),
                      ),
                      child: const Text('Cancel Order'),
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 80.h)),

              SliverToBoxAdapter(child: _buildReviewSection(order, items)),
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
    );
  }

  Widget _buildStatusTimeline(OrderModel order, ThemeData theme) {
    final steps = [
      {'status': 'Pending', 'completed': true, 'icon': Icons.receipt_outlined},
      {
        'status': 'Confirmed',
        'completed': order.status.index >= OrderStatus.confirmed.index,
        'icon': Icons.check_circle_outline,
      },
      {
        'status': 'Out for Delivery',
        'completed': order.status.index >= OrderStatus.out_for_delivery.index,
        'icon': Icons.local_shipping_outlined,
      },
      {
        'status': 'Delivered',
        'completed': order.status.index >= OrderStatus.delivered.index,
        'icon': Icons.home_outlined,
      },
    ];

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8.r),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: order.status
                      .getColor(theme.colorScheme)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  order.status.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: order.status.getColor(theme.colorScheme),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children:
                steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == steps.length - 1;

                  return Expanded(
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    step['completed'] as bool
                                        ? theme.colorScheme.primary
                                        : Colors.grey.shade300,
                              ),
                              child: Icon(
                                step['icon'] as IconData,
                                color: Colors.white,
                                size: 20.w,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              step['status'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    step['completed'] as bool
                                        ? theme.colorScheme.primary
                                        : Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              height: 2.h,
                              color:
                                  step['completed'] as bool
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade300,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfo(OrderModel order, ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage:
                    order.shopLogo != null
                        ? NetworkImage(order.shopLogo!)
                        : null,
                child:
                    order.shopLogo == null
                        ? Icon(Icons.store, size: 24.w)
                        : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.shopName ?? 'Shop',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (order.shopVerified == true)
                      Row(
                        children: [
                          Icon(Icons.verified, size: 14.w, color: Colors.blue),
                          SizedBox(width: 4.w),
                          Text(
                            'Verified Shop',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItemModel item, ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
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
                    '${item.quantity} x ₦${item.unitPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₦${item.subtotal.toStringAsFixed(2)}',
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

  Widget _buildDeliveryInfo(OrderModel order, ThemeData theme) {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20.w,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Expanded(child: Text(order.deliveryAddress)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 20.w,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Text(order.customerPhone),
              ],
            ),
            if (order.customerNotes != null &&
                order.customerNotes!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                'Order Notes:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(order.customerNotes!),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(String orderId) {
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
                onPressed: () async {
                  Navigator.pop(context);
                  final repository = ref.read(orderRepositoryProvider);
                  try {
                    await repository.cancelOrderByCustomer(orderId);
                    ref.invalidate(orderWithItemsProvider(orderId));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order cancelled successfully'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to cancel: $e')),
                      );
                    }
                  }
                },
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }
}
