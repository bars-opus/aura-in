import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/checkout_screen.dart';


class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!cartState.isEmpty)
            TextButton(
              onPressed: () => _showClearCartDialog(context, cartNotifier),
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 14.sp,
                ),
              ),
            ),
        ],
      ),
      body: cartState.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return _buildCartItem(
                        item,
                        cartNotifier,
                        theme,
                      );
                    },
                  ),
                ),
                
                // Bottom checkout bar
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8.r,
                        offset: Offset(0, -2.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            '₦${cartState.totalAmount.toStringAsFixed(2)}',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${cartState.itemCount} item(s)',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AppButton(
                        label: 'Proceed to Checkout',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        },
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(
    CartItemModel item,
    CartNotifier cartNotifier,
    ThemeData theme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 80.w,
              height: 80.w,
              color: Colors.grey.shade200,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_outlined,
                          size: 32.w,
                          color: Colors.grey.shade400,
                        );
                      },
                    )
                  : Icon(
                      Icons.image_outlined,
                      size: 32.w,
                      color: Colors.grey.shade400,
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  item.shopName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${item.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 20.w),
                          onPressed: () {
                            cartNotifier.updateQuantity(
                              item.productId,
                              item.quantity - 1,
                            );
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.all(4.w),
                        ),
                        Container(
                          width: 40.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 20.w),
                          onPressed: () {
                            cartNotifier.updateQuantity(
                              item.productId,
                              item.quantity + 1,
                            );
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.all(4.w),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Delete button
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20.w),
            onPressed: () {
              cartNotifier.removeItem(item.productId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80.w,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your cart is empty',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add items from the marketplace to get started',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          AppButton(
            label: 'Browse Products',
            onPressed: () {
              Navigator.pop(context);
            },
            width: 200.w,
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartNotifier cartNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cartNotifier.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
