import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_packages.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';

class CenterFloatingActionButton extends StatelessWidget {
  const CenterFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Map',
      onPressed: () {},
      iconData: Icons.map,
      borderRadius: BorderRadiusTokens.xlAll,
      size: ButtonSize.small,
      width: 200.w,
      padding: Spacing.horizontalMd,
      height: 40.h,
    );
  }
}
