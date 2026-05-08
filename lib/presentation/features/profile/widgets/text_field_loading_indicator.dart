import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class TextFieldLoadingIndicator extends StatelessWidget {
  const TextFieldLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0.h),
      child:
      CircularLoadingIndicator(
         size:  Spacing.sm,
        ),
      
      
    );
  }
}
