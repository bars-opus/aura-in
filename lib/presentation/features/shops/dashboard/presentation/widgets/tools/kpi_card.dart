// lib/features/dashboard/presentation/widgets/kpi_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/app_colors.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// Individual KPI card displaying a metric with optional trend indicator
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final double? trendPercent;
  final bool trendUpIsPositive;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.trendPercent,
    this.trendUpIsPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InfoRowWidget(
      title: value,
      subtitle: title,
      onTap: onTap,
      iconColor: iconColor,
      backgroundColor: iconColor!.withOpacity(.1),
      icon: icon,
      avatarRadius: 20.h,
      showTrailingArrow: false,
      disableTrailing: false,
      circularRadius: 10.r,
      showDivider: true,
      trailing: // Trend indicator
          trendPercent != null
              ? Padding(
                padding: EdgeInsets.only(top: Spacing.xs.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPositiveTrend
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: IconSizes.xs,
                      color:
                          _isPositiveTrend
                              ? colorScheme.success
                              : colorScheme.error,
                    ),
                    Gap(Spacing.xs.h),
                    Text(
                      '${(trendPercent!.abs() * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            _isPositiveTrend
                                ? colorScheme.success
                                : colorScheme.error,
                      ),
                    ),
                  ],
                ),
              )
              : SizedBox.shrink(),
    );
  }

  bool get _isPositiveTrend {
    if (trendPercent == null) return true;
    return trendUpIsPositive ? trendPercent! >= 0 : trendPercent! <= 0;
  }
}
