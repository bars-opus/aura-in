import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ShopDetailsSection extends StatelessWidget {
  final String title;
  final VoidCallback? seeAllOnperssed;
  final Widget widget;
  final bool showCard;

  const ShopDetailsSection({
    super.key,
    required this.title,
    required this.seeAllOnperssed,
    required this.widget,
    this.showCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(Spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            if (seeAllOnperssed != null)
              AppTextButton(
                fontSize: 12.sp,
                text: 'See all',
                onPressed: seeAllOnperssed,
              ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm),
          child:
              showCard
                  ? CardInkWell(
                    // elevation: 0,
                    onTap: () {},
                    child: widget,
                  )
                  : widget,
        ),
      ],
    );
  }
}
