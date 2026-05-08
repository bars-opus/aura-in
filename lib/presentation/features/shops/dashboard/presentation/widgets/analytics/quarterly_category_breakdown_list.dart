// lib/features/dashboard/presentation/widgets/category_breakdown_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quaterly_category_breakdown.dart';

class CategoryBreakdownList extends StatelessWidget {
  final List<QuaterlyCategoryBreakdown> categories;
  final bool isLoading;

  const CategoryBreakdownList({
    super.key,
    required this.categories,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return ShopSchimmerSkeleton(height: 350.h);
    }

    if (categories.isEmpty) {
      return CardInkWell(
        onTap: () {},
        child: Center(
          child: EmptyStateWidget(
            title: '',
            icon: Icons.horizontal_rule_outlined,
            subtitle: 'No category progress data available for this quarter',
          ),
        ),
      );
    }

    return Column(
      children: [
        ...categories.map(
          (category) => _buildCategoryRow(category, theme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(
    QuaterlyCategoryBreakdown category,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${category.amount.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                ),
                textAlign: TextAlign.right,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100.w,
                    child: LinearProgressIndicator(
                      value: category.percentage / 100,
                      backgroundColor: colorScheme.outline.withOpacity(0.1),
                      color: colorScheme.primary,
                    ),
                  ),
                  Gap(Spacing.sm.w),
                  Text(
                    '${category.percentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
