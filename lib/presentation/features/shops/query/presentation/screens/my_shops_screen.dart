// lib/features/shop/context/presentation/screens/my_shops_screen.dart

import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/shop_creation.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/edit_shop_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class MyShopsScreen extends ConsumerStatefulWidget {
  const MyShopsScreen({super.key});

  @override
  ConsumerState<MyShopsScreen> createState() => _MyShopsScreenState();
}

class _MyShopsScreenState extends ConsumerState<MyShopsScreen> {
  @override
  void initState() {
    super.initState();
    // Load shops when screen opens
    Future.microtask(() {
      ref.refresh(userShopsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shopsAsync = ref.watch(userShopsProvider);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Text(
          'Edit shops',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userShopsProvider);
        },
        child: shopsAsync.when(
          data: (shops) {
            if (shops.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: EdgeInsets.all(Spacing.md.h),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return _buildShopCard(shop);
              },
            );
          },
          loading:
              () => ListView.builder(
                padding: EdgeInsets.all(Spacing.md.h),
                itemCount: 3,
                itemBuilder:
                    (_, __) => Padding(
                      padding: EdgeInsets.only(bottom: Spacing.md.h),
                      child: ShopSchimmerSkeleton(height: 150.h),
                    ),
              ),
          error:
              (error, _) => Center(
                child: ErrorStateWidget(
                  title: '',
                  subtitle: 'Failed to load shops',
                  onPrimaryAction: () {
                    ref.invalidate(userShopsProvider);
                  },
                ),
              ),
        ),
      ),

      bottomNavigationBar: ShakeTransition(
        axis: Axis.vertical,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Spacing.md.h),
            child: AppButton(
              elevation: 0,
              label: 'Add a new shop',
              center: false,
              iconData: Icons.storefront_rounded,
              
              prefixIcon: Icons.add,
              prefixIconColor: colorScheme.background,
              onPressed: _createNewShop,
              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 40.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SizedBox(
        height: 300.h,
        child: CardInkWell(
          elevation: 0,
          padding: const EdgeInsets.all(0),
          child: Center(
            child: EmptyStateWidget(
              icon: Icons.storefront_rounded,
              title: 'No shops yet',
              subtitle: 'Create your first shop to get started',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(ShopListItemDTO shop) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      height: 400.h,
      child: Stack(
        alignment: FractionalOffset.topRight,
        children: [
          ShopCard(
            showIcon: false,
            shopName: shop.shopName,
            luxuryLevel: shop.luxuryLevel ?? '',
            averageRating: shop.averageRating ?? 0,
            distanceKm: shop.distanceKm ?? 0,
            numberClientsWorked: shop.numberClientsWorked ?? 0,
            shopId: shop.id,
            coverImageUrl: shop.coverImageUrl,
          ),

          Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: AppIconButton(
              iconColor: colorScheme.onPrimary,
              backgroundColor: colorScheme.primary,
              icon: Icons.edit,
              onPressed: () {
                _editShop(shop.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createNewShop() async {
    // Navigate to shop creation
    // Clear any existing draft before creating a new shop
    final profileId = ref.read(currentProfileIdProvider);
    if (profileId != null) {
      final storage = ref.read(localDraftStorageProvider);
      await storage.clearDraft(profileId);
    }

    // Also clear the in-memory provider state
    ref.read(shopCreationProvider.notifier).clearDraft();
    context.push('/shopCreation', extra: ShopMode.create);
    // context.push('/shop-creation');
  }

  void _editShop(String shopId) {
    // Invalidate so the notifier is recreated and loadShopData() runs fresh.
    // Without this, the cached notifier from a previous edit never re-fetches.
    ref.invalidate(editShopProvider(shopId));
    context.push('/editShop', extra: shopId);
  }

  // void _viewAnalytics(String shopId) {
  //   context.push('/shop-analytics/$shopId');
  // }
}
