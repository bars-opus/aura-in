import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ShopNoLocationSet extends StatelessWidget {
  const ShopNoLocationSet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        BottomSheetUtils.showDocumentationBottomSheet(
          maxHeight: 300.h,
          context: context,
          widget: LocationPickerBottomSheet(),
        );
      },
      child: SemanticContainerWidget(
        content: loc.shopNoLocationSetContent,
        icon: Icons.location_on,
        trailingIcon: Icons.add,
        title: loc.shopNoLocationSetTitle,

        backgroundColor: colorScheme.success.withValues(alpha: 0.1),
        borderColor: colorScheme.success,
        iconColor: colorScheme.success,
        textTheme: textTheme,
      ),
    );
  }
}
