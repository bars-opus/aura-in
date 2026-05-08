// lib/core/widgets/completion_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';

/// Universal progress bar for multi-step creation flows
///
/// This widget can be used for any draft type (ShopDraft, FreelancerDraft, etc.)
/// that provides `completedSectionsCount` and `totalSections` properties.
///
/// Usage:
/// ```dart
/// CompletionProgressBar(
///   completed: draft.completedSectionsCount,
///   total: ShopDraft.totalSections,
///   entityType: 'shop', // optional, for custom messages
/// )
/// ```
class CompletionProgressBar extends StatelessWidget {
  /// Number of completed sections
  final int completed;

  /// Total number of sections
  final int total;

  /// Optional entity type for custom progress messages (e.g., 'shop', 'freelancer')
  final String? entityType;

  /// Custom completion message (overrides default)
  final String? completionMessage;

  /// Custom progress message builder (for full customization)
  final String Function(int completed, int total)? messageBuilder;

  const CompletionProgressBar({
    super.key,
    required this.completed,
    required this.total,
    this.entityType,
    this.completionMessage,
    this.messageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = completed / total;
    final progressColor = _getProgressColor(percentage, colorScheme.primary);
    final isComplete = completed == total;

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
                isComplete ? 'Completed' : 'Completion Progress',
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
              value: percentage.clamp(0.0, 1.0),
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
      return Colors.green; // 70% or more - green
    } else if (percentage >= 0.4) {
      return Colors.orange; // 40% to 69% - orange
    } else {
      return primaryColor; // Less than 40% - primary color
    }
  }

  String _getProgressMessage(int completed, int total) {
    // Use custom message builder if provided
    if (messageBuilder != null) {
      return messageBuilder!(completed, total);
    }

    // Use completion message if provided and complete
    if (completed == total && completionMessage != null) {
      return completionMessage!;
    }

    // Use entity type for contextual messages
    final type = entityType ?? '';
    final capitalizedType =
        type.isNotEmpty ? type[0].toUpperCase() + type.substring(1) : '';

    if (completed == 0) {
      return type.isNotEmpty
          ? 'Start by adding your $type name'
          : 'Start by adding your information';
    }

    if (completed < 3) {
      return 'Keep going! You\'re making progress';
    }

    if (completed < total) {
      return type.isNotEmpty
          ? 'Almost there! Just a few more sections to complete your $type profile'
          : 'Almost there! Just a few more sections';
    }

    return type.isNotEmpty
        ? 'Ready to publish your $type profile! 🎉'
        : 'Ready to publish! 🎉';
  }
}

/// Extension for easy creation with shop drafts
extension ShopDraftProgress on Object {
  // This is just a convenience - actual usage will be inline
}

/// Convenience widget for ShopDraft progress
class ShopCompletionProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const ShopCompletionProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return CompletionProgressBar(
      completed: completed,
      total: total,
      entityType: 'shop',
      completionMessage: 'Your shop is ready to go live! 🎉',
    );
  }
}

/// Convenience widget for FreelancerDraft progress
class FreelancerCompletionProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const FreelancerCompletionProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return CompletionProgressBar(
      completed: completed,
      total: total,
      entityType: 'freelancer',
      completionMessage: 'Your freelancer profile is ready to publish! 🎉',
    );
  }
}
