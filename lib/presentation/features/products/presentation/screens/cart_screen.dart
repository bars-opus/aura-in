import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/customer_orders_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/qty_stepper.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,

        actions: [
          if (_selectedTabIndex == 0 && !cartState.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: Spacing.md),
              child: AppTextButton(
                textColor: colorScheme.error,
                onPressed: () {
                  BottomSheetUtils.showDocumentationBottomSheet(
                    context: context,
                    maxHeight: 350.h,
                    widget: ConfirmationDialog(
                      icon: Icons.delete,
                      type: ConfirmationType.warning,
                      title:
                          'Are you sure you want to remove all items from your cart?',
                      confirmText: 'Clear All',
                      message: '',
                      onConfirm: () {
                        cartNotifier.clearCart();
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                text: 'Clear All',
              ),
            ),
        ],
      ),

      body: TabsWithContent(
        onTabChanged: (index) => setState(() => _selectedTabIndex = index),
        scrollable: false,
        showContent: true,
        tabs: [
          AppTabItem(
            icon: null,
            label: MarketplaceStrings.cartTitle,
            // icon: Icons.shopping_cart_outlined,
            content: _buildCartContent(
              context,
              cartState,
              cartNotifier,
              theme,
              textTheme,
            ),
          ),
          const AppTabItem(
            label: 'Orders',
            icon: null,
            // icon: Icons.receipt_long_outlined,
            content: CustomerOrdersTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartState cartState,
    CartNotifier cartNotifier,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    if (cartState.isEmpty) return _buildEmptyCart();

    return Column(
      children: [
        if (cartState.error != null) ErrorStateWidget(title: cartState.error!),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: cartState.items.length,
            itemBuilder: (context, index) {
              final item = cartState.items[index];
              return _buildCartItem(context, item, cartNotifier, theme);
            },
          ),
        ),
        CardInkWell(
          margin: const EdgeInsets.all(0),
          child: Column(
            children: [
              InfoRowWidget(
                subtitle: '',
                title: '${cartState.itemCount} item(s)',
                icon: Icons.memory,
                iconSize: 0.0,
                avatarRadius: 25.h,
                onTap: () {},
                disableTrailing: false,
                showAvatar: false,
                showDivider: false,
                showTrailingArrow: false,
                trailing: Text(
                  Currency.formatWithCurrency(
                    cartState.totalAmount,
                    currencySymbol: cartState.currencySymbol,
                    currencyCode: cartState.currencyCode,
                  ),
                  semanticsLabel:
                      'Total ${Currency.formatWithCurrency(cartState.totalAmount, currencySymbol: cartState.currencySymbol, currencyCode: cartState.currencyCode)}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Gap(Spacing.md),
              AppButton(
                height: 40.h,
                label: MarketplaceStrings.proceedToCheckout,
                onPressed: () => context.pushNamed('checkout'),
                padding: Spacing.horizontalMd,
                size: ButtonSize.small,
                width: double.infinity,
              ),
              Gap(Spacing.lg.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItemModel item,
    CartNotifier cartNotifier,
    ThemeData theme,
  ) {
    return CardInkWell(
      child: InfoRowWidget(
        subtitle: '',
        title: item.productName,
        isNotAvatarImage: true,
        icon: Icons.image_outlined,
        iconSize: 50.0,
        imageUrl: item.imageUrl,
        titleFontSize: FontSizeTokens.lg,
        avatarRadius: 70.h,
        onTap:
            () => context.pushNamed(
              'productDetail',
              extra: <String, String?>{
                'productId': item.productId,
                'coverImageUrl': item.imageUrl ?? '',
              },
            ),
        disableTrailing: false,
        showAvatar: false,
        showDivider: false,
        showTrailingArrow: false,
        trailing: AppIconButton(
          icon: Icons.delete_forever,
          iconColor: Colors.red,
          onPressed: () {
            BottomSheetUtils.showDocumentationBottomSheet(
              context: context,
              maxHeight: 350.h,
              widget: ConfirmationDialog(
                type: ConfirmationType.warning,
                icon: Icons.delete_forever,
                title:
                    'Are you sure you want to remove this item from your cart?',
                confirmText: 'Remove item',
                message: '',
                onConfirm: () {
                  cartNotifier.removeItem(item.productId);
                },
              ),
            );
          },
        ),
        bottomWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Currency.formatWithCurrency(
                item.price,
                currencySymbol: item.currencySymbol,
                currencyCode: item.currencyCode,
              ),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            QtyStepper(
              quantity: item.quantity,
              max: item.stockQuantity,
              onChanged: (q) => cartNotifier.updateQuantity(item.productId, q),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: EmptyStateWidget(
        subtitle: MarketplaceStrings.cartEmptySubtitle,
        title: MarketplaceStrings.cartEmpty,
        icon: Icons.shopping_cart_outlined,
      ),
    );
  }
}
