// lib/features/dashboard/presentation/widgets/export_options_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/export_report.dart';

class ExportOptionsSheet extends StatefulWidget {
  final Function(ExportConfig) onExport;

  const ExportOptionsSheet({
    super.key,
    required this.onExport,
  });

  @override
  State<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<ExportOptionsSheet> {
  ReportType _reportType = ReportType.bookings;
  ExportFormat _format = ExportFormat.csv;
  DateTimeRange? _dateRange;
  bool _includeDetails = true;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Export Report',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  size: IconSizes.md,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Gap(Spacing.md.h),

          // Report type
          Text(
            'Report Type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.xs.h),
          Wrap(
            spacing: Spacing.sm.w,
            children: ReportType.values.map((type) {
              final isSelected = _reportType == type;
              return ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _reportType = type);
                  }
                },
              );
            }).toList(),
          ),
          Gap(Spacing.md.h),

          // Date range
          Text(
            'Date Range (Optional)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.xs.h),
          OutlinedButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
              }
            },
            child: Text(_dateRange == null
                ? 'All Time'
                : '${_dateRange!.start.month}/${_dateRange!.start.day} - '
                    '${_dateRange!.end.month}/${_dateRange!.end.day}'),
          ),
          Gap(Spacing.md.h),

          // Format
          Text(
            'Format',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.xs.h),
          Row(
            children: ExportFormat.values.map((format) {
              final isSelected = _format == format;
              return Expanded(
                child: RadioListTile<ExportFormat>(
                  title: Text(format.displayName),
                  value: format,
                  groupValue: _format,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _format = value);
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
          Gap(Spacing.md.h),

          // Include details
          CheckboxListTile(
            title: Text('Include Details'),
            subtitle: Text('Include full details in report'),
            value: _includeDetails,
            onChanged: (value) {
              setState(() => _includeDetails = value ?? true);
            },
            contentPadding: EdgeInsets.zero,
          ),
          Gap(Spacing.lg.h),

          // Export button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final config = ExportConfig(
                  reportType: _reportType,
                  format: _format,
                  startDate: _dateRange?.start,
                  endDate: _dateRange?.end,
                  includeDetails: _includeDetails,
                );
                widget.onExport(config);
                Navigator.pop(context);
              },
              child: const Text('Export'),
            ),
          ),
        ],
      ),
    );
  }
}
