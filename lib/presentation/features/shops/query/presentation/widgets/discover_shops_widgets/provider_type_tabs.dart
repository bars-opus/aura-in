// lib/features/discover/widgets/provider_type_tabs.dart

import 'package:nano_embryo/core/widgets/custom_universal_tab/simple_provider_tab.dart';
import 'package:nano_embryo/core/widgets/custom_universal_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ProviderTypeTabs extends ConsumerWidget {
  const ProviderTypeTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedProviderTypeProvider);

    return SimpleProviderTabs<ProviderType>(
      tabs: [
        SimpleProviderTabItem(
          label: 'Shops',
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront_rounded,
          value: ProviderType.shops,
        ),
        SimpleProviderTabItem(
          label: 'Freelancers',
          icon: Icons.person_2_outlined,
          selectedIcon: Icons.person_2,
          value: ProviderType.freelancers,
        ),
        SimpleProviderTabItem(
          label: 'Buy',
          icon: Icons.shopping_bag_outlined,
          selectedIcon: Icons.shopping_bag,
          value: ProviderType.buy,
        ),
      ],
      selectedValue: selectedType,
      // Just update the selection state. Each content sliver (ShopListSliver,
      // FreelancerGridSliver) is responsible for loading its own data when it
      // enters the widget tree. shopListProvider auto-reacts to filter changes
      // via ref.watch in its build(), so no manual load call is needed here.
      onValueSelected: (value) {
        ref.read(selectedProviderTypeProvider.notifier).selectType(value);
      },
    );
  }
}
