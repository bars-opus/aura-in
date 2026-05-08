// lib/features/dashboard/presentation/screens/export_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/export_report.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class ExportReportsScreen extends ConsumerStatefulWidget {
  final String shopId;

  const ExportReportsScreen({super.key, required this.shopId});

  @override
  ConsumerState<ExportReportsScreen> createState() =>
      _ExportReportsScreenState();
}

class _ExportReportsScreenState extends ConsumerState<ExportReportsScreen> {
  ReportType? _selectedReportType;
  DateTimeRange? _dateRange;
  ExportFormat _format = ExportFormat.csv;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exportState = ref.watch(exportControllerProvider);

    // Update local exporting state based on controller state
    if (exportState.isExporting != _isExporting) {
      _isExporting = exportState.isExporting;
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Export Reports',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.md.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Type Selection
            Text(
              'Select Report Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: Spacing.sm.h,
              crossAxisSpacing: Spacing.sm.h,
              childAspectRatio: 1.5,
              children:
                  ReportType.values.map((type) {
                    final isSelected = _selectedReportType == type;
                    return _ReportTypeCard(
                      reportType: type,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedReportType = type;
                        });
                      },
                    );
                  }).toList(),
            ),
            Gap(Spacing.lg.h),

            // Date Range (for bookings and revenue)
            if (_selectedReportType == ReportType.bookings ||
                _selectedReportType == ReportType.revenue)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Range (Optional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(Spacing.sm.h),
                  InkWell(
                    onTap: _selectDateRange,
                    child: Container(
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
                          Icon(
                            Icons.calendar_today,
                            color: colorScheme.primary,
                          ),
                          Gap(Spacing.sm.w),
                          Text(
                            _dateRange == null
                                ? 'All Time'
                                : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(Spacing.lg.h),
                ],
              ),

            // Format Selection
            Text(
              'Export Format',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            Row(
              children:
                  ExportFormat.values.map((format) {
                    final isSelected = _format == format;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: Spacing.sm.w),
                        child: _FormatChip(
                          format: format,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _format = format;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
            ),
            Gap(Spacing.lg.h),

            // Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReportType == null ? null : _export,
                child:
                    _isExporting
                        ? const CircularLoadingIndicator(
         
        )
                        : const Text('Export Report'),
              ),
            ),

            // Error Message
            if (exportState.error != null)
              Padding(
                padding: EdgeInsets.only(top: Spacing.md.h),
                child: Container(
                  padding: EdgeInsets.all(Spacing.sm.h),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: IconSizes.sm,
                        color: colorScheme.error,
                      ),
                      Gap(Spacing.sm.w),
                      Expanded(
                        child: Text(
                          exportState.error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  Future<void> _export() async {
    if (_selectedReportType == null) return;

    final config = ExportConfig(
      reportType: _selectedReportType!,
      format: _format,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );

    final controller = ref.read(exportControllerProvider.notifier);
    await controller.exportReport(config);

    if (mounted && ref.read(exportControllerProvider).lastExport != null) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final state = ref.read(exportControllerProvider);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Complete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${state.lastExport?.recordCount} records exported'),
                Gap(Spacing.sm.h),
                Text(
                  'File saved to: ${state.filePath?.split('/').last}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(exportControllerProvider.notifier).shareFile();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Share'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _ReportTypeCard extends StatelessWidget {
  final ReportType reportType;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportTypeCard({
    required this.reportType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Spacing.sm.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary.withOpacity(0.1)
                  : theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              reportType.icon,
              size: IconSizes.lg,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            Gap(Spacing.xs.h),
            Text(
              reportType.displayName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  final ExportFormat format;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatChip({
    required this.format,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Spacing.sm.h,
          horizontal: Spacing.md.w,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isSelected
                    ? Colors.transparent
                    : colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            format.displayName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
