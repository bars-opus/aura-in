// lib/features/shop/workers/widgets/unavailability_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_icon_button.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/worker_unavailability_model.dart';

class UnavailabilityTile extends StatelessWidget {
  final WorkerUnavailabilityModel unavailability;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UnavailabilityTile({
    super.key,
    required this.unavailability,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAllDay = unavailability.startTime.hour == 0 && 
                     unavailability.startTime.minute == 0 &&
                     unavailability.endTime.hour == 23 &&
                     unavailability.endTime.minute == 59;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: Spacing.md.w, vertical: Spacing.xs.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: Icon(Icons.block, color: Colors.orange, size: 20.sp),
        ),
        title: Text(
          unavailability.reason ?? 'Unavailable',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          isAllDay
              ? '${_formatDate(unavailability.startTime)} (All day)'
              : '${_formatDateTime(unavailability.startTime)} - ${_formatTime(unavailability.endTime)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconButton(
              icon: Icons.edit,
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            AppIconButton(
              icon: Icons.delete_outline,
              onPressed: onDelete,
              tooltip: 'Delete',
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} at ${_formatTime(dateTime)}';
  }
}
