// lib/features/freelancer/presentation/widgets/freelancer_card.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/nearby_freelancer_dto.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/shop_rating_widget.dart';

/// Card widget for displaying a freelancer in discovery lists
class FreelancerCard extends StatelessWidget {
  final NearbyFreelancerDTO freelancer;
  final VoidCallback? onTap;

  const FreelancerCard({super.key, required this.freelancer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displaySpecialties = freelancer.specialties.take(2);
    final remainingCount = freelancer.specialties.length - 2;
    return CardInkWell(
      onTap: onTap ?? () {},
      margin: EdgeInsets.only(bottom: Spacing.md.h),
      padding: EdgeInsets.all(Spacing.md.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(
            bioTextColor: colorScheme.primary,
            mode: ProfileHeaderMode.compact,
            avatarUrl: freelancer.profileImage,
            displayName: freelancer.name,
            userId: freelancer.id,
            bio: freelancer.freelancerType!.displayName,
            onProfileNavigatePressed: onTap,
          ),
          Padding(
            padding: const EdgeInsets.only(left: Spacing.xxl + Spacing.sm),
            child: InfoRowWidget(
              imageUrl: freelancer.profileImage,
              title:
                  remainingCount > 0
                      ? '${displaySpecialties.join(', ')} +$remainingCount more'
                      : displaySpecialties.join(', '),
              subtitle: freelancer.bio ?? '',
              icon: Icons.account_circle_rounded,
              avatarRadius: 0.r,
              titleFontSize: 12,
              titleFontColor: colorScheme.onBackground.withOpacity(.7),
              iconSize: 0.r,
              subTitleMaxLines: 2,
              onTap: onTap,
              disableTrailing: false,
              showAvatar: false,
              showTrailingArrow: false,
              showDivider: false,
              trailing: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: IconSizes.md,
                    color: colorScheme.warning,
                  ),
                  Gap(Spacing.xs.w),
                  Text(
                    freelancer.averageRating == null
                        ? '0'
                        : freelancer.averageRating!.toStringAsFixed(1),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal scrollable list of freelancer cards
class FreelancerHorizontalList extends ConsumerWidget {
  final List<NearbyFreelancerDTO> freelancers;
  final String title;
  final VoidCallback? onSeeAllTap;

  const FreelancerHorizontalList({
    super.key,
    required this.freelancers,
    required this.title,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (freelancers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        Gap(Spacing.sm.h),
        SizedBox(
          height: 160.h, // Increased height to accommodate all content
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            itemCount: freelancers.length,
            separatorBuilder: (_, __) => Gap(Spacing.sm.w),
            itemBuilder: (context, index) {
              final freelancer = freelancers[index];
              return SizedBox(
                width: 300.w, // Slightly wider to accommodate content
                child: FreelancerCard(
                  freelancer: freelancer,
                  onTap: () {
                    context.push('/freelancer/${freelancer.id}');
                  },
                ),
              );
            },
          ),
        ),
        Gap(Spacing.md.h),
      ],
    );
  }
}
