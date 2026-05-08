// lib/features/dashboard/presentation/widgets/promotion_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const PromotionCard({
    super.key,
    required this.promotion,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isExpired = promotion.isExpired;
    final isActive = promotion.isValid;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Spacing.sm.h),
        padding: EdgeInsets.all(Spacing.md.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
            width: BorderWidthTokens.hairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with code and status
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.xs.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    promotion.code,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Gap(Spacing.sm.w),
                if (!isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xs.w,
                      vertical: Spacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      isExpired ? 'Expired' : 'Inactive',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: IconSizes.sm,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            Gap(Spacing.sm.h),

            // Promotion name
            Text(
              promotion.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.xs.h),

            // Discount
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: IconSizes.xs,
                  color: colorScheme.primary,
                ),
                Gap(Spacing.xs.w),
                Text(
                  promotion.formattedDiscount,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            Gap(Spacing.xs.h),

            // Validity dates
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: IconSizes.xs,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                Gap(Spacing.xs.w),
                Text(
                  '${_formatDate(promotion.validFrom)} - ${_formatDate(promotion.validTo)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            Gap(Spacing.xs.h),

            // Usage stats
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: IconSizes.xs,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                Gap(Spacing.xs.w),
                Text(
                  promotion.isUnlimited
                      ? 'Used ${promotion.usageCount} times'
                      : 'Used ${promotion.usageCount}/${promotion.usageLimit} times',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
