import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';

class SpecialRequirementsWidget extends ConsumerStatefulWidget {
  final String bookingServiceId;
  final String serviceName;
  final String? initialRequirements;
  final bool isEditable;
  final Function(String)? onSaved;

  const SpecialRequirementsWidget({
    super.key,
    required this.bookingServiceId,
    required this.serviceName,
    this.initialRequirements,
    this.isEditable = true,
    this.onSaved,
  });

  @override
  ConsumerState<SpecialRequirementsWidget> createState() =>
      _SpecialRequirementsWidgetState();
}

class _SpecialRequirementsWidgetState
    extends ConsumerState<SpecialRequirementsWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _currentRequirements;

  @override
  void initState() {
    super.initState();
    _currentRequirements = widget.initialRequirements;
    _controller = TextEditingController(text: _currentRequirements);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(Spacing.sm.h),
            child: Row(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 20.h,
                  color: colorScheme.primary,
                ),
                SizedBox(width: Spacing.xs.w),
                Text(
                  'Special Requirements',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.isEditable && !_isEditing)
                  TextButton.icon(
                    onPressed: _startEditing,
                    icon: Icon(Icons.edit, size: IconSizes.sm.h),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: Spacing.xs.w),
                    ),
                  ),
                if (_isEditing)
                  Row(
                    children: [
                      TextButton(
                        onPressed: _cancelEditing,
                        child: const Text('Cancel'),
                      ),
                      SizedBox(width: Spacing.xs.w),
                      ElevatedButton(
                        onPressed: _saveRequirements,
                        child:
                            _isSaving
                                ? CircularLoadingIndicator()
                                : const Text('Save'),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Content
          if (!_isEditing &&
              _currentRequirements != null &&
              _currentRequirements!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.sm.w,
                0,
                Spacing.sm.w,
                Spacing.sm.h,
              ),
              child: Container(
                padding: EdgeInsets.all(Spacing.sm.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _currentRequirements!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),

          if (!_isEditing &&
              (_currentRequirements == null || _currentRequirements!.isEmpty))
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.sm.w,
                0,
                Spacing.sm.w,
                Spacing.sm.h,
              ),
              child: Text(
                'No special requirements for this service',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          if (_isEditing)
            Padding(
              padding: EdgeInsets.all(Spacing.sm.w),
              child: TextField(
                controller: _controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g., Allergic to certain products, prefer female stylist, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _controller.text = _currentRequirements ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _controller.text = _currentRequirements ?? '';
    });
  }

  Future<void> _saveRequirements() async {
    final newRequirements = _controller.text.trim();

    // If nothing changed, just cancel editing
    if (newRequirements == _currentRequirements) {
      setState(() {
        _isEditing = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(bookingRepositoryProvider);
      await repository.updateSpecialRequirements(
        bookingServiceId: widget.bookingServiceId,
        requirements: newRequirements,
      );

      setState(() {
        _currentRequirements = newRequirements.isEmpty ? null : newRequirements;
        _isEditing = false;
        _isSaving = false;
      });

      widget.onSaved?.call(_currentRequirements ?? '');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newRequirements.isEmpty
                  ? 'Special requirements removed'
                  : 'Special requirements saved',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
