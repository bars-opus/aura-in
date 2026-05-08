// lib/features/freelancer/creation/presentation/widgets/completion_progress_bar.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// Progress bar showing completion status of freelancer profile creation
class CompletionProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const CompletionProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = completed / total;

    final progressColor = _getProgressColor(percentage, colorScheme.primary);

    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                completed == total ? 'Complete!' : 'Profile Progress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '$completed/$total sections',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Gap(Spacing.sm.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8.h,
            ),
          ),
          Gap(Spacing.sm.h),
          Text(
            _getProgressMessage(completed, total),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage, Color primaryColor) {
    if (percentage >= 0.7) {
      return Colors.green;
    } else if (percentage >= 0.4) {
      return Colors.orange;
    } else {
      return primaryColor;
    }
  }

  String _getProgressMessage(int completed, int total) {
    if (completed == 0) return 'Start by adding your name and profession';
    if (completed < 3) return 'Keep going! You\'re making progress';
    if (completed < total) return 'Almost there! Just a few more sections';
    return 'Ready to publish! 🎉';
  }
}
