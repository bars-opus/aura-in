import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';



class BookingStatusHeader extends StatelessWidget {
  final BookingModel booking;

  const BookingStatusHeader({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final statusConfig = _getStatusConfig(booking.status, colorScheme);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: statusConfig.borderColor,
          width: BorderWidthTokens.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusConfig.icon,
            size: IconSizes.sm.h,
            color: statusConfig.textColor,
          ),
          Gap(Spacing.xs.w),
          Text(
            _getStatusText(booking.status),
            style: theme.textTheme.labelLarge?.copyWith(
              color: statusConfig.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(BookingStatus status, ColorScheme colors) {
    switch (status) {
      case BookingStatus.confirmed:
        return _StatusConfig(
          backgroundColor: Colors.green.withOpacity(0.1),
          textColor: Colors.green.shade700,
          borderColor: Colors.green.withOpacity(0.3),
          icon: Icons.check_circle_outline,
        );
      case BookingStatus.pending:
        return _StatusConfig(
          backgroundColor: Colors.orange.withOpacity(0.1),
          textColor: Colors.orange.shade700,
          borderColor: Colors.orange.withOpacity(0.3),
          icon: Icons.pending_outlined,
        );
      case BookingStatus.completed:
        return _StatusConfig(
          backgroundColor: Colors.blue.withOpacity(0.1),
          textColor: Colors.blue.shade700,
          borderColor: Colors.blue.withOpacity(0.3),
          icon: Icons.done_all_outlined,
        );
      case BookingStatus.cancelled:
        return _StatusConfig(
          backgroundColor: Colors.red.withOpacity(0.1),
          textColor: Colors.red.shade700,
          borderColor: Colors.red.withOpacity(0.3),
          icon: Icons.cancel_outlined,
        );
      case BookingStatus.noShow:
        return _StatusConfig(
          backgroundColor: Colors.grey.withOpacity(0.1),
          textColor: Colors.grey.shade700,
          borderColor: Colors.grey.withOpacity(0.3),
          icon: Icons.person_off_outlined,
        );
      default:
        return _StatusConfig(
          backgroundColor: colors.surfaceVariant,
          textColor: colors.onSurfaceVariant,
          borderColor: colors.outline,
          icon: Icons.help_outline,
        );
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending Confirmation';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.noShow:
        return 'No Show';
      default:
        return status.toString().split('.').last;
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
  });
}
