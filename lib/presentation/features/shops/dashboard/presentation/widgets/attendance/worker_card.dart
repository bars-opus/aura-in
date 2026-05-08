// lib/features/dashboard/presentation/widgets/worker_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/app_colors.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/today_attendance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_profile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/attendance/attendance_summary_card.dart';

class WorkerCard extends StatelessWidget {
  final WorkerProfile worker;
  final VoidCallback onTap;
  final VoidCallback? onEditTap;
  // final VoidCallback? onScheduleTap;
  final TodayAttendanceStatus? todayStatus;

  const WorkerCard({
    super.key,
    required this.worker,
    required this.onTap,
    this.onEditTap,
    // this.onScheduleTap,
    this.todayStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRowWidget(
            imageUrl: worker.profileImageUrl,
            subtitle:
                '${worker.totalBookings} bookings \$${worker.totalRevenue.toStringAsFixed(0)}',
            title: worker.name,
            icon: Icons.account_circle_rounded,
            avatarRadius: 35.r,
            iconSize: 35.r,
            onTap: () {},
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
                  worker.averageRating == null
                      ? '0'
                      : worker.averageRating!.toStringAsFixed(1),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(Spacing.xs.h),

              AppDivider(),
              // In the build method, after the specialties Wrap, add:
              if (worker.isShopEmployee) ...[
                Gap(Spacing.xs.h),
                AttendanceSummaryCard(
                  daysWorked: worker.daysWorkedThisMonth,
                  totalHours: worker.totalHoursThisMonth,
                  onTimeRate: worker.onTimeRate,
                  lateArrivals: worker.lateArrivalsThisMonth,
                  onTap: () {
                    // Navigate to detailed attendance view
                  },
                ),
              ],
            ],
          ),
          AppDivider(),
          if (worker.specialties.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.start, // Aligns to left (start)
              spacing: Spacing.xs.w,
              children:
                  worker.specialties.take(2).map((specialty) {
                    return Text(
                      specialty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: FontSizeTokens.sm.sp,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.start,
                    );
                  }).toList(),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // if (todayStatus != null)
                  MiniContainerIndicator(
                    color: Colors.green,
                    // _getStatusColor(
                    //               todayStatus!,
                    //               colorScheme,
                    //             )
                    text: 'clockedIn',
                    // todayStatus!.displayName,
                    fontSize: FontSizeTokens.xxs,
                  ),
                  // if (!worker.isActive)
                  MiniContainerIndicator(
                    color: colorScheme.neutral,
                    text: 'Inactive',
                    fontSize: FontSizeTokens.xxs,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
