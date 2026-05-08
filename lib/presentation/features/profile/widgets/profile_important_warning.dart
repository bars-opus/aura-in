import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ProfileImportantWarning extends StatelessWidget {
  const ProfileImportantWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        children: [
          Gap(15.h),
          SemanticContainerWidget(
            content:
                'Kindly verify your email before 12 March to avaiding losing your account.',
            icon: Icons.info_outline,
            title: '',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}
