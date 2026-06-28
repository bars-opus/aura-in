import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/payment/presentation/widgets/info_row.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_container.dart';

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
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    if (user == null) {
      return Center(
        child: EmptyStateWidget(
          title: 'Please log in to view your orders',
          subtitle: '',
        ),
      );
    }

    final state = ref.watch(customerOrdersPagedProvider(user.id));
    final notifier = ref.read(customerOrdersPagedProvider(user.id).notifier);

    if (!widget.showStatusFilter) {
      return _buildBody(state, notifier, theme, statusFilter: null);
    }

    return TabsWithContent(
      tabs: _buildTabs(state, notifier, theme),
      initialIndex: 0,
      scrollable: true,
      showContent: true,
    );
  }

  List<AppTabItem> _buildTabs(
    PagedListState<OrderModel> state,
    CustomerOrdersPagedNotifier notifier,
    ThemeData theme,
  ) {
    return [
      AppTabItem(
        label: 'All',
        icon: Icons.receipt_long_outlined,
        content: _buildBody(state, notifier, theme, statusFilter: null),
      ),
      ...OrderStatus.values.map(
        (status) => AppTabItem(
          label: status.displayName,
          icon: _iconForStatus(status),
          content: _buildBody(state, notifier, theme, statusFilter: status),
        ),
      ),
    ];
  }

  Widget _buildBody(
    PagedListState<OrderModel> state,
    CustomerOrdersPagedNotifier notifier,
    ThemeData theme, {
    required OrderStatus? statusFilter,
  }) {
    if (state.isInitialLoading) {
      return const Center(child: CircularLoadingIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: ErrorStateWidget(
          title: state.error!,
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
        icon: Icons.shopping_bag_outlined,
        title: 'No orders',
        subtitle:
            statusFilter == null
                ? "You haven't placed any orders yet"
                : 'No ${statusFilter.displayName.toLowerCase()} orders',
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

  Widget _buildOrderCard(OrderModel order, ThemeData theme) {
    final statusColor = order.status.getColor(theme.colorScheme);
    final colorScheme = theme.colorScheme;
    return CardInkWell(
      onTap: () => context.pushNamed('customerOrderDetail', extra: order.id),
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
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Gap(Spacing.md),
          InfoRow(label: 'Shop name', value: order.shopName ?? ''),
          InfoRow(
            label: 'Order date',
            value: MyDateFormat.toDate(order.orderDate),
          ),
          MiniContainerIndicator(
            color: statusColor,
            text: order.status.displayName,
          ),

          if (order.status == OrderStatus.pending_confirmation)
            Padding(
              padding: EdgeInsets.only(top: Spacing.lg),
              child: Semantics(
                button: true,
                label: 'Cancel order',
                child: AppButton(
                  height: 30.h,

                  label: 'Cancel Order',
                  onPressed: () async {
                    BottomSheetUtils.showDocumentationBottomSheet(
                      context: context,
                      widget: ConfirmationDialog(
                        type: ConfirmationType.warning,
                        title: 'Are you sure you want to cancel this order?',
                        confirmText: 'Cancel Order',
                        message: '',
                        onConfirm: () async {
                          Navigator.pop(context);
                          try {
                            await ref
                                .read(orderRepositoryProvider)
                                .cancelOrderByCustomer(order.id);
                            if (!mounted) return;
                            final u = ref.read(currentUserProvider);
                            if (u != null) {
                              await ref
                                  .read(
                                    customerOrdersPagedProvider(u.id).notifier,
                                  )
                                  .refresh();
                            }
                            if (!mounted) return;
                            context.showInfoSnackbar('Order cancelled');
                          } catch (e, stack) {
                            MarketplaceLogger.error(
                              'cancelOrderByCustomer failed',
                              error: e,
                              stack: stack,
                            );
                            if (!mounted) return;
                            context.showErrorSnackbar('Failed to cancel: $e');
                          }
                        },
                      ),
                    );
                  },
                  padding: Spacing.horizontalMd,
                  variant: ButtonVariant.outline,
                  outlineColor: colorScheme.error,
                  textColor: colorScheme.error,
                  size: ButtonSize.small,
                  width: double.infinity,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_confirmation:
        return Icons.pending_actions_outlined;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
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

class _CustomerOrdersScreenState extends ConsumerState<CustomerOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const CustomerOrdersTab());
  }
}
