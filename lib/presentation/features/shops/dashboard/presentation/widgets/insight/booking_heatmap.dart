// lib/features/dashboard/presentation/widgets/booking_heatmap.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/booking_heatmap_data.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/insight/day_label.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/insight/heatmap_insights.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/insight/legend_item.dart';

class BookingHeatmap extends StatelessWidget {
  final BookingHeatmapData data;
  final VoidCallback? onTap;
  final void Function(int day, int hour)? onCellTap;

  const BookingHeatmap({
    super.key,
    required this.data,
    this.onTap,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define hours to show (8am to 10pm = 14 hours)
    const startHour = 8;
    const endHour = 22;
    final hours = List.generate(endHour - startHour + 1, (i) => startHour + i);
    final hourCount = hours.length;

    // Create lookup map for O(1) access
    final pointsMap = data.pointsMap;

    return Column(
      children: [
        CardInkWell(
          margin: EdgeInsets.only(bottom: Spacing.xs),

          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Heatmap',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Gap(Spacing.sm.h),
              Text(
                'Most popular times for bookings',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Gap(Spacing.md.h),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LegendItem(color: _getColor(0.0, colorScheme), label: 'None'),
                  Gap(Spacing.sm.w),
                  LegendItem(color: _getColor(0.2, colorScheme), label: 'Low'),
                  Gap(Spacing.sm.w),
                  LegendItem(
                    color: _getColor(0.4, colorScheme),
                    label: 'Medium',
                  ),
                  Gap(Spacing.sm.w),
                  LegendItem(color: _getColor(0.7, colorScheme), label: 'High'),
                  Gap(Spacing.sm.w),
                  LegendItem(color: _getColor(1.0, colorScheme), label: 'Peak'),
                ],
              ),
              Gap(Spacing.md.h),
              // Heatmap Grid
              SizedBox(
                height: 150.h,
                child: GridView.builder(
                  padding: EdgeInsets.only(top: Spacing.sm),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: hourCount + 1, // +1 for day labels
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount:
                      (hourCount + 1) *
                      7, // 7 days × (hours + day label column)
                  itemBuilder: (context, index) {
                    final col = index % (hourCount + 1);
                    final row = index ~/ (hourCount + 1);

                    // First column = day labels
                    if (col == 0) {
                      if (row < 7) {
                        return DayLabel(day: row);
                      }
                      return const SizedBox.shrink();
                    }

                    final day = row;
                    final hourIndex = col - 1;
                    final hour = hours[hourIndex];

                    if (day >= 7) return const SizedBox.shrink();

                    // Get booking count from map
                    final point = pointsMap['${day}_$hour'];
                    final bookingCount = point?.bookingCount ?? 0;

                    // Calculate intensity (0.0 to 1.0)
                    double intensity = 0.0;
                    if (data.maxBookingCount > 0 && bookingCount > 0) {
                      intensity = (bookingCount / data.maxBookingCount).clamp(
                        0.0,
                        1.0,
                      );
                    }

                    return GestureDetector(
                      onTap: () => onCellTap?.call(day, hour),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getColor(intensity, colorScheme),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child:
                              bookingCount > 0
                                  ? Text(
                                    bookingCount.toString(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: FontSizeTokens.xxs.sp,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          intensity > 0.6
                                              ? Colors.white
                                              : colorScheme.onSurface,
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Gap(Spacing.sm.h),

              // Hour labels
              Padding(
                padding: EdgeInsets.only(left: 48.w),
                child: Row(
                  children:
                      hours.map((hour) {
                        return Expanded(
                          child: Text(
                            _getHourLabel(hour),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: FontSizeTokens.xxs.sp,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }).toList(),
                ),
              ),
              Gap(Spacing.md.h),

              // AppDivider(),
              // Gap(Spacing.md.h),
            ],
          ),
        ),
        CardInkWell(child: HeatmapInsights(data: data)),
      ],
    );
  }

  Color _getColor(double intensity, ColorScheme colorScheme) {
    // Make colors more vibrant so they're visible
    if (intensity <= 0) {
      return colorScheme.onBackground.withOpacity(
        .1,
      ); // White/light gray for empty
    }
    if (intensity < 0.2) {
      return colorScheme.onBackground.withOpacity(.3); // Very light green
    }
    if (intensity < 0.4) {
      return Colors.green.shade200;
    }
    if (intensity < 0.6) {
      return Colors.green.shade300;
    }
    if (intensity < 0.8) {
      return Colors.green.shade500;
    }
    return Colors.green.shade800; // Dark green for peak
  }

  String _getHourLabel(int hour) {
    if (hour == 0) return '12am';
    if (hour < 12) return '${hour}am';
    if (hour == 12) return '12pm';
    return '${hour - 12}pm';
  }
}
