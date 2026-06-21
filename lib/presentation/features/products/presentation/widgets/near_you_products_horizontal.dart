import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_grid_item.dart';

/// Products near the user on the discover Buy tab. Hidden without location or
/// when empty/error.
class NearYouProductsHorizontal extends ConsumerWidget {
  const NearYouProductsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLocation = ref.watch(hasLocationProvider);
    if (!hasLocation) return const SizedBox.shrink();

    final async = ref.watch(nearYouProductsProvider);
    final theme = Theme.of(context);

    return async.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Row(
                children: [
                  Icon(Icons.near_me, color: Colors.purple, size: 20.sp),
                  Gap(Spacing.xs.w),
                  Text(
                    'Products Near You',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Gap(Spacing.sm.h),
            SizedBox(
              height: 230.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                itemCount: products.length,
                separatorBuilder: (_, __) => Gap(Spacing.md.w),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: 160.w,
                    child: ProductGridItem(
                      product: product,
                      onTap: () => context.pushNamed('productDetail', extra: product.id),
                    ),
                  );
                },
              ),
            ),
            Gap(Spacing.md.h),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
