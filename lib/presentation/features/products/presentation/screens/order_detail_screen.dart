// lib/features/orders/presentation/screens/order_detail_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/payment/presentation/widgets/info_row.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
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

  /// Open the buyer's profile. Only called when the buyer ordered with an
  /// account (order.userId present); guest/web buyers have no profile.
  void _openBuyerProfile(OrderModel order) {
    final buyerId = order.userId;
    if (buyerId == null || buyerId.isEmpty) return;
    final currentUserId =
        ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';
    context.pushNamed(
      'profileScreen',
      extra: <String, dynamic>{
        'currentUserId': currentUserId,
        'profileUserId': buyerId,
      },
    );
  }

  Widget _buildInfoSection(OrderModel order, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final statusColor = order.status.getColor(theme.colorScheme);
    // The buyer only has a viewable profile if they ordered with an account.
    // Guest (web, no account) buyers have no profile to open.
    final hasBuyerAccount = (order.userId ?? '').isNotEmpty;
    return CardInkWell(
      margin: const EdgeInsets.all(0),
      onTap: hasBuyerAccount ? () => _openBuyerProfile(order) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(Spacing.sm),
          Row(
            children: [
              Expanded(
                child: ProfileHeader(
                  mode: ProfileHeaderMode.compact,
                  avatarUrl: order.customerAvatarUrl,
                  displayName: order.customerName ?? '',
                  userId: order.userId ?? '',
                  bio: '',
                  // Disable the header's built-in profile nav for guest buyers;
                  // otherwise it would push /profileScreen with an empty userId.
                  enableOnProfileNavigatePressed: hasBuyerAccount,
                  onProfileNavigatePressed:
                      hasBuyerAccount ? () => _openBuyerProfile(order) : null,
                ),
              ),
              if (hasBuyerAccount)
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: IconSizes.md.h,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
            ],
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
          // Lifecycle dates in order: placed → confirmed → dispatched →
          // delivered, with cancelled as the terminal branch. Each row shows
          // only when its timestamp exists.
          AppDivider(),
          InfoRow(
            label: 'Order date',
            value: MyDateFormat.toDate(order.orderDate),
          ),
          if (order.confirmedAt != null) ...[
            AppDivider(),
            InfoRow(
              label: 'Confirmed date',
              value: MyDateFormat.toDate(order.confirmedAt!),
            ),
          ],
          if (order.dispatchedAt != null) ...[
            AppDivider(),
            InfoRow(
              label: 'Dispatched date',
              value: MyDateFormat.toDate(order.dispatchedAt!),
            ),
          ],
          if (order.deliveredAt != null) ...[
            AppDivider(),
            InfoRow(
              label: 'Delivered date',
              value: MyDateFormat.toDate(order.deliveredAt!),
            ),
          ],
          if (order.cancelledAt != null) ...[
            AppDivider(),
            InfoRow(
              label: 'Cancelled date',
              value: MyDateFormat.toDate(order.cancelledAt!),
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

          AppDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MiniContainerIndicator(
                color: statusColor,
                text: order.status.displayName,
              ),
              if (order.status.name == 'Delivered')
                Icon(
                  Icons.check_circle_sharp,
                  size: IconSizes.md.h,
                  color: colorScheme.success,
                ),
            ],
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
        onTap:
            item.productId.isEmpty
                ? null
                : () => context.pushNamed(
                  'productDetail',
                  extra: <String, String?>{
                    'productId': item.productId,
                    'coverImageUrl': item.productImage ?? '',
                  },
                ),
        subTitleMaxLines: 2,
        disableTrailing: false,
        showAvatar: false,
        showDivider: false,
        showTrailingArrow: false,
        trailing: Row(
          children: [
            Text(
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
            Icon(
              Icons.chevron_right,
              size: IconSizes.md.h,
              color: colorScheme.onBackground.withOpacity(0.3),
            ),
          ],
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
            onTap:
                order.deliveryAddress.trim().isEmpty
                    ? null
                    : () => UrlLauncherUtils.launchMapsQuery(
                      context: context,
                      address: order.deliveryAddress,
                    ),
            disableTrailing: false,
            showDivider: order.customerNotes == null,
            showAvatar: false,
            showTrailingArrow: false,
          ),

          if (order.customerNotes != null &&
              order.customerNotes!.isNotEmpty) ...[
            Gap(Spacing.md),
            AppDivider(),
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
            AppDivider(),
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

  /// Contact the buyer. Phone is preferred and always wins — a marketplace
  /// order is time-sensitive, so even a buyer with an app account gets called
  /// directly. Only when there is no phone do we fall back to the in-app
  /// messenger, which requires the buyer to have an account (order.userId).
  /// Guests with no phone and no account can't be reached here — the button
  /// is hidden in that case.
  Widget _buildContactButtons(OrderModel order) {
    final hasPhone = order.customerPhone.trim().isNotEmpty;
    final hasAccount = (order.userId ?? '').isNotEmpty;

    if (!hasPhone && !hasAccount) {
      return const SizedBox.shrink();
    }

    return AppButton(
      elevation: 0,
      label: hasPhone ? 'Call customer' : 'Message customer',
      onPressed: () {
        if (hasPhone) {
          UrlLauncherUtils.launchPhone(
            context: context,
            phoneNumber: order.customerPhone.trim(),
          );
        } else {
          // No phone — message the buyer in-app. BusinessChatLauncher routes
          // the shop owner to the buyer's Sendbird channel.
          BusinessChatLauncher.openForOrder(
            context,
            ref,
            order,
            isShopOwner: true,
          );
        }
      },
      size: ButtonSize.small,
      width: double.infinity,
      padding: Spacing.horizontalMd,
      height: 40.h,
    );
  }
}
