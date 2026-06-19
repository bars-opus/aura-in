import 'package:nano_embryo/core/widgets/custom_universal_tab/simple_provider_tab.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ProviderTypeTabs extends ConsumerWidget {
  const ProviderTypeTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedProviderTypeProvider);
    final loc = AppLocalizations.of(context)!;

    final tabs = [
      SimpleProviderTabItem<ProviderType>(
        label: loc.providerTypeShops,
        icon: Icons.storefront_outlined,
        selectedIcon: Icons.storefront_rounded,
        value: ProviderType.shops,
      ),
      SimpleProviderTabItem<ProviderType>(
        label: loc.providerTypeFreelancers,
        icon: Icons.person_2_outlined,
        selectedIcon: Icons.person_2,
        value: ProviderType.freelancers,
      ),
      SimpleProviderTabItem<ProviderType>(
        label: loc.providerTypeBuy,
        icon: Icons.shopping_bag_outlined,
        selectedIcon: Icons.shopping_bag,
        value: ProviderType.buy,
      ),
    ];

    return SimpleProviderTabs<ProviderType>(
      tabs: tabs,
      selectedValue: selectedType,
      onValueSelected: (value) {
        ref.read(selectedProviderTypeProvider.notifier).selectType(value);
      },
    );
  }
}
