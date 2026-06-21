// lib/features/shop/creation/presentation/screens/manage_amenities_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import '../widgets/amenity_checkbox_group.dart';

class ManageAmenitiesScreen extends ConsumerStatefulWidget {
  const ManageAmenitiesScreen({super.key});

  @override
  ConsumerState<ManageAmenitiesScreen> createState() =>
      _ManageAmenitiesScreenState();
}

class _ManageAmenitiesScreenState extends ConsumerState<ManageAmenitiesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedIds = ref.watch(
      shopCreationProvider.select((draft) => draft.amenityIds),
    );
    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // actions: [AppTextButton(text: 'Save', onPressed: _saveAndExit)],
      ),
      body: Padding(
        padding: EdgeInsets.all(Spacing.md.h),
        child: ListView(
          children: [
            SemanticContainerWidget(
              content:
                  'This helps customers have an expectation of the comfort and ease available at your shop.',
              icon: Icons.hotel_outlined,
              title: 'Select the amenities and features your shop provides',
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              borderColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              textTheme: theme.textTheme,
            ),
            Gap(Spacing.lg.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedIds.length} amenities selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                if (selectedIds.isEmpty)
                  Text(
                    'None selected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
            Gap(Spacing.md.h),
            AppDivider(), Gap(Spacing.sm.h),
            // Amenities list
            Expanded(
              child: SingleChildScrollView(
                child: AmenityCheckboxGroup(
                  selectedAmenityIds: selectedIds,
                  onSelectionChanged: (selectedIds) {
                    ref
                        .read(shopCreationProvider.notifier)
                        .updateAmenities(selectedIds);
                    // setState(() {
                    //   _selectedAmenityIds = selectedIds;
                    // });
                  },
                ),
              ),
            ),

            // Selected count
          ],
        ),
      ),
      bottomNavigationBar:
          selectedIds.isNotEmpty
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to openening hours',
                    onPressed: _saveAndContinue,
                    center: false,
                    iconData: Icons.schedule,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,

                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              )
              : SizedBox.shrink(),
    );
  }

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/setHours'); // Use your navigation method
  }
}
