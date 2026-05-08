import 'package:flutter/material.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class MiniContainerIndicator extends StatelessWidget {
  final Color color;
  final Color? fontColor;

  final String text;
  final bool isInverted;
  final double fontSize;
  final bool isCircle;

  const MiniContainerIndicator({
    super.key,
    required this.color,
    required this.text,
    this.isInverted = false,
    this.isCircle = false,
    this.fontSize = 8,
    this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding:
          isCircle
              ? EdgeInsets.all(Spacing.xs.w)
              : EdgeInsets.symmetric(horizontal: Spacing.xs.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isInverted ? color : color.withOpacity(0.1),

        // _getLuxuryColor(luxuryLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(isCircle ? 100.r : 4.r),
      ),
      child: Text(
        text,
        // luxuryLevel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isInverted ? colorScheme.background : fontColor ?? color,
          // _getLuxuryColor(luxuryLevel),
          fontSize: fontSize.h,
        ),
      ),
    );
  }
}
