import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';

class CustomerOrdersScreen extends ConsumerStatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  ConsumerState<CustomerOrdersScreen> createState() =>
      _CustomerOrdersScreenState();
}

class CustomerOrdersTab extends ConsumerStatefulWidget {
  final bool showStatusFilter;

  const CustomerOrdersTab({super.key, this.showStatusFilter = true});

  @override
  ConsumerState<CustomerOrdersTab> createState() => _CustomerOrdersTabState();
}

class _CustomerOrdersTabState extends ConsumerState<CustomerOrdersTab> {
  OrderStatus? _selectedStatusFilter;

  /// Filter is client-side: applies to whatever pages are currently
  /// loaded. Choosing a status no other order in the loaded pages
  /// matches will surface an empty state — user can scroll to load
  /// more or pull to refresh.
  bool _matchesFilter(OrderModel o) =>
      _selectedStatusFilter == null || o.status == _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64.w),
            SizedBox(height: 16.h),
            const Text('Please log in to view your orders'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    final state = ref.watch(customerOrdersPagedProvider(user.id));
    final notifier = ref.read(customerOrdersPagedProvider(user.id).notifier);

    return Column(
      children: [
        if (widget.showStatusFilter) _buildStatusFilter(),
        Expanded(child: _buildBody(state, notifier, theme)),
      ],
    );
  }

  Widget _buildBody(
    PagedListState<OrderModel> state,
    CustomerOrdersPagedNotifier notifier,
    ThemeData theme,
  ) {
    if (state.isInitialLoading) {
      return const Center(child: CircularLoadingIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return _ErrorRetry(
        message: state.error!,
        onRetry: notifier.refresh,
      );
    }

    final filtered = state.items.where(_matchesFilter).toList();

    if (filtered.isEmpty && !state.hasMore) {
      return EmptyStateWidget(
        icon: Icons.shopping_bag_outlined,
        title: 'No orders',
        subtitle: _selectedStatusFilter == null
            ? "You haven't placed any orders yet"
            : 'No ${_selectedStatusFilter!.displayName.toLowerCase()} orders',
        actionLabel: 'Start Shopping',
        onAction: () => context.pushNamed('marketplace'),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            notifier.loadNext();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.all(12.w),
          itemCount: filtered.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= filtered.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return _buildOrderCard(filtered[index], theme);
          },
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
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('All'),
              selected: _selectedStatusFilter == null,
              onSelected: (_) =>
                  setState(() => _selectedStatusFilter = null),
            );
          }
          final status = orderStatuses[index - 1];
          return FilterChip(
            label: Text(status.displayName),
            selected: _selectedStatusFilter == status,
            onSelected: (_) =>
                setState(() => _selectedStatusFilter = status),
            backgroundColor: Colors.grey.shade100,
            selectedColor: status
                .getColor(Theme.of(context).colorScheme)
                .withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: _selectedStatusFilter == status
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
        onTap: () => context.pushNamed('customerOrderDetail', extra: order.id),
        borderRadius: BorderRadius.circular(12.r),
        child: Semantics(
          button: true,
          label:
              'Order ${order.id.substring(0, 8)}, ${order.status.displayName}, '
              '${Currency.formatWithSymbol(order.totalAmount, order.currencySymbol)}',
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
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
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
                    Icon(Icons.store_outlined,
                        size: 14.w, color: Colors.grey.shade600),
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
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    Text(
                      Currency.formatWithSymbol(order.totalAmount, order.currencySymbol),
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
                    child: Semantics(
                      button: true,
                      label: 'Cancel order',
                      child: OutlinedButton(
                        onPressed: () => _showCancelConfirmation(order.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: Size(double.infinity, 32.h),
                        ),
                        child: const Text('Cancel Order'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(String orderId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await ref
                    .read(orderRepositoryProvider)
                    .cancelOrderByCustomer(orderId);
                if (!mounted) return;
                final u = ref.read(currentUserProvider);
                if (u != null) {
                  await ref
                      .read(customerOrdersPagedProvider(u.id).notifier)
                      .refresh();
                }
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled')),
                );
              } catch (e, stack) {
                MarketplaceLogger.error('cancelOrderByCustomer failed',
                    error: e, stack: stack);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to cancel: $e')),
                );
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _CustomerOrdersScreenState extends ConsumerState<CustomerOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          MarketplaceStrings.myOrders,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: const CustomerOrdersTab(),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.w),
            SizedBox(height: 16.h),
            const Text('Failed to load'),
            SizedBox(height: 8.h),
            Text(message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(MarketplaceStrings.retry),
            ),
          ],
        ),
      );
}
