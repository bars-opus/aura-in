// lib/features/dashboard/presentation/widgets/schedule_list_item.dart
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/today_schedule_item.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

/// Individual schedule item for today's list
class ScheduleListItem extends StatelessWidget {
  final TodayScheduleItem item;
  final VoidCallback onTap;
  final VoidCallback? onContactTap;

  const ScheduleListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Spacing.sm.h),
        padding: EdgeInsets.all(Spacing.md.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
            width: BorderWidthTokens.hairline,
          ),
        ),
        child: Row(
          children: [
            // Time column
            Container(
              width: 60.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.formattedStartTime,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizeTokens.md.sp,
                    ),
                  ),
                  Text(
                    _formatDuration(item.startTime, item.endTime),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator dot
            Container(
              width: 8.w,
              height: 8.h,
              margin: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
              decoration: BoxDecoration(
                color: Theme.of(context).appColors.getStatusColor(item.status),
                shape: BoxShape.circle,
              ),
            ),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client and service
                  Text(
                    item.clientName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.serviceName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Worker
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: IconSizes.xs,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      Gap(Spacing.xs.w),
                      Text(
                        item.workerName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            if (onContactTap != null && item.clientPhone != null)
              IconButton(
                onPressed: onContactTap,
                icon: Icon(
                  Icons.phone_outlined,
                  size: IconSizes.sm,
                  color: colorScheme.primary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }
}
