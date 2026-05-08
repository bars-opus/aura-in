import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/models/time_group.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';

class AppointmentGroupSection extends StatelessWidget {
  final GroupedAppointments group;
  final Function(ShopCalendarBooking) onAppointmentTap;
  final bool isLoading;

  const AppointmentGroupSection({
    super.key,
    required this.group,
    required this.onAppointmentTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Column(
        children: [
          _buildHeader(context),
          const ShopSchimmerSkeleton(height: 100),
          const ShopSchimmerSkeleton(height: 100),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),

        // Appointments
        if (group.hasAppointments)
          ...group.appointments.map(
            (booking) => _buildAppointmentCard(context, booking),
          ),

        // Empty state
        if (!group.hasAppointments)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
            child: Text(
              'No appointments in the ${group.group.displayName.toLowerCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        SizedBox(height: Spacing.md.h),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      child: Row(
        children: [
          Icon(
            _getIconForGroup(group.group),
            size: 20.h,
            color: colorScheme.primary,
          ),
          SizedBox(width: Spacing.xs.w),
          Text(
            group.group.displayName.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.xs.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '${group.count}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    ShopCalendarBooking booking,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => onAppointmentTap(booking),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.xs.h,
        ),
        padding: EdgeInsets.all(Spacing.sm.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Time
            Container(
              width: 60.w,
              child: Text(
                _formatTime(booking.startTime),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            // Client Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.clientName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    booking.serviceName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Status Indicator
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(booking.status, colorScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return colorScheme.info;
      case 'pending':
        return colorScheme.primary;
      case 'completed':
        return colorScheme.success;
      case 'cancelled':
        return colorScheme.error;
      case 'no_show':
        return Colors.grey;
      default:
        return const Color.fromARGB(255, 18, 4, 4);
    }
  }

  IconData _getIconForGroup(TimeGroup group) {
    switch (group) {
      case TimeGroup.morning:
        return Icons.wb_sunny;
      case TimeGroup.afternoon:
        return Icons.sunny;
      case TimeGroup.evening:
        return Icons.nights_stay;
    }
  }
}
