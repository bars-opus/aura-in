import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';

class ServiceListItem extends StatelessWidget {
  final int rank;
  final String name;
  final String? profileImageUrl;
  final int bookingCount;
  final double percentage;
  final double averageRating;
  final double revenue;
  final VoidCallback? onTap;
  final bool isWorker;
  final bool showDivider;

  const ServiceListItem({
    required this.rank,
    required this.name,
    required this.bookingCount,
    this.percentage = 0.0,
    required this.revenue,
    this.onTap,
    this.showDivider = false,
    required this.averageRating,
    required this.isWorker,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: rank > 10 ? colorScheme.success : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight:
                            rank > 10 ? FontWeight.w600 : FontWeight.normal,
                        color:
                            rank > 10
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),

                if (isWorker)
                  ProfileAvatar(
                    avatarUrl: profileImageUrl ?? '',
                    currentUserId: '',
                    size: 45.h,
                  ),

                Gap(Spacing.sm.w),

                // Name and progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(Spacing.xs.h),

                      // Progress bar
                      isWorker
                          ? Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: IconSizes.sm,
                                color: colorScheme.warning,
                              ),
                              Gap(Spacing.xs.w),
                              Text(
                                averageRating!.toStringAsFixed(1),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 8.h,
                              backgroundColor: colorScheme.primary.withOpacity(
                                0.1,
                              ),
                              color: colorScheme.primary,
                            ),
                          ),
                    ],
                  ),
                ),
                Gap(Spacing.sm.w),

                // Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$bookingCount',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    isWorker
                        ? Text(
                          '\$${revenue.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        )
                        : Text(
                          '${percentage!.toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDivider) AppDivider(),
      ],
    );
  }
}
