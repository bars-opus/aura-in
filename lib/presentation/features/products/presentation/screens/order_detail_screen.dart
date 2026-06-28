// lib/features/orders/presentation/screens/order_detail_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/payment/presentation/widgets/info_row.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';

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
        context.showInfoSnackbar('Order ${_getStatusAction(newStatus)}');
      }
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('updateStatus rejected', error: e, stack: stack);
      if (mounted) {
        setState(() => _optimisticStatus = null); // revert
        context.showErrorSnackbar(e.message);
      }
    } catch (e, stack) {
      MarketplaceLogger.error('updateStatus failed', error: e, stack: stack);
      if (mounted) {
        setState(() => _optimisticStatus = null); // revert
        context.showErrorSnackbar('Failed to update: $e');
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Order #${widget.orderId.substring(0, 8)}',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: orderDataAsync.when(
          data: (data) {
            final order = data['order'] as OrderModel;
            final items = data['items'] as List<OrderItemModel>;

            return CustomScrollView(
              slivers: [
                // Customer info section
                SliverToBoxAdapter(child: _buildInfoSection(order, theme)),

                // Order items section
                SliverPadding(
                  padding: EdgeInsets.all(0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = items[index];
                      return _buildOrderItem(
                        item,
                        theme,
                        order.currencySymbol,
                        order.currencyCode,
                      );
                    }, childCount: items.length),
                  ),
                ),

                // Delivery address section
                SliverToBoxAdapter(child: _buildAddressSection(order, theme)),

                // Status update buttons (if not delivered or cancelled)
                if (_effectiveStatus(order) != OrderStatus.delivered &&
                    _effectiveStatus(order) != OrderStatus.cancelled)
                  SliverPadding(
                    padding: EdgeInsets.only(top: Spacing.xl),
                    sliver: SliverToBoxAdapter(
                      child: _buildActionButtons(order, theme),
                    ),
                  ),

                SliverPadding(
                  padding: EdgeInsets.only(top: Spacing.md),
                  sliver: SliverToBoxAdapter(
                    child: _buildContactButtons(order),
                  ),
                ),

                SliverToBoxAdapter(child: Gap(Spacing.xxl)),
              ],
            );
          },
          loading: () => Center(child: const CircularLoadingIndicator()),
          error:
              (error, stack) => Center(
                child: Center(
                  child: ErrorStateWidget(
                    title: 'Failed to load order details',
                    subtitle: error.toString(),
                    onPrimaryAction: () {
                      ref.invalidate(orderWithItemsProvider(widget.orderId));
                    },
                  ),
                ),
              ),
        ),
      ),
      bottomNavigationBar:
          _isUpdating
              ? SizedBox(
                height: 50.h,
                child: const Center(child: CircularLoadingIndicator()),
              )
              : null,
    );
  }

  Widget _buildInfoSection(OrderModel order, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final statusColor = order.status.getColor(theme.colorScheme);
    return CardInkWell(
      margin: const EdgeInsets.all(0),
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(Spacing.sm),
          ProfileHeader(
            mode: ProfileHeaderMode.compact,
            avatarUrl: order.customerAvatarUrl,
            displayName: order.customerName ?? '',
            userId: '',
            bio: '',
            onProfileNavigatePressed: () {},
          ),
          Gap(Spacing.md),
          if (order.customerPhone.isNotEmpty) ...[
            AppDivider(),
            InfoRow(label: 'Phone number', value: order.customerPhone),
          ],
          if (order.customerEmail != null) ...[
            AppDivider(),
            InfoRow(label: 'Customer email', value: order.customerEmail ?? ''),
          ],
          if (order.orderDate != null) ...[
            AppDivider(),
            InfoRow(
              label: 'Order date',
              value: MyDateFormat.toDate(order.orderDate),
            ),
          ],
          if (order.confirmedAt != null) ...[
            AppDivider(),
            InfoRow(
              label: 'Confirm date',
              value:
                  order.confirmedAt == null
                      ? ''
                      : MyDateFormat.toDate(order.confirmedAt!),
            ),
          ],
          if (order.deliveredAt != null) ...[
            AppDivider(),
            InfoRow(
              label: 'Confirm date',
              value:
                  order.dispatchedAt == null
                      ? ''
                      : MyDateFormat.toDate(order.dispatchedAt!),
            ),
          ],
          AppDivider(),
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

          if (order.deliveredAt != null) ...[
            AppDivider(),
            InfoRow(
              label: 'Delivery date',
              value:
                  order.deliveredAt == null
                      ? ''
                      : MyDateFormat.toDate(order.deliveredAt!),
            ),
          ],
          MiniContainerIndicator(
            color: statusColor,
            text: order.status.displayName,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    OrderItemModel item,
    ThemeData theme,
    String? currencySymbol,
    String? currencyCode,
  ) {
    final colorScheme = theme.colorScheme;
    return CardInkWell(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(Spacing.sm),
      child: InfoRowWidget(
        isNotAvatarImage: true,
        subtitle:
            '${item.quantity} x ${Currency.formatWithCurrency(item.unitPrice, currencySymbol: currencySymbol, currencyCode: currencyCode)}',
        title: item.productName,
        icon: Icons.image_outlined,
        iconSize: 50.0,
        imageUrl: item.productImage,
        titleFontSize: FontSizeTokens.lg,
        avatarRadius: 70.h,
        subTitleMaxLines: 2,
        disableTrailing: false,
        showAvatar: false,
        showDivider: false,
        showTrailingArrow: false,
        trailing: Text(
          Currency.formatWithCurrency(
            item.subtotal,
            currencySymbol: currencySymbol,
            currencyCode: currencyCode,
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildAddressSection(OrderModel order, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      margin: const EdgeInsets.all(0),
      child: Column(
        children: [
          InfoRowWidget(
            subtitle: 'Delivery Address',
            titleMaxLines: 5,
            title: order.deliveryAddress,
            icon: Icons.house,
            avatarRadius: 25.h,
            onTap: () {},
            disableTrailing: true,
            showDivider: order.customerNotes == null,
            showAvatar: false,
            showTrailingArrow: false,
          ),

          if (order.customerNotes != null &&
              order.customerNotes!.isNotEmpty) ...[
            Gap(Spacing.md),
            Text(
              'Customer Notes:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onBackground,
              ),
            ),
            Gap(Spacing.sm),
            Text(
              order.customerNotes!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ],
          if (order.shopNotes != null && order.shopNotes!.isNotEmpty) ...[
            Gap(Spacing.md),
            Text(
              'Shop Notes:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onBackground,
              ),
            ),
            Gap(Spacing.sm),
            Text(
              order.shopNotes!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ],
          Gap(Spacing.xl),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, ThemeData theme) {
    final List<Widget> buttons = [];
    final colorScheme = theme.colorScheme;
    // Show different buttons based on current status
    switch (_effectiveStatus(order)) {
      case OrderStatus.pending_confirmation:
        buttons.add(
          Expanded(
            child: AppButton(
              elevation: 0,
              label: 'Confirm Order',
              onPressed: () => _updateStatus('confirmed'),

              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 40.h,
            ),
          ),
        );
        buttons.add(Gap(Spacing.sm));
        buttons.add(
          Expanded(
            child: AppButton(
              height: 40.h,

              label: 'Cancel Order',

              onPressed: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  maxHeight: 400.h,
                  widget: ConfirmationDialog(
                    type: ConfirmationType.warning,
                    title: 'Are you sure you want to cancel this order?',
                    confirmText: 'Cancel Order',
                    message: '',
                    onConfirm: () {
                      _updateStatus('cancelled');
                    },
                  ),
                );
              },

              padding: Spacing.horizontalMd,
              customColor: colorScheme.error,
              size: ButtonSize.small,
              width: double.infinity,
            ),
          ),
        );
        break;

      case OrderStatus.confirmed:
        buttons.add(
          Expanded(
            child: AppButton(
              elevation: 0,
              label: 'Mark as Out for Delivery',
              onPressed: () => _updateStatus('out_for_delivery'),

              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 40.h,
            ),
          ),
        );
        break;

      case OrderStatus.out_for_delivery:
        buttons.add(
          Expanded(
            child: AppButton(
              elevation: 0,
              label: 'Mark as Delivered',
              onPressed: () => _updateStatus('delivered'),
              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 40.h,
            ),
          ),
        );
        break;

      default:
        break;
    }

    return Row(children: buttons);
  }

  Widget _buildContactButtons(OrderModel order) {
    return AppButton(
      elevation: 0,
      label: 'Call customer',
      onPressed: () {},
      size: ButtonSize.small,
      width: double.infinity,
      padding: Spacing.horizontalMd,
      height: 40.h,
    );
  }
}


// Calendar shows guest bookings — quick fix, just need to check the calendar provider query
// Wallet balance reflecting payments — verify the add_wallet_transaction RPC is actually being called on payment success
