// lib/features/products/presentation/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/core/widgets/app_text_form_field.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/input_sanitizer.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/connectivity_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isPlacingOrder = false;

  /// Stable for the lifetime of this checkout screen — a tap-twice or
  /// network-retry within the same screen replays the same key so the
  /// server-side idempotency check returns the existing order_id
  /// instead of creating a duplicate.
  late final String _idempotencyKey = const Uuid().v4();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartState = ref.read(cartNotifierProvider);
    if (cartState.isEmpty) return;

    // Check if cart has items from multiple shops
    if (cartState.hasMultipleShops) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please order from one shop at a time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final shopId = cartState.items.first.shopId;
    final items =
        cartState.items
            .map(
              (item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
                'unit_price': item.price,
              },
            )
            .toList();

    setState(() => _isPlacingOrder = true);

    try {
      final orderNotifier = ref.read(orderNotifierProvider.notifier);
      final orderId = await orderNotifier.createOrder(
        shopId: shopId,
        items: items,
        totalAmount: cartState.totalAmount,
        deliveryAddress: InputSanitizer.clean(_addressController.text),
        customerPhone: InputSanitizer.clean(_phoneController.text),
        customerNotes: InputSanitizer.clean(_notesController.text),
        idempotencyKey: _idempotencyKey,
      );

      if (mounted && orderId != null) {
        // Clear cart and navigate to order confirmation
        await ref.read(cartNotifierProvider.notifier).clearCart();
        if (!mounted) return;
        context.pushReplacementNamed('orderConfirmation', extra: orderId);
      }
    } catch (e, stack) {
      MarketplaceLogger.error('placeOrder failed', error: e, stack: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          MarketplaceStrings.checkoutTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body:
          cartState.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order summary
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Summary',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                semanticsLabel: 'Order summary',
                              ),
                              SizedBox(height: 12.h),
                              ...cartState.items.map(
                                (item) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.quantity}x ${item.productName}',
                                          style: textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        Currency.formatCompact(item.subtotal),
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(height: 24.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    Currency.format(cartState.totalAmount),
                                    style: textTheme.titleLarge?.copyWith(
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

                      SizedBox(height: 24.h),

                      // Delivery address
                      Text(
                        'Delivery Information',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      AppTextFormField(
                        controller: _addressController,
                        label: 'Delivery Address',
                        hintText: 'Enter your full address',
                        maxLines: 3,
                        maxLength: InputSanitizer.maxDeliveryAddress,
                        validator: InputSanitizer.requiredLength(
                          InputSanitizer.maxDeliveryAddress,
                          fieldName: 'Delivery address',
                        ),
                      ),
                      SizedBox(height: 16.h),

                      AppTextFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        maxLength: InputSanitizer.maxCustomerPhone,
                        validator: InputSanitizer.validatePhone,
                      ),
                      SizedBox(height: 16.h),

                      AppTextFormField(
                        controller: _notesController,
                        label: 'Order Notes (Optional)',
                        hintText: 'Special instructions for delivery',
                        maxLines: 2,
                        maxLength: InputSanitizer.maxOrderNotes,
                        validator: InputSanitizer.optionalLength(
                          InputSanitizer.maxOrderNotes,
                          fieldName: 'Order notes',
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Payment info (COD)
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    MarketplaceStrings.codTitle,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    MarketplaceStrings.codSubtitle,
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Offline banner — blocks Place Order with a clear reason.
                      if (!isOnline)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_off,
                                  size: 18.w,
                                  color: theme.colorScheme.onErrorContainer),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  MarketplaceStrings.youreOffline,
                                  style: textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Place order button
                      Semantics(
                        button: true,
                        label: MarketplaceStrings.placeOrder,
                        enabled: !_isPlacingOrder && isOnline,
                        child: AppButton(
                          label: _isPlacingOrder
                              ? MarketplaceStrings.placingOrder
                              : MarketplaceStrings.placeOrder,
                          onPressed: (_isPlacingOrder || !isOnline)
                              ? null
                              : _placeOrder,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
