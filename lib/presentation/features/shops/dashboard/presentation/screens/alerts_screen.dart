// lib/features/dashboard/presentation/screens/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/app_colors.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/performance_alert.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/alerts_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/tools/alert_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  final String shopId;

  const AlertsScreen({super.key, required this.shopId});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(
            alertsControllerProviderFamily(
              AlertsParams(shopId: widget.shopId),
            ).notifier,
          )
          .loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      alertsControllerProviderFamily(AlertsParams(shopId: widget.shopId)),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Alerts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Filter button
          IconButton(
            onPressed: _showFilterOptions,
            icon: Icon(
              Icons.filter_list_outlined,
              color: colorScheme.onSurface,
            ),
          ),
          // Refresh button
          IconButton(
            onPressed:
                () =>
                    ref
                        .read(
                          alertsControllerProviderFamily(
                            AlertsParams(shopId: widget.shopId),
                          ).notifier,
                        )
                        .refresh(),
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
          ),
          // Generate alerts button
          IconButton(
            onPressed: _showGenerateOptions,
            icon: Icon(Icons.auto_awesome, color: colorScheme.primary),
          ),
        ],
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(AlertsState state) {
    final theme = Theme.of(context);

    if (state.isLoading && state.alerts.isEmpty) {
      return Center(
        child: CircularLoadingIndicator(
         
        ),
      );
    }

    if (state.error != null && state.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.w,
              color: theme.colorScheme.error,
            ),
            Gap(Spacing.md.h),
            Text('Failed to load alerts', style: theme.textTheme.titleMedium),
            Gap(Spacing.xs.h),
            Text(
              state.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            Gap(Spacing.lg.h),
            ElevatedButton(
              onPressed:
                  () =>
                      ref
                          .read(
                            alertsControllerProviderFamily(
                              AlertsParams(shopId: widget.shopId),
                            ).notifier,
                          )
                          .refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.alerts.isEmpty) {
      final colorScheme = theme.colorScheme;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64.w,
              color: colorScheme.success,
            ),
            Gap(Spacing.md.h),
            Text(
              'No alerts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.xs.h),
            Text(
              'All metrics look good!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Gap(Spacing.lg.h),
            OutlinedButton(
              onPressed: () {
                ref
                    .read(
                      alertsControllerProviderFamily(
                        AlertsParams(shopId: widget.shopId),
                      ).notifier,
                    )
                    .generateAlerts();
              },
              child: const Text('Generate Alerts'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          () =>
              ref
                  .read(
                    alertsControllerProviderFamily(
                      AlertsParams(shopId: widget.shopId),
                    ).notifier,
                  )
                  .refresh(),
      child: ListView.builder(
        padding: EdgeInsets.all(Spacing.md.h),
        itemCount: state.alerts.length,
        itemBuilder: (context, index) {
          final alert = state.alerts[index];
          return AlertCard(
            alert: alert,
            onTap: () => _showAlertDetail(alert),
            onDismiss: () {
              ref
                  .read(
                    alertsControllerProviderFamily(
                      AlertsParams(shopId: widget.shopId),
                    ).notifier,
                  )
                  .resolveAlert(alert.id);
            },
          );
        },
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder:
          (context) => _FilterSheet(
            onFilterChanged: (severity) {
              // Apply filter - you may need to add filter method to controller
              // For now, just refresh
              ref
                  .read(
                    alertsControllerProviderFamily(
                      AlertsParams(shopId: widget.shopId),
                    ).notifier,
                  )
                  .refresh();
            },
          ),
    );
  }

  void _showGenerateOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder:
          (context) => _GenerateSheet(
            onGenerate: () {
              ref
                  .read(
                    alertsControllerProviderFamily(
                      AlertsParams(shopId: widget.shopId),
                    ).notifier,
                  )
                  .generateAlerts();
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showAlertDetail(PerformanceAlert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder:
          (context) => _AlertDetailSheet(
            alert: alert,
            onMarkRead: () {
              ref
                  .read(
                    alertsControllerProviderFamily(
                      AlertsParams(shopId: widget.shopId),
                    ).notifier,
                  )
                  .markAlertRead(alert.id);
              Navigator.pop(context);
            },
            onResolve: () {
              ref
                  .read(
                    alertsControllerProviderFamily(
                      AlertsParams(shopId: widget.shopId),
                    ).notifier,
                  )
                  .resolveAlert(alert.id);
              Navigator.pop(context);
            },
          ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  final Function(AlertSeverity?) onFilterChanged;

  const _FilterSheet({required this.onFilterChanged});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  AlertSeverity? _selectedSeverity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(Spacing.lg.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Alerts',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.md.h),
          Text(
            'Severity',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.sm.h),
          Wrap(
            spacing: Spacing.sm.w,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedSeverity == null,
                onSelected: (selected) {
                  setState(() => _selectedSeverity = null);
                  widget.onFilterChanged(null);
                },
              ),
              ...AlertSeverity.values.map((severity) {
                return FilterChip(
                  label: Text(severity.displayName),
                  selected: _selectedSeverity == severity,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSeverity = selected ? severity : null;
                    });
                    widget.onFilterChanged(selected ? severity : null);
                  },
                  selectedColor: colorScheme.error.withOpacity(0.2),
                  checkmarkColor: colorScheme.error,
                );
              }),
            ],
          ),
          Gap(Spacing.lg.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateSheet extends StatelessWidget {
  final VoidCallback onGenerate;

  const _GenerateSheet({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(Spacing.lg.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48.w,
            color: theme.colorScheme.primary,
          ),
          Gap(Spacing.md.h),
          Text(
            'Generate New Alerts',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.sm.h),
          Text(
            'This will analyze your recent performance metrics and create alerts for any areas that need attention.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          Gap(Spacing.lg.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              Gap(Spacing.md.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onGenerate,
                  child: const Text('Generate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertDetailSheet extends StatelessWidget {
  final PerformanceAlert alert;
  final VoidCallback onMarkRead;
  final VoidCallback onResolve;

  const _AlertDetailSheet({
    required this.alert,
    required this.onMarkRead,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final severityColor = colorScheme.error;

    return Container(
      padding: EdgeInsets.all(Spacing.lg.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Spacing.sm.h),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(alert.severity),
                  size: IconSizes.lg,
                  color: severityColor,
                ),
              ),
              Gap(Spacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      alert.category.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: IconSizes.sm),
              ),
            ],
          ),
          Gap(Spacing.lg.h),

          // Message
          Text(alert.message, style: theme.textTheme.bodyLarge),
          Gap(Spacing.md.h),

          // Metrics
          if (alert.currentValue != null)
            Container(
              padding: EdgeInsets.all(Spacing.md.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _formatValue(alert.currentValue!),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: severityColor,
                          ),
                        ),
                        Text('Current', style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                  if (alert.threshold != null)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _formatValue(alert.threshold!),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text('Threshold', style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          Gap(Spacing.md.h),

          // Suggested action
          if (alert.suggestedAction != null)
            Container(
              padding: EdgeInsets.all(Spacing.md.h),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested Action',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(Spacing.xs.h),
                  Text(
                    alert.suggestedAction!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          Gap(Spacing.lg.h),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onMarkRead,
                  child: const Text('Mark as Read'),
                ),
              ),
              Gap(Spacing.md.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onResolve,
                  child: const Text('Resolve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return Icons.info_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case AlertSeverity.critical:
        return Icons.error_outline;
    }
  }

  String _formatValue(double value) {
    if (value < 1) return '${(value * 100).toStringAsFixed(0)}%';
    return '\$${value.toStringAsFixed(0)}';
  }
}
