import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_logger.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/exceptions/booking_error_messages.dart';

class SpecialRequirementsBottomSheet extends ConsumerStatefulWidget {
  final String bookingServiceId;
  final String serviceName;
  final String? initialRequirements;
  final VoidCallback onRequirementsSaved;

  const SpecialRequirementsBottomSheet({
    super.key,
    required this.bookingServiceId,
    required this.serviceName,
    this.initialRequirements,
    required this.onRequirementsSaved,
  });

  @override
  ConsumerState<SpecialRequirementsBottomSheet> createState() =>
      _SpecialRequirementsBottomSheetState();
}

class _SpecialRequirementsBottomSheetState
    extends ConsumerState<SpecialRequirementsBottomSheet> {
  late TextEditingController _controller;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialRequirements);
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

    return ListView(
      children: [
        // Header
        BottomSheetHeader(title: 'Special Requirements'),
        AppDivider(),

        Gap(Spacing.lg.h),

        AppTextFormField(
          controller: _controller,
          isSmall: true,
          label: 'Requirement',
          hintText:
              'e.g., Allergic to strong fragrances, prefer female stylist, etc.',
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          errorText: _error,
        ),
        Gap(Spacing.md.h),
        SemanticContainerWidget(
          content:
              'Add any special requests or notes for this service. \nThe shop will see this before your appointment.',
          icon: Icons.hotel_outlined,
          title: '',
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          borderColor: colorScheme.primary,
          iconColor: colorScheme.primary,
          textTheme: theme.textTheme,
        ),

        Gap(Spacing.xl.h),
        _isSaving
            ? CircularLoadingIndicator()
            : AppButton(
              elevation: 0,
              label: 'Submit requirement',
              onPressed: _isSaving ? null : _saveRequirements,
              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 40.h,
            ),
      ],
    );
  }

  Future<void> _saveRequirements() async {
    final requirements = _controller.text.trim();

    // Clear any previous error
    setState(() {
      _error = null;
    });

    // Optional: Add validation (e.g., max length)
    if (requirements.length > 500) {
      setState(() {
        _error = 'Requirements cannot exceed 500 characters';
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
        requirements: requirements,
      );

      if (mounted) {
        // Close the bottom sheet
        Navigator.pop(context);

        // Call the onRequirementsSaved callback to refresh the parent
        widget.onRequirementsSaved();

        // Show success message
        context.showSuccessSnackbar(
          requirements.isEmpty
              ? 'Special requirements removed'
              : 'Special requirements saved',
        );
      }
    } catch (e, st) {
      BookingLogger.error(
        'special_requirements_save_failed',
        error: e,
        stack: st,
      );
      if (mounted) {
        setState(() {
          _error = BookingErrorMessages.forUser(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
