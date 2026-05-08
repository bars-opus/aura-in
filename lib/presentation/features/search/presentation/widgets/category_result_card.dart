// lib/features/search/presentation/widgets/category_result_card.dart

import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_card.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/nearby_freelancer_dto.dart';
import 'package:nano_embryo/presentation/features/search/models/freelancer_search_result.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_search_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_search_result.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_card.dart';

class CategoryResultCard extends ConsumerWidget {
  final UnifiedSearchResult result;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const CategoryResultCard({
    super.key,
    required this.result,
    this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final String userId = user?.id ?? '';

    // Check the type and build appropriate card
    if (result is ShopSearchResult) {
      return _buildShopCard(result as ShopSearchResult);
    } else if (result is ProfileSearchResult) {
      return _buildProfileCard(context, userId, result as ProfileSearchResult);
    } else if (result is FreelancerSearchResult) {
      return _buildFreelancerCard(context, result as FreelancerSearchResult);
    } else {
      return _buildDefaultCard();
    }
  }

  /// Shop Card - Horizontal for "All" view, Vertical for category view
  Widget _buildShopCard(ShopSearchResult shop) {
    return SizedBox(
      height: 400.h,
      child: ShopCard(
        showIcon: !isHorizontal,
        shopName: shop.title,
        luxuryLevel: shop.luxuryLevel ?? '',
        averageRating: shop.averageRating ?? 0,
        distanceKm: shop.distanceKm ?? 0,
        numberClientsWorked: shop.reviewCount ?? 0,
        shopId: shop.id,
        coverImageUrl: shop.imageUrl,
      ),
    );
  }

  /// Profile Card - Always Vertical
  Widget _buildProfileCard(
    BuildContext context,
    String currentUserId,
    ProfileSearchResult profile,
  ) {
    return ProfileHeader(
      mode: ProfileHeaderMode.compact,
      displayName: profile.title,
      userId: profile.id,
      avatarUrl: profile.avatarUrl,
      bio: profile.briefDescription,
      enableHero: false,
      onProfileNavigatePressed: () {
        context.push(
          '/profileScreen',
          extra: {
            'profileUserId': profile.id,
            'currentUserId': currentUserId,
            'profileSearchResult': profile,
          },
        );
      },
    );
  }

  /// Freelancer Card - Always Vertical (uses existing FreelancerCard)
  Widget _buildFreelancerCard(
    BuildContext context,
    FreelancerSearchResult freelancer,
  ) {
    // Convert FreelancerSearchResult to NearbyFreelancerDTO for the existing card
    final nearbyFreelancer = NearbyFreelancerDTO(
      id: freelancer.id,
      name: freelancer.name,
      profileImage: freelancer.profileImage,
      bio: freelancer.bio,
      specialties: freelancer.specialties,
      freelancerType: freelancer.freelancerType,
      freelancerTypes: freelancer.freelancerTypes,
      tools: freelancer.tools,
      canTravel: freelancer.canTravel,
      travelRadiusKm: freelancer.travelRadiusKm,
      averageRating: freelancer.averageRating,
      totalReviews: freelancer.totalReviews,
      totalBookings: freelancer.totalBookings,
      totalRevenue: freelancer.totalRevenue,
      distanceKm: freelancer.distanceKm,
      baseLatitude: freelancer.baseLatitude,
      baseLongitude: freelancer.baseLongitude,
      isIdentityVerified: freelancer.isIdentityVerified,
      isBackgroundChecked: freelancer.isBackgroundChecked,
    );

    return FreelancerCard(
      freelancer: nearbyFreelancer,
      onTap: () {
        context.push(
          '/freelancerDetailsScreen',
          extra: {
            'freelancerId': freelancer.id,
            'coverImageUrl': freelancer.profileImage,
          },
        );
      },
    );
  }

  /// Default Card for unknown types or when category-specific cards aren't available
  Widget _buildDefaultCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                  image:
                      result.imageUrl != null
                          ? DecorationImage(
                            image: NetworkImage(result.imageUrl!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    result.imageUrl == null
                        ? Icon(
                          _getDefaultIcon(),
                          size: 24.h,
                          color: Colors.grey.shade400,
                        )
                        : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      result.briefDescription,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        result.category.displayName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20.h,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (result.category) {
      case SearchCategory.shops:
        return Icons.store;
      case SearchCategory.profiles:
        return Icons.person;
      case SearchCategory.freelancers:
        return Icons.work;
      case SearchCategory.products:
        return Icons.shopping_bag;
      default:
        return Icons.search;
    }
  }
}
