// lib/features/dashboard/presentation/widgets/alert_card.dart

import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/performance_alert.dart';

class AlertCard extends StatelessWidget {
  final PerformanceAlert alert;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get severity-specific colors
    final severityColor = _getSeverityColor(alert.severity, colorScheme);
    final backgroundColor = alert.isRead ? theme.cardColor : severityColor;

    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.md.h),
      child: SemanticContainerWidget(
        content: alert.message,
        icon: _getIcon(alert.severity),
        title: alert.title,
        backgroundColor: backgroundColor.withOpacity(0.1),
        borderColor: backgroundColor,
        iconColor: backgroundColor,
        textTheme: theme.textTheme,
        child:
            alert.suggestedAction == null
                ? null
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (alert.currentValue != null) Gap(Spacing.xs.h),
                    if (alert.currentValue != null)
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: IconSizes.xs,
                            color: severityColor,
                          ),
                          Gap(Spacing.xs.w),
                          Text(
                            'Current: ${_formatValue(alert.currentValue!)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: severityColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (alert.threshold != null) ...[
                            Gap(Spacing.sm.w),
                            Text(
                              'Threshold: ${_formatValue(alert.threshold!)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    Text(
                      alert.suggestedAction!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  /// Get the color based on alert severity
  Color _getSeverityColor(AlertSeverity severity, ColorScheme colorScheme) {
    switch (severity) {
      case AlertSeverity.info:
        return colorScheme.info;
      case AlertSeverity.warning:
        return colorScheme.warning;
      case AlertSeverity.critical:
        return colorScheme.error;
    }
  }

  /// Get icon based on alert severity
  IconData _getIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return Icons.info_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case AlertSeverity.critical:
        return Icons.running_with_errors_rounded;
    }
  }

  /// Format value for display (percentage or currency)
  String _formatValue(double value) {
    if (value < 1) return '${(value * 100).toStringAsFixed(0)}%';
    return '\$${value.toStringAsFixed(0)}';
  }
}
