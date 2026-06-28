import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/services/business_chat_launcher.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/input_sanitizer.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
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

  Future<void> _reorder(OrderModel order) async {
    if (_isReordering) return;
    setState(() => _isReordering = true);

    try {
      final repository = ref.read(orderRepositoryProvider);
      final items = await repository.getReorderItems(widget.orderId);
      final cartNotifier = ref.read(cartNotifierProvider.notifier);

      int added = 0;
      int skipped = 0;
      for (final item in items) {
        final isActive = item['is_active'] as bool? ?? false;
        final stock = (item['stock_quantity'] as num?)?.toInt() ?? 0;
        final qty = (item['quantity'] as num).toInt();

        if (!isActive || stock < qty) {
          skipped++;
          continue;
        }

        try {
          await cartNotifier.addItem(
            CartItemModel(
              productId: item['product_id'] as String,
              productName: item['product_name'] as String,
              price: (item['price'] as num).toDouble(),
              imageUrl: item['image_url'] as String?,
              quantity: qty,
              shopId: item['shop_id'] as String,
              shopName: item['shop_name'] as String? ?? '',
              currencySymbol: order.currencySymbol,
              currencyCode: order.currencyCode,
            ),
          );
          added++;
        } on MultiShopCartException {
          // First item from a different shop was added in a prior add;
          // subsequent items would all reject. Stop and inform.
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Some items are from a different shop than your current cart',
              ),
            ),
          );
          return;
        }
      }

      if (!mounted) return;
      final msg =
          skipped == 0
              ? '$added item${added == 1 ? '' : 's'} added to cart'
              : '$added added · $skipped unavailable';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      if (added > 0) context.pushNamed('cart');
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('reorder rejected', error: e, stack: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e, stack) {
      MarketplaceLogger.error('reorder failed', error: e, stack: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to reorder')));
      }
    } finally {
      if (mounted) setState(() => _isReordering = false);
    }
  }

  Future<void> _reportIssue(OrderModel order) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Report an issue'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Briefly describe what went wrong. The shop will be notified.',
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  maxLength: InputSanitizer.maxDisputeReason,
                  decoration: const InputDecoration(
                    hintText: 'e.g. wrong product delivered',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final v = InputSanitizer.clean(reasonController.text);
                  if (v.isEmpty) return;
                  if (v.length > InputSanitizer.maxDisputeReason) return;
                  Navigator.pop(ctx, v);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );

    if (reason == null || !mounted) return;

    try {
      await ref
          .read(orderNotifierProvider.notifier)
          .raiseDispute(orderId: order.id, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue reported. The shop will respond.')),
      );
      ref.invalidate(orderWithItemsProvider(widget.orderId));
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('reportIssue rejected', error: e, stack: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e, stack) {
      MarketplaceLogger.error('reportIssue failed', error: e, stack: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to report issue')));
      }
    }
  }

  bool _canReport(OrderModel order) =>
      order.status == OrderStatus.confirmed ||
      order.status == OrderStatus.out_for_delivery ||
      order.status == OrderStatus.delivered;

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
                // Order Status Timeline
                SliverToBoxAdapter(child: _buildStatusTimeline(order, theme)),

                // Order items
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
                ), // Shop info
                SliverToBoxAdapter(child: _buildShopInfo(order, theme)),

                // Delivery info
                SliverToBoxAdapter(child: _buildAddressSection(order, theme)),

                SliverToBoxAdapter(child: Gap(Spacing.xl)),

                // Reorder button (if delivered)
                if (order.status == OrderStatus.delivered)
                  SliverPadding(
                    padding: EdgeInsets.only(top: Spacing.md),
                    sliver: SliverToBoxAdapter(
                      child: AppButton(
                        elevation: 0,
                        label:
                            _isReordering
                                ? 'Adding to Cart...'
                                : 'Reorder Items',
                        onPressed: _isReordering ? null : () => _reorder(order),
                        size: ButtonSize.small,
                        width: double.infinity,
                        padding: Spacing.horizontalMd,
                        height: 40.h,
                      ),
                    ),
                  ),

                // Cancel button (if pending)
                if (order.status == OrderStatus.pending_confirmation)
                  SliverPadding(
                    padding: EdgeInsets.only(top: Spacing.md),
                    sliver: SliverToBoxAdapter(
                      child: AppButton(
                        elevation: 0,
                        customColor: colorScheme.error,
                        label: 'Cancel Order',
                        onPressed: () => _showCancelDialog(order.id),
                        size: ButtonSize.small,
                        width: double.infinity,
                        padding: Spacing.horizontalMd,
                        height: 40.h,
                      ),
                    ),
                  ),

                SliverPadding(
                  padding: EdgeInsets.only(top: Spacing.md),
                  sliver: SliverToBoxAdapter(
                    child: _buildContactButtons(order),
                  ),
                ),
                // Report issue (once the order is in motion)
                if (_canReport(order) && order.status != OrderStatus.disputed)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Semantics(
                        button: true,
                        label: MarketplaceStrings.reportIssue,
                        child: TextButton.icon(
                          icon: const Icon(Icons.flag_outlined),
                          label: const Text(MarketplaceStrings.reportIssue),
                          onPressed: () => _reportIssue(order),
                        ),
                      ),
                    ),
                  ),

                SliverToBoxAdapter(child: Gap(Spacing.xxl)),

                SliverToBoxAdapter(child: _buildReviewSection(order, items)),
              ],
            );
          },
          loading: () => Center(child: const CircularLoadingIndicator()),
          error:
              (error, stack) => Center(
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
    );
  }

  Widget _buildStatusTimeline(OrderModel order, ThemeData theme) {
    final colorScheme = theme.colorScheme;
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

    return CardInkWell(
      margin: const EdgeInsets.all(0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: order.status
                      .getColor(theme.colorScheme)
                      .withValues(alpha: 0.1),
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
                                color:
                                    step['completed'] as bool
                                        ? colorScheme.background
                                        : colorScheme.onPrimary,
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
    return CardInkWell(
      margin: const EdgeInsets.all(0),
      child: ProfileHeader(
        mode: ProfileHeaderMode.compact,
        avatarUrl: order.shopLogo,
        displayName: order.shopName ?? '',
        userId: order.shopId,
        bio: '',
        onProfileNavigatePressed: () {},
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

          Gap(Spacing.xl),
        ],
      ),
    );
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
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order cancelled successfully'),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e, stack) {
                    MarketplaceLogger.error(
                      'cancel order (from detail) failed',
                      error: e,
                      stack: stack,
                    );
                    if (!context.mounted) return;
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
}
