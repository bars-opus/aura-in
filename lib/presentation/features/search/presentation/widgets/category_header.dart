import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';

class CategoryHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback onPressed;

  const CategoryHeader({
    super.key,
    required this.title,
    required this.showSeeAll,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (showSeeAll)
            AppTextButton(
              text: 'See all',
              onPressed: onPressed,
              fontSize: FontSizeTokens.sm,
            ),
        ],
      ),
    );
  }
}
