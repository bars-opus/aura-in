import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/services/business_chat_launcher.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_header_widget.dart';

/// Info tab body for product detail: seller header, name, price, category and
/// description. Pure content (no Scaffold / app bar / add-to-cart) — those live
/// in the ProductDetailContent shell.
class ProductInfoSection extends ConsumerWidget {
  final ProductModel product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.neutral,
      child: ListView(
        padding: EdgeInsets.all(Spacing.md.w),
        children: [
          // Seller identity (shop or product-seller account). Tappable.
          Gap(Spacing.md.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      MiniContainerIndicator(
                        color: colorScheme.primary,
                        text: product.category,
                        fontSize: FontSizeTokens.lg,
                      ),
                      Gap(Spacing.sm.w),
                      if (product.stockQuantity > 0)
                        Text(
                          '${product.stockQuantity} in stock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        )
                      else
                        Text(
                          'Out of stock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Gap(Spacing.md.w),
              Text(
                product.formattedPrice,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),

          Gap(Spacing.lg.h),
          AppDivider(),
          Gap(Spacing.lg.h),

          if (product.description != null &&
              product.description!.isNotEmpty) ...[
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Gap(Spacing.sm.h),
            Text(
              product.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
          Gap(Spacing.lg.h),
          CardInkWell(
            child: _SellerHeader(
              product: product,
              shopId: product.shopId,
              fallbackName: product.shopName,
              fallbackVerified: product.shopVerified ?? false,
              totalOrdersCount: product.totalOrdersCount,
            ),
          ),
          Gap(Spacing.md.h),
          SemanticContainerWidget(
            title: 'Payment on delivery only',
            content:
                'Marketplace product payments are not processed in-app. Buyers pay when the product is delivered or handed over.',
            icon: Icons.account_balance_wallet_outlined,
            backgroundColor: colorScheme.warning.withValues(alpha: 0.08),
            borderColor: colorScheme.warning,
            iconColor: colorScheme.warning,
            textTheme: theme.textTheme,
          ),
          Gap(Spacing.xxl * 2),
        ],
      ),
    );
  }
}

/// Shows who is selling the product. Resolves the product's shop row (a real
/// shop OR the lightweight shop created for a product-seller account) and
/// renders ShopHeaderWidget from it — so buyers see the seller's name, type
/// chip, rating and overview either way. Tapping opens the seller's shop page.
class _SellerHeader extends ConsumerWidget {
  final ProductModel product;
  final String shopId;
  final String? fallbackName;
  final bool fallbackVerified;
  final int totalOrdersCount;

  const _SellerHeader({
    required this.product,
    required this.shopId,
    required this.fallbackName,
    required this.fallbackVerified,
    required this.totalOrdersCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopByIdProvider(shopId));

    Widget headerFromDto(ShopDetailsDTO shop) => Column(
      children: [
        GestureDetector(
          onTap:
              () => context.pushNamed(
                'shopDetailsScreen',
                extra: <String, String?>{
                  'shopId': shop.id,
                  'coverImageUrl': shop.shopLogoUrl ?? '',
                },
              ),
          child: ShopHeaderWidget(
            name: shop.shopName,
            luxuryLevel: shop.luxuryLevel ?? '',
            logoUrl: shop.shopLogoUrl ?? '',
            verified: shop.verified,
            shopType: shop.shopType ?? '',
            latitude: shop.latitude,
            longitude: shop.longitude,
            averageRating: shop.averageRating,
            numberClientsWorked: totalOrdersCount,
            overview: '',
            id: shop.id,
            isShop: true,
          ),
        ),
        AppDivider(),
        SplitActionRow(
          actions: [
            SplitActionRowItem(
              label: 'Message',
              icon: Icons.message_outlined,
              onTap:
                  () => BusinessChatLauncher.openForProduct(
                    context,
                    ref,
                    product,
                  ),
            ),
            SplitActionRowItem(
              label: 'Call',
              icon: Icons.phone_outlined,
              onTap: () async {
                final phone = shop.phone?.trim() ?? '';
                if (phone.isEmpty) {
                  context.showInfoSnackbar('No phone number available');
                  return;
                }
                await UrlLauncherUtils.launchPhone(
                  context: context,
                  phoneNumber: phone,
                );
              },
            ),
          ],
        ),
      ],
    );

    return shopAsync.when(
      data: (shop) => shop == null ? _fallback() : headerFromDto(shop),
      loading: () => _fallback(),
      error: (_, __) => _fallback(),
    );
  }

  Widget _fallback() {
    final name =
        (fallbackName == null || fallbackName!.isEmpty)
            ? 'Seller'
            : fallbackName!;
    return Builder(
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        return Row(
          children: [
            ProfileAvatar(avatarUrl: '', currentUserId: shopId, size: 40.r),
            Gap(20.w),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fallbackVerified) ...[
                    Gap(Spacing.xs.w),
                    Icon(Icons.verified, size: 15.sp, color: Colors.blue),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
