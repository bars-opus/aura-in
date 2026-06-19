// lib/features/freelancer/presentation/widgets/top_rated_freelancers_horizontal.dart

import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_discovery_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/horizontal_freelancer_section.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_no_location_set.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class TopRatedFreelancersHorizontal extends ConsumerWidget {
  const TopRatedFreelancersHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topRatedAsync = ref.watch(topRatedFreelancersProvider);
    final userLocation = ref.watch(userLocationNotifierProvider);
    final loc = AppLocalizations.of(context)!;
    String title = loc.topRatedFreelancersHorizontalTitle(userLocation?.displayName ?? '');
    // final hasLocation = ref.watch(hasLocationProvider);

    // if (!hasLocation) {
    //   return ShopNoLocationSet();
    // }
    return topRatedAsync.when(
      data: (freelancers) {
        if (freelancers.isEmpty) {
          return _buildEmptyState(context);
        }

        return HorizontalFreelancerSection(
          title: title,
          titleIcon: Icons.diamond,
          titleIconColor: Colors.purple,
          freelancers: freelancers,
          isLoading: false,
          body: loc.topRatedFreelancersHorizontalBody,
          onSeeAllPressed: () {
            context.push('/topRatedFreelancersScreen');
          },
          onShopTap: (freelancer) {
            // Navigate to shop details
          },
        );
      },
      loading:
          () => HorizontalShopSection(
            title: title,
            body: '',
            titleIcon: Icons.diamond,
            titleIconColor: Colors.purple,
            shops: const [],
            isLoading: true,
            onShopTap: (_) {},
          ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox.shrink();
  
  }
}
