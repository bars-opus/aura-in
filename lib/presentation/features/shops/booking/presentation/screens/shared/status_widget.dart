import 'package:flutter/material.dart';
import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/status_config.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/mini_container_indicator.dart';

class StatusWidget extends StatelessWidget {
  final String status;
  final bool showIcon;
  final bool showLabel;
  final EdgeInsetsGeometry? padding;

  const StatusWidget({
    super.key,
    required this.status,
    this.showIcon = true,
    this.showLabel = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final config = _getStatusConfig(status, colorScheme);

    return showLabel
        ? MiniContainerIndicator(
          fontSize: 10,
          color: config.backgroundColor,
          text: config.displayName,
        )
        : status == 'completed'
        ? AnimatedScaleFade(
          curve: Curves.easeOutBack,
          child: AppIconButton(
            icon: Icons.check_circle,
            iconColor: Colors.green,
          ),
        )
        : Text(
          status[0].toUpperCase(),
          style: textTheme.titleSmall?.copyWith(
            color: config.backgroundColor,
            fontWeight: FontWeight.w700,
            // fontSize: 20.sp,
          ),
        );
  }

  StatusConfig _getStatusConfig(String status, ColorScheme colorSchem) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return StatusConfig(
          displayName: 'Confirmed',
          backgroundColor: colorSchem.warning,
        );
      case 'pending':
        return StatusConfig(
          displayName: 'Pending',
          backgroundColor: colorSchem.primary,
        );
      case 'completed':
        return StatusConfig(
          displayName: 'Completed',
          backgroundColor: colorSchem.success,
        );
      case 'cancelled':
        return StatusConfig(
          displayName: 'Cancelled',
          backgroundColor: colorSchem.error,
        );
      case 'no_show':
        return StatusConfig(
          displayName: 'No Show',
          backgroundColor: Colors.grey,
        );
      default:
        return StatusConfig(displayName: status, backgroundColor: Colors.grey);
    }
  }
}
