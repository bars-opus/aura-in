// lib/features/products/presentation/screens/shop_products_screen.dart


import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_form_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_card.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

class ShopProductsScreen extends ConsumerWidget {
  final String shopId;

  const ShopProductsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopProductsPagedProvider(shopId));
    final notifier = ref.read(shopProductsPagedProvider(shopId).notifier);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      
      appBar: AppBar(
        title: Text(
          'My Products',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Add product',
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.pushNamed(
                'productForm',
                extra: {'shopId': shopId, 'mode': FormMode.create},
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(context, state, notifier, theme, textTheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PagedListState<ProductModel> state,
    ShopProductsPagedNotifier notifier,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    if (state.isInitialLoading) {
      return const Center(child: CircularLoadingIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48.w, color: theme.colorScheme.error),
            SizedBox(height: 16.h),
            Text('Failed to load products', style: textTheme.titleMedium),
            SizedBox(height: 8.h),
            Text(state.error!,
                style: textTheme.bodySmall, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            AppButton(
              label: 'Retry',
              onPressed: notifier.refresh,
              size: ButtonSize.small,
            ),
          ],
        ),
      );
    }
    if (state.items.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            notifier.loadNext();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: state.items.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            final product = state.items[index];
            return ProductCard(
              product: product,
              onTap: () => context.pushNamed(
                'productForm',
                extra: {
                  'shopId': shopId,
                  'mode': FormMode.edit,
                  'product': product,
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 80.w,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No products yet',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start selling your products by adding your first item',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          AppButton(
            label: 'Add Product',
            onPressed: () => context.pushNamed(
              'productForm',
              extra: {'shopId': shopId, 'mode': FormMode.create},
            ),
            width: 200.w,
          ),
        ],
      ),
    );
  }
}
