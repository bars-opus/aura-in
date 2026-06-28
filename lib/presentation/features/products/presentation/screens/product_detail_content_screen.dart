import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/qty_stepper.dart';
import 'package:nano_embryo/core/link/entity_share_links.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/tab_bar_delegate.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_pageview.dart';

/// Tabbed shell for product detail — the product analogue of ShopDetailsContent.
/// Cover image + pinned TabBar (Info / Reviews) + the Add-to-Cart bar (with an
/// inline quantity stepper) pinned at the bottom, mirroring the shop "Book now"
/// bar.
class ProductDetailContent extends ConsumerStatefulWidget {
  final ProductModel product;
  final TabController tabController;
  final List<AppTabItem> tabs;

  const ProductDetailContent({
    super.key,
    required this.product,
    required this.tabController,
    required this.tabs,
  });

  @override
  ConsumerState<ProductDetailContent> createState() =>
      _ProductDetailContentState();
}

class _ProductDetailContentState extends ConsumerState<ProductDetailContent> {
  int _quantity = 1;
  bool _isAddingToCart = false;

  ProductModel get _product => widget.product;

  Future<void> _addToCart() async {
    final colorScheme = Theme.of(context).colorScheme;

    final product = _product;
    if (_isAddingToCart) return;

    if (!product.isActive) {
      _toast('This product is no longer available.');
      return;
    }
    if (product.stockQuantity < _quantity) {
      _toast(
        product.stockQuantity == 0
            ? 'Out of stock'
            : 'Only ${product.stockQuantity} left in stock',
      );
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final shopName =
          product.shopName ??
          (await ref.read(shopNameByIdProvider(product.shopId).future));

      final item = CartItemModel(
        productId: product.id,
        productName: product.name,
        price: product.price,
        imageUrl: product.images.isNotEmpty ? product.images.first : null,
        quantity: _quantity,
        shopId: product.shopId,
        shopName: shopName ?? 'Unknown shop',
        currencySymbol: product.shopCurrencySymbol,
        currencyCode: product.shopCurrencyCode,
        stockQuantity: product.stockQuantity,
      );

      await ref.read(cartNotifierProvider.notifier).addItem(item);

      if (!mounted) return;
      context.showSuccessSnackbar(
        backgroundColor: colorScheme.success,
        MarketplaceStrings.addedToCart,
      );
    } on MultiShopCartException catch (_) {
      if (!mounted) return;
      final confirmed = await _confirmReplaceCart();
      if (confirmed == true && mounted) {
        await ref.read(cartNotifierProvider.notifier).clearCart();
        if (!mounted) return;
        await _addToCart();
        return;
      }
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('add to cart rejected', error: e, stack: stack);
      _toast(e.message);
    } catch (e, stack) {
      MarketplaceLogger.error('add to cart failed', error: e, stack: stack);
      _toast('Failed to add to cart');
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    context.showInfoSnackbar(msg);
  }

  /// Opens the More actions sheet (Report / Block / Share). There is no
  /// product-level moderation type, so Report/Block target the SHOP that sells
  /// the product. The shop owner id (targetOwnerId) isn't on ProductModel, so
  /// we resolve it from the cached shop record on tap.
  Future<void> _openMore(ProductModel product) async {
    final shop = await ref.read(shopByIdProvider(product.shopId).future);
    if (!mounted) return;
    final ownerId = shop?.userId ?? '';
    // Block/Report act on the shop owner. Without a resolved owner id we'd let
    // the user "block nobody" — fail clearly instead of opening a broken sheet.
    if (ownerId.isEmpty) {
      _toast('Could not load shop details. Please try again.');
      return;
    }
    BottomSheetUtils.showDocumentationBottomSheet(
      padding: Spacing.md,
      maxHeight: 570.h,
      context: context,
      widget: MoreScreen(
        moderationTarget: ModerationTarget(
          targetType: ModerationTargetType.shop,
          targetId: product.shopId,
          targetOwnerId: ownerId,
          displayName: product.shopName ?? shop?.shopName ?? 'Shop',
        ),
        // Real destination: the shop's public products page.
        shareUrl: EntityShareLinks.shopProducts(shop?.productsSlug),
      ),
    );
  }

  String _buttonLabel(ProductModel product) {
    if (_isAddingToCart) return MarketplaceStrings.addingToCart;
    if (_isOwnProduct) return 'Your product';
    if (!product.isActive) return MarketplaceStrings.unavailable;
    if (product.stockQuantity == 0) return MarketplaceStrings.outOfStock;
    return '${MarketplaceStrings.addToCart} '
        '(${Currency.formatWithCurrency(product.price * _quantity, currencySymbol: product.shopCurrencySymbol, currencyCode: product.shopCurrencyCode)})';
  }

  Future<bool?> _confirmReplaceCart() => showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text(MarketplaceStrings.replaceCartTitle),
          content: const Text(MarketplaceStrings.replaceCartBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(MarketplaceStrings.keepCart),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(MarketplaceStrings.replace),
            ),
          ],
        ),
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final product = _product;

    return Scaffold(
      backgroundColor: colorScheme.neutral,

      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 400.h,
              pinned: true,
              leading: Center(
                child: AppIconButton(
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: colorScheme.surface.withValues(alpha: .6),
                  icon:
                      Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                ),
              ),
              actions: [
                AppIconButton(
                  onPressed: () => _openMore(product),
                  backgroundColor: colorScheme.surface.withValues(alpha: .6),
                  icon: Icons.more_vert,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: ShopImagePageview(
                  isPreview: false,
                  shopImageUrls: product.images,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: TabBarDelegate(
                tabs: widget.tabs,
                tabController: widget.tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: widget.tabController,
          children:
              widget.tabs
                  .map((tab) => tab.content ?? const SizedBox())
                  .toList(),
        ),
      ),
      bottomNavigationBar: _buildAddToCartBar(context, product),
    );
  }

  /// A seller can't buy their own product — it would create a self-order and
  /// distort their own stock/wallet. True when the current user owns the shop
  /// that sells this product. Defaults to false while the shops list loads.
  bool get _isOwnProduct {
    final shops = ref.watch(userShopsProvider).valueOrNull;
    if (shops == null) return false;
    return shops.any((s) => s.id == _product.shopId);
  }

  Widget _buildAddToCartBar(BuildContext context, ProductModel product) {
    final colorScheme = Theme.of(context).colorScheme;
    final outOfStock = product.stockQuantity == 0;
    final isOwnProduct = _isOwnProduct;
    final disabled =
        _isAddingToCart || !product.isActive || outOfStock || isOwnProduct;

    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity stepper (hidden when out of stock / inactive).
            if (!disabled || _isAddingToCart) ...[
              QtyStepper(
                quantity: _quantity,
                max: product.stockQuantity,
                onChanged: (q) => setState(() => _quantity = q),
              ),
              Gap(Spacing.md.w),
            ],
            Expanded(
              child: Semantics(
                button: true,
                label: _buttonLabel(product),
                enabled: !disabled,

                child: AppButton(
                  elevation: 0,
                  padding: Spacing.allSm,
                  label: _buttonLabel(product),
                  textColor: _isOwnProduct ? colorScheme.success : null,
                  onPressed: disabled ? null : _addToCart,
                  size: ButtonSize.small,
                  width: double.infinity,
                  height: 40.h,
                  isDisabled: disabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
