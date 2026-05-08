// lib/features/shop/creation/presentation/widgets/section_status_indicator.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class SectionStatusIndicator extends StatelessWidget {
  final bool isComplete;
  const SectionStatusIndicator({super.key, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.xs.w, vertical: 2.h),
      decoration: BoxDecoration(
        color:
            isComplete
                ? Colors.green.withOpacity(0.1)
                : colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: IconSizes.sm.h,
            color: isComplete ? Colors.green : colorScheme.outline,
          ),
          SizedBox(width: Spacing.xs.w),
          Text(
            isComplete ? 'Complete' : 'Pending',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isComplete ? Colors.green : colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
