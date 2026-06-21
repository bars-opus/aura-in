import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String orderId;

  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final orderAsync = ref.watch(orderWithItemsProvider(orderId));

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),
                Icon(
                  Icons.check_circle,
                  size: 96.w,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: 24.h),
                Text(
                  MarketplaceStrings.orderPlaced,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Cash on delivery. The shop will confirm your order shortly.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 24.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: orderAsync.when(
                      loading:
                          () => const Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      error:
                          (_, __) => Text(
                            'Order ID: ${_short(orderId)}',
                            style: textTheme.bodyMedium,
                          ),
                      data: (data) {
                        final order = data['order'] as OrderModel;
                        final items = data['items'] as List;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '#${_short(order.id)}',
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '${items.length} item${items.length == 1 ? '' : 's'}',
                              style: textTheme.bodySmall,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Total: ${Currency.formatWithSymbol(order.totalAmount, order.currencySymbol)}',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: 'View My Orders',
                  onPressed: () => context.goNamed('customerOrders'),
                  width: double.infinity,
                ),
                SizedBox(height: 12.h),
                OutlinedButton(
                  onPressed: () => context.goNamed('marketplace'),
                  child: const Text('Continue Shopping'),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _short(String id) =>
      id.length <= 8 ? id : id.substring(0, 8).toUpperCase();
}
