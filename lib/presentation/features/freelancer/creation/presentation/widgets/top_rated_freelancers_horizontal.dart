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
    String title = 'Top Rated \nin ${userLocation?.displayName}';
    final hasLocation = ref.watch(hasLocationProvider);

    if (!hasLocation) {
      return ShopNoLocationSet();
    }
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
          body:
              'Handpicked high‑end salons and spas offering luxury experiences. These shops are classified as Luxury or Ultra‑Luxury based on their services, pricing, and customer reviews. Perfect when you\'re looking for that extra touch of elegance.',
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
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: () {},
      child: EmptyStateWidget(
        icon: Icons.person_2,
        type: EmptyStateType.noShops,
        compact: true,
        title: 'No top rated freelancers available',
        subtitle: 'Freelancers would be shown here once they become available',
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final topRatedAsync = ref.watch(topRatedFreelancersProvider);
//     final colorScheme = Theme.of(context).colorScheme;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.amber, size: 20.sp),
//                   Gap(Spacing.xs.w),
//                   Text(
//                     'Top Rated Freelancers',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const TopRatedFreelancersScreen(),
//                     ),
//                   );
//                 },
//                 child: const Text('See all'),
//               ),
//             ],
//           ),
//         ),
//         Gap(Spacing.sm.h),
        // topRatedAsync.when(
        //   data: (freelancers) {
//             if (freelancers.isEmpty) return const SizedBox.shrink();
//             return SizedBox(
//               height: 220.h,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
//                 itemCount: freelancers.length,
//                 separatorBuilder: (_, __) => Gap(Spacing.md.w),
//                 itemBuilder: (context, index) {
//                   final freelancer = freelancers[index];
//                   return SizedBox(
//                     width: 200.w,
//                     child: FreelancerCard(
//                       freelancer: freelancer,
//                       onTap: () {
//                         context.push('/freelancer/${freelancer.id}');
//                       },
//                       // compact: true, // You'll need to add this to FreelancerCard
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//           loading: () => _buildLoadingShimmer(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadingShimmer() {
//     return SizedBox(
//       height: 220.h,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
//         itemCount: 3,
//         separatorBuilder: (_, __) => Gap(Spacing.md.w),
//         itemBuilder: (_, __) => Container(
//           width: 200.w,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//       ),
//     );
//   }
// }
