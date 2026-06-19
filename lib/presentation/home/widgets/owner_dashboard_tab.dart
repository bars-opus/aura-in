import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_role.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/home/widgets/owner_tab_shop_switcher.dart';

class OwnerDashboardTab extends ConsumerStatefulWidget {
  final AccountType role;

  const OwnerDashboardTab({super.key, required this.role});

  @override
  ConsumerState<OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}

class _OwnerDashboardTabState extends ConsumerState<OwnerDashboardTab> {
  bool _redirecting = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      ref.invalidate(userShopsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(userShopsProvider);
    final currentShop = ref.watch(currentShopProvider);
    final isFreelancer =
        ref.watch(currentUserIsFreelancerProvider).valueOrNull ?? false;

    return shopsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(
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
        // OwnerScheduleTab initialises it; we wait if it's still null.
        if (currentShop == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            final full =
                await ref.read(shopByIdProvider(shops.first.id).future);
            if (full != null && mounted) {
              ref.read(currentShopProvider.notifier).state = full;
            }
          });
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            OwnerTabShopSwitcher(shops: shops),
            Expanded(
              child: OwnerDashboardScreen(
                shopId: currentShop.id,
                shopOwnerId: currentShop.userId,
                accountType: widget.role.value,
                shopName: currentShop.shopName,
                shopCurrencyCode: currentShop.currency ?? '',
                shopCountry: currentShop.country ?? '',
                isFreelancer: isFreelancer,
              ),
            ),
          ],
        );
      },
    );
  }
}
