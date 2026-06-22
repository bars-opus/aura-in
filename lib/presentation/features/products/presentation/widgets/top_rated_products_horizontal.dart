import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_grid_item.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_header.dart';

/// Most-ordered products rail on the discover Buy tab. Mirrors TopRatedShopsHorizontal.
class TopRatedProductsHorizontal extends ConsumerWidget {
  const TopRatedProductsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topRatedAsync = ref.watch(topRatedProductsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return topRatedAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return CardInkWell(
          onTap: () {},
          margin: EdgeInsets.only(bottom: Spacing.sm.h),
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(Spacing.lg.h),
              CategoryHeader(
                title: 'Top Sellers',
                body: 'Most ordered products',
                showSeeAll: false,
                onPressed: () {},
              ),
              Gap(Spacing.md.h),
              Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: SizedBox(
                  height: 400.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => Gap(Spacing.md.w),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return SizedBox(
                        width: 250.w,
                        child: ProductGridItem(
                          product: product,
                          showVertical: false,
                          onTap:
                              () => context.pushNamed(
                                'productDetail',
                                extra: <String, String?>{
                                  'productId': product.id,
                                  'coverImageUrl':
                                      product.images.firstOrNull ?? '',
                                },
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Gap(Spacing.lg.h),
            ],
          ),
        );
      },
      loading:
          () => CardInkWell(
            onTap: () {},
            margin: EdgeInsets.only(bottom: Spacing.sm.h),
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(Spacing.lg.h),
                CategoryHeader(
                  title: 'Top Sellers',
                  body: '',
                  showSeeAll: false,
                  onPressed: () {},
                ),
                Gap(Spacing.md.h),
                SizedBox(
                  height: 230.h,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Gap(Spacing.lg.h),
              ],
            ),
          ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
