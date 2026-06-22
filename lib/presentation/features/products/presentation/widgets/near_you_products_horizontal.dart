import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_grid_item.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_header.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';

/// Products near the user on the discover Buy tab. Mirrors NearYouShopsHorizontal.
/// Hidden when location is unavailable.
class NearYouProductsHorizontal extends ConsumerWidget {
  const NearYouProductsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLocation = ref.watch(hasLocationProvider);
    if (!hasLocation) return const SizedBox.shrink();

    final nearYouAsync = ref.watch(nearYouProductsProvider);
    final radiusKm = ref.watch(searchRadiusKmProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final title = 'Products within ${radiusKm.toInt()} km';

    return nearYouAsync.when(
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
                title: title,
                body: 'Products available near you',
                showSeeAll: false,
                onPressed: () {},
              ),
              Gap(Spacing.md.h),
              Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: SizedBox(
                  height: 230.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => Gap(Spacing.md.w),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return SizedBox(
                        width: 160.w,
                        child: ProductGridItem(
                          showVertical: false,
                          product: product,
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
                  title: title,
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
