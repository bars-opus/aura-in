// lib/features/orders/presentation/screens/shop_orders_screen.dart



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/order_detail_screen.dart';

class ShopOrdersScreen extends ConsumerStatefulWidget {
  final String shopId;

  const ShopOrdersScreen({super.key, required this.shopId});

  @override
  ConsumerState<ShopOrdersScreen> createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends ConsumerState<ShopOrdersScreen> {
  OrderStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(shopOrdersProvider(widget.shopId));
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: _buildStatusFilter(),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final filteredOrders =
              _selectedStatusFilter == null
                  ? orders
                  : orders
                      .where((o) => o.status == _selectedStatusFilter)
                      .toList();

          if (filteredOrders.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.inbox_outlined,
              title: 'No orders',
              subtitle:
                  _selectedStatusFilter == null
                      ? 'No orders yet'
                      : 'No ${_selectedStatusFilter!.displayName.toLowerCase()} orders',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(shopOrdersProvider(widget.shopId));
            },
            child: ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(order, theme);
              },
            ),
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
                  Text('Failed to load orders'),
                  SizedBox(height: 8.h),
                  Text(
                    error.toString(),
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(shopOrdersProvider(widget.shopId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final orderStatuses = OrderStatus.values;

    return Container(
      height: 45.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: orderStatuses.length + 1,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: Text('All'),
              selected: _selectedStatusFilter == null,
              onSelected: (_) {
                setState(() {
                  _selectedStatusFilter = null;
                });
              },
            );
          }

          final status = orderStatuses[index - 1];
          return FilterChip(
            label: Text(status.displayName),
            selected: _selectedStatusFilter == status,
            onSelected: (_) {
              setState(() {
                _selectedStatusFilter = status;
              });
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: status
                .getColor(Theme.of(context).colorScheme)
                .withOpacity(0.2),
            labelStyle: TextStyle(
              color:
                  _selectedStatusFilter == status
                      ? status.getColor(Theme.of(context).colorScheme)
                      : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, ThemeData theme) {
    final statusColor = order.status.getColor(theme.colorScheme);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => OrderDetailScreen(
                    orderId: order.id,
                    shopId: widget.shopId,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                order.customerName ?? 'Customer',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 4.h),
              Text(
                order.customerPhone,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(order.orderDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '₦${order.totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
