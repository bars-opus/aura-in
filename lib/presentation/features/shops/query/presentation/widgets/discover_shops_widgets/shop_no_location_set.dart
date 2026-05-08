import 'package:flutter/widgets.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ShopNoLocationSet extends StatelessWidget {
  const ShopNoLocationSet({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CardInkWell(
      onTap: () {},
      margin: EdgeInsets.only(bottom: 0),
      // padding: const EdgeInsets.all(0),
      child: GestureDetector(
        onTap: () {
          BottomSheetUtils.showDocumentationBottomSheet(
            maxHeight: 500.h,
            context: context,
            widget: LocationPickerBottomSheet(),
          );
        },
        child: SemanticContainerWidget(
          content:
              'Set your location to discover premium and top rated shops near you.',
          icon: Icons.location_on,
          title: 'Set your location to discover',
          backgroundColor: Colors.green.withOpacity(0.1),
          borderColor: Colors.green,
          iconColor: Colors.green,
          textTheme: textTheme,
        ),
      ),
    );
  }
}
