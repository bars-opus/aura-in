import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';

/// A simple countdown widget that counts down to a specified target date.
/// Uses Stream for real-time updates.

class CountdownStreamWidget extends StatelessWidget {
  final DateTime targetDate;
  final VoidCallback? onComplete;
  final String? completedText;
  final bool showDays;
  final bool showHours;
  final bool showMinutes;
  final bool showSeconds;

  const CountdownStreamWidget({
    super.key,
    required this.targetDate,
    this.onComplete,
    this.completedText = "Today!",
    this.showDays = true,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    // Check if target date is today
    final isToday =
        targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day;

    // Check if date is in the past
    final isPast = targetDate.isBefore(now);

    return StreamBuilder<Duration>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) {
        final remaining = targetDate.difference(DateTime.now());
        return remaining.isNegative ? Duration.zero : remaining;
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final remaining = snapshot.data!;

        // Handle past dates - show time ago instead of countdown
        if (isPast) {
          final difference = now.difference(targetDate);
          final daysAgo = difference.inDays;
          final monthsAgo =
              (now.year - targetDate.year) * 12 +
              (now.month - targetDate.month);

          String timeAgoText;
          if (monthsAgo > 0) {
            timeAgoText =
                monthsAgo == 1 ? '1 month ago' : '$monthsAgo months ago';
          } else if (daysAgo > 0) {
            timeAgoText = daysAgo == 1 ? '1 day ago' : '$daysAgo days ago';
          } else if (difference.inHours > 0) {
            final hoursAgo = difference.inHours;
            timeAgoText = hoursAgo == 1 ? '1 hour ago' : '$hoursAgo hours ago';
          } else if (difference.inMinutes > 0) {
            final minutesAgo = difference.inMinutes;
            timeAgoText =
                minutesAgo == 1 ? '1 minute ago' : '$minutesAgo minutes ago';
          } else {
            timeAgoText = 'Just now';
          }

          return ShakeTransition(
            duration: Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            child: Text(
              timeAgoText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(
                  .6,
                ), // Red color for past dates
              ),
            ),
          );
        }

        // Handle today's date - special styling
        if (isToday) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onComplete?.call();
          });
          return Text(
            completedText!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.success, // Green color for today
              fontWeight: FontWeight.bold,
            ),
          );
        }

        // Future date - show countdown
        final days = remaining.inDays;
        final hours = remaining.inHours % 24;
        final minutes = remaining.inMinutes % 60;
        final seconds = remaining.inSeconds % 60;

        final parts = <String>[];

        if (showDays && days > 0) {
          parts.add('${days}d');
        }
        if (showHours && (hours > 0 || parts.isNotEmpty)) {
          parts.add('${hours.toString().padLeft(2, '0')}h');
        }
        if (showMinutes && (minutes > 0 || parts.isNotEmpty)) {
          parts.add('${minutes.toString().padLeft(2, '0')}m');
        }
        if (showSeconds) {
          parts.add('${seconds.toString().padLeft(2, '0')}s');
        }

        final displayText = parts.isEmpty ? '0s' : parts.join(' ');

        // Determine color based on urgency
        Color textColor;
        if (days == 0 && hours < 24) {
          // Less than a day left - use warning color
          textColor = colorScheme.primary;
        } else if (days < 3) {
          // Less than 3 days left - use accent color
          textColor = colorScheme.warning;
        } else {
          // Normal countdown
          textColor = colorScheme.onSurfaceVariant;
        }

        return Text(
          displayText,
          style: theme.textTheme.labelMedium?.copyWith(color: textColor),
        );
      },
    );
  }
}
