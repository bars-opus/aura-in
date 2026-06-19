// lib/features/shop/creation/presentation/screens/manage_media_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_media_provider.dart';
import 'package:path/path.dart';
import '../widgets/shop_media_grid.dart';

class ManageMediaScreen extends ConsumerWidget {
  const ManageMediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(shopCreationProvider);
    final images = ref.watch(shopMediaProvider); // Get images directly
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.neutral,

      appBar: AppBar(backgroundColor: Colors.transparent, actions: [
         
        ],
      ),

      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
        children: [
          SemanticContainerWidget(
            content:
                'Add at least 3 good looking professional photos of your shop. You can drag to reorder - the first photo will be your cover image.',
            icon: Icons.add_photo_alternate,
            title: 'Shop Photos',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),
          Gap(Spacing.sm.h),
          Expanded(child: SingleChildScrollView(child: const ShopMediaGrid())),
        ],
      ),
      bottomNavigationBar:
          images.length >= ShopMediaNotifier.minImages
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to save',
                    onPressed: () {
                      _saveAndContinue(context);
                    },

                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              )
              : null,
    );
  }

  void _saveAndContinue(BuildContext context) {
    // if (_formKey.currentState?.validate() ?? false) {
    //   ref
    //       .read(shopCreationProvider.notifier)
    //       .updateBasics(
    //         shopName: _nameController.text,
    //         shopType: _selectedType,
    //         luxuryLevel: _selectedLuxuryLevel,
    //         overview:
    //             _overviewController.text.isNotEmpty
    //                 ? _overviewController.text
    //                 : null,
    //         terms:
    //             _termsController.text.isNotEmpty ? _termsController.text : null,
    //       );
    Navigator.pop(context);
    // context.push('/location'); // Use your navigation method
  }
}
