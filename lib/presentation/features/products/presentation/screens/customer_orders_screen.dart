// lib/features/orders/data/repositories/order_repository.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/customer_order_detail_screen.dart';

class CustomerOrdersScreen extends ConsumerStatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  ConsumerState<CustomerOrdersScreen> createState() =>
      _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends ConsumerState<CustomerOrdersScreen> {
  OrderStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final ordersAsync = ref.watch(customerOrdersProvider(user?.id ?? ''));
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64.w),
            SizedBox(height: 16.h),
            Text('Please log in to view your orders'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Navigate to login
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
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
              icon: Icons.shopping_bag_outlined,
              title: 'No orders',
              subtitle:
                  _selectedStatusFilter == null
                      ? 'You haven\'t placed any orders yet'
                      : 'No ${_selectedStatusFilter!.displayName.toLowerCase()} orders',
              actionLabel: 'Start Shopping',
              onAction: () {
                Navigator.pushNamed(context, '/marketplace');
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(customerOrdersProvider(user.id));
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
                      ref.invalidate(customerOrdersProvider(user.id));
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
              builder: (_) => CustomerOrderDetailScreen(orderId: order.id),
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
              Row(
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 14.w,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      order.shopName ?? 'Shop',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
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
              if (order.status == OrderStatus.pending_confirmation)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: OutlinedButton(
                    onPressed: () => _showCancelConfirmation(order.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      minimumSize: Size(double.infinity, 32.h),
                    ),
                    child: const Text('Cancel Order'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(String orderId) {
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
                  try {
                    final repository = ref.read(orderRepositoryProvider);
                    await repository.cancelOrderByCustomer(orderId);

                    final user = ref.read(currentUserProvider);
                    ref.invalidate(customerOrdersProvider(user?.id ?? ''));

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order cancelled successfully'),
                        ),
                      );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
