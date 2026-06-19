// lib/features/freelancer/presentation/widgets/near_you_freelancers_horizontal.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_discovery_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/near_you_freelancers_screen.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_card.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/horizontal_freelancer_section.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/horizontal_shop_section.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_no_location_set.dart';

class NearYouFreelancersHorizontal extends ConsumerWidget {
  const NearYouFreelancersHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearYouAsync = ref.watch(nearYouFreelancersProvider);
    final userLocation = ref.watch(userLocationNotifierProvider);
    final loc = AppLocalizations.of(context)!;
    String title = loc.nearYouFreelancersHorizontalTitle(userLocation?.displayName ?? '');
    final hasLocation = ref.watch(hasLocationProvider);

    if (!hasLocation) {
      return SizedBox.shrink();
    }

    return nearYouAsync.when(
      data: (freelancers) {
        if (freelancers.isEmpty) {
          return _buildEmptyState(context);
        }

        return HorizontalFreelancerSection(
          title: title,
          titleIcon: Icons.near_me,
          titleIconColor: Colors.purple,
          freelancers: freelancers,
          isLoading: false,
          body: loc.nearYouFreelancersHorizontalBody,
          onSeeAllPressed: () {
            context.push('/nearYouFreelancersScreen');
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
            titleIcon: Icons.near_me,
            titleIconColor: Colors.purple,
            shops: const [],
            isLoading: true,
            onShopTap: (_) {},
          ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: () {},
      child: EmptyStateWidget(
        icon: Icons.near_me,
        type: EmptyStateType.noShops,
        compact: true,
        title: loc.nearYouFreelancersHorizontalEmpty,
        subtitle: loc.nearYouFreelancersHorizontalEmptySubtitle,
      ),
    );
  }
}


//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final nearYouAsync = ref.watch(nearYouFreelancersProvider);
//     final hasLocation = ref.watch(hasLocationProvider);
//     final colorScheme = Theme.of(context).colorScheme;

    // if (!hasLocation) {
    //   return _buildNoLocationState(context, ref);
    // }

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
//                   Icon(
//                     Icons.near_me,
//                     color: colorScheme.primary,
//                     size: 20.sp,
//                   ),
//                   Gap(Spacing.xs.w),
//                   Text(
//                     'Freelancers Near You',
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
//                       builder: (_) => const NearYouFreelancersScreen(),
//                     ),
//                   );
//                 },
//                 child: const Text('See all'),
//               ),
//             ],
//           ),
//         ),
//         Gap(Spacing.sm.h),
//         nearYouAsync.when(
//           data: (freelancers) {
//             if (freelancers.isEmpty) {
//               return _buildEmptyState(context);
//             }
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
//                       // compact: true,
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

//   Widget _buildNoLocationState(BuildContext context, WidgetRef ref) {
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
//                   Icon(Icons.near_me, color: colorScheme.primary, size: 20.sp),
//                   Gap(Spacing.xs.w),
//                   Text(
//                     'Freelancers Near You',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Gap(Spacing.md.h),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: Spacing.md.w),
//           padding: EdgeInsets.all(Spacing.lg.h),
//           decoration: BoxDecoration(
//             color: colorScheme.surface,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 Icons.location_off,
//                 size: 48.sp,
//                 color: colorScheme.onSurface.withOpacity(0.3),
//               ),
//               Gap(Spacing.md.h),
//               Text(
//                 'Set your location to discover',
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               Text(
//                 'freelancers near you',
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               Gap(Spacing.md.h),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   showModalBottomSheet(
//                     context: context,
//                     isScrollControlled: true,
//                     backgroundColor: Colors.transparent,
//                     builder: (context) => const LocationPickerBottomSheet(),
//                   );
//                 },
//                 icon: const Icon(Icons.location_on),
//                 label: const Text('Set Location'),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
    
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: Spacing.md.w),
//       padding: EdgeInsets.all(Spacing.lg.h),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.person_outline,
//             size: 48.sp,
//             color: colorScheme.onSurface.withOpacity(0.3),
//           ),
//           Gap(Spacing.md.h),
//           Text(
//             'No freelancers found nearby',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           Gap(Spacing.sm.h),
//           Text(
//             'Try expanding your search radius',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
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
