// lib/features/licenses/oss_licenses_screen.dart

import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LicensePage(
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: AppConstants.appCopyright,
    );
  }
}
