// lib/features/shop/workers/widgets/add_unavailability_modal.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nano_embryo/core/utils/cupertino_date_picker_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/app_text_form_field.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/worker_unavailability_model.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/worker_availability_provider.dart';

class AddUnavailabilityModal extends ConsumerStatefulWidget {
  final String workerId;
  final WorkerUnavailabilityModel? initialUnavailability;
  final VoidCallback onSaved;

  const AddUnavailabilityModal({
    super.key,
    required this.workerId,
    this.initialUnavailability,
    required this.onSaved,
  });

  @override
  ConsumerState<AddUnavailabilityModal> createState() => _AddUnavailabilityModalState();
}

class _AddUnavailabilityModalState extends ConsumerState<AddUnavailabilityModal> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  late TextEditingController _reasonController;
  bool _isAllDay = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialUnavailability != null) {
      _startDateTime = widget.initialUnavailability!.startTime;
      _endDateTime = widget.initialUnavailability!.endTime;
      _reasonController = TextEditingController(text: widget.initialUnavailability!.reason);
    } else {
      _startDateTime = DateTime.now();
      _endDateTime = DateTime.now().add(const Duration(hours: 1));
      _reasonController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialUnavailability != null;

    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Unavailable Period' : 'Add Unavailable Period',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),

          // All-day toggle
          Row(
            children: [
              Checkbox(
                value: _isAllDay,
                onChanged: (value) {
                  setState(() {
                    _isAllDay = value ?? false;
                    if (_isAllDay) {
                      _startDateTime = DateTime(_startDateTime.year, _startDateTime.month, _startDateTime.day);
                      _endDateTime = DateTime(_endDateTime.year, _endDateTime.month, _endDateTime.day, 23, 59);
                    }
                  });
                },
              ),
              Text('All day', style: theme.textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: Spacing.md.h),

          // Start date/time
          Text(
            'Start Date & Time',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: Spacing.xs.h),
          _buildDateTimePicker(
            value: _startDateTime,
            onChanged: (dateTime) {
              setState(() {
                _startDateTime = dateTime;
                if (_endDateTime.isBefore(_startDateTime)) {
                  _endDateTime = _startDateTime.add(const Duration(hours: 1));
                }
              });
            },
          ),
          SizedBox(height: Spacing.md.h),

          // End date/time
          Text(
            'End Date & Time',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: Spacing.xs.h),
          _buildDateTimePicker(
            value: _endDateTime,
            onChanged: (dateTime) {
              setState(() {
                _endDateTime = dateTime;
              });
            },
          ),
          SizedBox(height: Spacing.md.h),

          // Reason (optional)
          AppTextFormField(
            controller: _reasonController,
            label: 'Reason (optional)',
            hintText: 'e.g., Vacation, Training, Sick leave',
            prefixIcon: Icons.note,
          ),
          SizedBox(height: Spacing.lg.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Expanded(
                child: AppButton(
                  label: _isLoading
                      ? 'Saving...'
                      : (isEditing ? 'Update' : 'Add'),
                  onPressed: _isLoading ? null : _save,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.sm.h),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        if (_isAllDay) {
          final picked = await showCupertinoDatePickerSheet(
            context: context,
            initialDate: value,
            minimumDate: DateTime.now(),
            maximumDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) onChanged(picked);
        } else {
          final datePicked = await showCupertinoDatePickerSheet(
            context: context,
            initialDate: value,
            minimumDate: DateTime.now(),
            maximumDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (datePicked == null || !mounted) return;
          final timePicked = await showCupertinoDatePickerSheet(
            context: context,
            initialDate: value,
            mode: CupertinoDatePickerMode.time,
            sheetHeight: 260,
          );
          final time = timePicked ?? value;
          onChanged(DateTime(
            datePicked.year, datePicked.month, datePicked.day,
            time.hour, time.minute,
          ));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.w, vertical: Spacing.sm.h),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20.sp),
            SizedBox(width: Spacing.sm.w),
            Expanded(
              child: Text(
                _formatDateTime(value),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 20.sp),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    if (_isAllDay) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    if (_endDateTime.isBefore(_startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(workerAvailabilityProvider(widget.workerId).notifier);
      
      if (widget.initialUnavailability != null) {
        await notifier.updateUnavailability(
          unavailabilityId: widget.initialUnavailability!.id,
          startTime: _startDateTime,
          endTime: _endDateTime,
          reason: _reasonController.text.trim(),
        );
      } else {
        await notifier.addUnavailability(
          startTime: _startDateTime,
          endTime: _endDateTime,
          reason: _reasonController.text.trim(),
        );
      }

      widget.onSaved();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialUnavailability != null
                ? 'Unavailable period updated'
                : 'Unavailable period added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
