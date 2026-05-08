import 'package:flutter/material.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';

class ShopCardSubDetails extends StatelessWidget {
  final String ratings;
  final String clientWorks;
  final String distance;
  final bool showIcon;
  const ShopCardSubDetails({
    super.key,
    required this.ratings,
    required this.clientWorks,
    required this.distance,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    _rowTexts(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
    ) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon)
            AppIconButton(
              icon: icon,
              size: 15,
              iconColor: colorScheme.onBackground.withOpacity(.4),
            ),
          if (showIcon) Gap(Spacing.md.w),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '\n${subtitle}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _rowTexts(context, ratings, 'Ratings', Icons.star_border),

        _rowTexts(
          context,
          clientWorks,
          'Client works',
          Icons.handshake_outlined,
        ),

        _rowTexts(context, distance, 'Distance', Icons.directions),
      ],
    );
  }
}
