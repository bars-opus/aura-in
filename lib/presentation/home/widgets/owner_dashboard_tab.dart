import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_role.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart';

class OwnerDashboardTab extends ConsumerStatefulWidget {
  final AccountType role;

  const OwnerDashboardTab({super.key, required this.role});

  @override
  ConsumerState<OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}



class _OwnerDashboardTabState extends ConsumerState<OwnerDashboardTab> {
  bool _redirecting = false;
  bool _initializingShop = false;

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(userShopsProvider);
    final currentShop = ref.watch(currentShopProvider);
    final isFreelancer =
        ref.watch(currentUserIsFreelancerProvider).valueOrNull ?? false;

    return shopsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => ErrorStateWidget(
            title: 'Could not load shops',
            subtitle: e.toString(),
            type: ErrorStateType.genericError,
          ),
      data: (shops) {
        if (shops.isEmpty) {
          if (!_redirecting) {
            _redirecting = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go(RouteNames.shopCreation);
            });
          }
          return const Center(child: CircularProgressIndicator());
        }

        // currentShopProvider holds full ShopDetailsDTO, needed for all params.
        // Initialise after this frame so persistent sibling tabs are never
        // dirtied while Flutter is building this tab.
        final currentShopIsOwned =
            currentShop != null &&
            shops.any((shop) => shop.id == currentShop.id);
        if (!currentShopIsOwned) {
          _initializeShop(shops);
          return const Center(child: CircularProgressIndicator());
        }

        return OwnerDashboardScreen(
          shopId: currentShop.id,
          shopOwnerId: currentShop.userId,
          accountType: widget.role.value,
          shopName: currentShop.shopName,
          shopCurrencyCode: currentShop.currency ?? '',
          shopCountry: currentShop.country ?? '',
          isFreelancer: isFreelancer,
        );
      },
    );
  }

  void _initializeShop(List<ShopListItemDTO> shops) {
    if (_initializingShop) return;
    _initializingShop = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final preferredId =
            ref.read(ownerShopPreferenceProvider).selectedShopId;
        final shopId =
            shops.any((shop) => shop.id == preferredId)
                ? preferredId!
                : shops.first.id;
        final full = await ref.read(shopByIdProvider(shopId).future);
        if (full != null && mounted) {
          ref.read(currentShopProvider.notifier).state = full;
          await ref.read(ownerShopPreferenceProvider).save(full.id);
        }
      } finally {
        _initializingShop = false;
      }
    });
  }
}
