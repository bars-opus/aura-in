import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';

class ServiceAnalyticsHeader extends StatelessWidget {
  final String headerTitle;
  final VoidCallback? onSeeAll;

  final String periodName;

  const ServiceAnalyticsHeader({
    super.key,
    required this.onSeeAll,
    required this.headerTitle,
    required this.periodName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.2, // Controls line height (default is ~1.2-1.5)
                ),
                children: [
                  TextSpan(
                    text: '$periodName\n',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      height: 1.0, // Tighter spacing for this line
                    ),
                  ),
                  TextSpan(
                    text: headerTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.0, // Tighter spacing for this line
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.start,
            ),

            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ), // Period indicator
        Gap(Spacing.sm.h),
      ],
    );
  }
}
