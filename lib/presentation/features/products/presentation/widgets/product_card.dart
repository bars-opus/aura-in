// lib/features/products/presentation/widgets/product_card.dart

import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label:
          'Product: ${product.name}, ${product.formattedPrice}'
          '${product.stockQuantity == 0 ? ', out of stock' : ''}'
          '${product.shopVerified == true ? ', from a verified shop' : ''}',
      child: CardInkWell(
        padding: const EdgeInsets.all(Spacing.sm),
        onTap: onTap,
        child: InfoRowWidget(
          isNotAvatarImage: true,
          subtitle: product.description ?? '',
          title: product.name,
          icon: Icons.image_outlined,
          iconSize: 50.0,
          imageUrl: product.images.first,
          titleFontSize: FontSizeTokens.lg,
          avatarRadius: 70.h,
          subTitleMaxLines: 2,
          onTap: onTap,
          disableTrailing: false,
          showAvatar: false,
          showDivider: false,
          showTrailingArrow: false,
          trailing: Column(
            children: [
              Text(
                product.formattedPrice,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (product.totalOrdersCount > 0)
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 14.w,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${product.totalOrdersCount} orders',
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          bottomWidget: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Row(
              children: [
                if (!product.isActive)
                  _StatusChip(label: 'Inactive', color: Colors.grey.shade200)
                else if (product.stockQuantity == 0)
                  _StatusChip(
                    label: 'Out of stock',
                    color: theme.colorScheme.errorContainer,
                  )
                else if (product.stockQuantity <= 5)
                  _StatusChip(
                    label: 'Only ${product.stockQuantity} left',
                    color: theme.colorScheme.tertiaryContainer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: Spacing.xs),
    child: MiniContainerIndicator(
      color: color,
      text: label,
      // fontSize: 20,
    ),
  );

  //  Container(
  //   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
  //   decoration: BoxDecoration(
  //     color: color,
  //     borderRadius: BorderRadius.circular(4.r),
  //   ),
  //   child: Text(label, style: textTheme.labelSmall?.copyWith(color: textColor)),
  // );
}
