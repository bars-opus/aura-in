import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';

class CategoryHeader extends StatelessWidget {
  final String title;
  final String? body;
  final bool showSeeAll;
  final VoidCallback onPressed;

  const CategoryHeader({
    super.key,
    required this.title,
    this.body,
    required this.showSeeAll,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  maxHeight: 320.h,
                  context: context,
                  widget: Column(
                    children: [
                      Gap(Spacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          AppTextButton(),
                        ],
                      ),
                      Gap(Spacing.md),
                      if (body != null)
                        Text(
                          body!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onBackground),
                        ),
                    ],
                  ),
                );
              },
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Gap(Spacing.md.w),
          if (showSeeAll)
            AppTextButton(
              text: loc.searchResultsSeeAll,
              onPressed: onPressed,
              fontSize: FontSizeTokens.sm,
            ),
        ],
      ),
    );
  }
}
