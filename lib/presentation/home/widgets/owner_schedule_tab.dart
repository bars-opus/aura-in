import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_role.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/presentation/widgets/shop_schedule_hub.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/home/widgets/owner_tab_shop_switcher.dart';

class OwnerScheduleTab extends ConsumerStatefulWidget {
  final AccountType role;

  const OwnerScheduleTab({super.key, required this.role});

  @override
  ConsumerState<OwnerScheduleTab> createState() => _OwnerScheduleTabState();
}

class _OwnerScheduleTabState extends ConsumerState<OwnerScheduleTab> {
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

        // Initialise currentShopProvider with full details on first render.
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
              child: ShopScheduleHub(
                shopId: currentShop.id,
                accountType: widget.role.value,
              ),
            ),
          ],
        );
      },
    );
  }
}
