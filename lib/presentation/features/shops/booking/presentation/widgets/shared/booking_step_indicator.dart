// lib/features/booking/presentation/widgets/shared/booking_step_indicator.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// A beautiful step indicator for the booking flow.
///
/// Displays the current step in a 4-step booking process with
/// visual indicators for completed, current, and upcoming steps.
///
/// ## Features
/// - Visual feedback for step status
/// - Animated transitions between steps
/// - Uses design tokens for consistent spacing and colors
///
/// ## Usage
/// ```dart
/// BookingStepIndicator(
///   currentStep: currentStep,
///   stepLabels: const ['Services', 'Workers', 'Time', 'Confirm'],
/// )
/// ```
class BookingStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepLabels;
  final VoidCallback? onStepTapped;

  const BookingStepIndicator({
    Key? key,
    required this.currentStep,
    required this.stepLabels,
    this.onStepTapped,
  })  : assert(stepLabels.length == 4, 'Must have exactly 4 steps'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: Spacing.md.h,
      ),
      child: Row(
        children: List.generate(stepLabels.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final isUpcoming = index > currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: onStepTapped != null ? () => onStepTapped!() : null,
              child: _StepItem(
                index: index,
                label: stepLabels[index],
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isUpcoming: isUpcoming,
                colorScheme: colorScheme,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Internal widget for individual step indicator
class _StepItem extends StatelessWidget {
  final int index;
  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final bool isUpcoming;
  final ColorScheme colorScheme;

  const _StepItem({
    Key? key,
    required this.index,
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.isUpcoming,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Step number with status indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getCircleColor(),
            border: Border.all(
              color: isCurrent ? colorScheme.primary : Colors.transparent,
              width: 2.w,
            ),
          ),
          child: Center(
            child: _buildIcon(),
          ),
        ),
        Gap(Spacing.xs.h),
        // Step label
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: _getLabelColor(),
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getCircleColor() {
    if (isCompleted) return colorScheme.primary;
    if (isCurrent) return colorScheme.primaryContainer;
    return colorScheme.surfaceVariant;
  }

  Color _getLabelColor() {
    if (isCompleted || isCurrent) return colorScheme.onSurface;
    return colorScheme.onSurface.withOpacity(0.5);
  }

  Widget _buildIcon() {
    if (isCompleted) {
      return Icon(
        Icons.check,
        size: IconSizes.sm.w,
        color: colorScheme.onPrimary,
      );
    }
    if (isCurrent) {
      return Text(
        '${index + 1}',
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      );
    }
    return Text(
      '${index + 1}',
      style: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.5),
        fontSize: 14.sp,
      ),
    );
  }
}
