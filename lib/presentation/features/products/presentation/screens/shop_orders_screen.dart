// lib/features/orders/presentation/screens/shop_orders_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/payment/presentation/widgets/info_row.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_container.dart';

class ShopOrdersScreen extends ConsumerStatefulWidget {
  final String shopId;

  const ShopOrdersScreen({super.key, required this.shopId});

  @override
  ConsumerState<ShopOrdersScreen> createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends ConsumerState<ShopOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopOrdersPagedProvider(widget.shopId));
    final notifier = ref.read(shopOrdersPagedProvider(widget.shopId).notifier);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Orders',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),

      body: TabsWithContent(
        tabs: _buildTabs(state, notifier, theme, textTheme),
        initialIndex: 0,
        scrollable: true,
        showContent: true,
      ),
    );
  }

  List<AppTabItem> _buildTabs(
    PagedListState<OrderModel> state,
    ShopOrdersPagedNotifier notifier,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return [
      AppTabItem(
        label: 'All',
        icon: Icons.inbox_outlined,
        content: _buildBody(
          state,
          notifier,
          theme,
          textTheme,
          statusFilter: null,
        ),
      ),
      ...OrderStatus.values.map(
        (status) => AppTabItem(
          label: status.displayName,
          icon: _iconForStatus(status),
          content: _buildBody(
            state,
            notifier,
            theme,
            textTheme,
            statusFilter: status,
          ),
        ),
      ),
    ];
  }

  Widget _buildBody(
    PagedListState<OrderModel> state,
    ShopOrdersPagedNotifier notifier,
    ThemeData theme,
    TextTheme textTheme, {
    required OrderStatus? statusFilter,
  }) {
    if (state.isInitialLoading) {
      return const Center(child: CircularLoadingIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: ErrorStateWidget(
          title: 'Failed to load orders',
          subtitle: state.error!,
          onPrimaryAction: notifier.refresh,
        ),
      );
    }

    final filtered =
        statusFilter == null
            ? state.items
            : state.items.where((o) => o.status == statusFilter).toList();

    if (filtered.isEmpty && !state.hasMore) {
      return EmptyStateWidget(
        icon: Icons.inbox_outlined,
        title: 'No orders',
        subtitle:
            statusFilter == null
                ? 'No orders yet'
                : 'No ${statusFilter.displayName.toLowerCase()} orders',
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

  Widget _buildOrderCard(OrderModel order, ThemeData theme) {
    final statusColor = order.status.getColor(theme.colorScheme);
    final colorScheme = theme.colorScheme;
    return
    
    
     CardInkWell(
      onTap: () {
        context.pushNamed(
          'shopOrderDetail',
          extra: {'orderId': order.id, 'shopId': widget.shopId},
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.substring(0, 8)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                Currency.formatWithSymbol(
                  order.totalAmount,
                  order.currencySymbol,
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Gap(Spacing.sm),
          AppDivider(),
          Gap(Spacing.sm),
          Row(
            children: [
              SizedBox(
                width: 45.h,
                height: 45.h,
                child: ShopImageContainer(
                  imageUrl: order.previewProductImage ?? '',
                  isPreview: false,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              Gap(Spacing.md.w),
              Text(
                order.previewProductName ?? 'Ordered product',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ],
          ),
          Gap(Spacing.md),
          InfoRow(label: 'Customer name', value: order.customerName ?? ''),
          InfoRow(label: 'Phone number', value: order.customerPhone),
          InfoRow(
            label: 'Order date',
            value: MyDateFormat.toDate(order.orderDate),
          ),
          MiniContainerIndicator(
            color: statusColor,
            text: order.status.displayName,
          ),
        ],
      ),
    );
  }

  IconData _iconForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_confirmation:
        return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:
        return Icons.verified_outlined;
      case OrderStatus.out_for_delivery:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.inventory_2_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.disputed:
        return Icons.report_problem_outlined;
    }
  }
}
