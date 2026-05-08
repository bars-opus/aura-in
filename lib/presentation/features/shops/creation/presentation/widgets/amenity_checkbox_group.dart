// lib/features/shops/creation/presentation/widgets/amenity_checkbox_group.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/amenity_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/amenity.dart';
import 'package:nano_embryo/presentation/features/shops/creation/utils/amenity_icon_helper.dart';

class AmenityCheckboxGroup extends ConsumerStatefulWidget {
  final List<String> selectedAmenityIds;
  final Function(List<String>) onSelectionChanged;

  const AmenityCheckboxGroup({
    super.key,
    required this.selectedAmenityIds,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<AmenityCheckboxGroup> createState() =>
      _AmenityCheckboxGroupState();
}

class _AmenityCheckboxGroupState extends ConsumerState<AmenityCheckboxGroup> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(amenitiesByCategoryProvider);
    final theme = Theme.of(context);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Text(
              'No amenities available',
              style: theme.textTheme.bodyMedium,
            ),
          );
        }
        return Column(
          children:
              categories.map((cat) => _buildCategory(cat, theme)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, _) => Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text('Failed to load amenities: $err'),
                TextButton(
                  onPressed: () => ref.invalidate(amenitiesByCategoryProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }



  Widget _buildCategory(AmenityCategory category, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(Spacing.md),
        Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
          child: Text(
            category.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground.withOpacity(.6),
            ),
          ),
        ),
        // AppDivider(),
        CardInkWell(
          // margin: EdgeInsets.only(bottom: Spacing.md.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...category.amenities.map(
                (amenity) => _buildAmenityTile(
                  amenity,
                  theme,
                  category.amenities.indexOf(amenity) <
                      category.amenities.length - 1,
                ),
              ),

              // Gap(Spacing.md.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityTile(Amenity amenity, ThemeData theme, bool showDivider) {
    final isSelected = widget.selectedAmenityIds.contains(amenity.id);
    final colorScheme = theme.colorScheme;

    final icon = AmenityIconHelper.getIconData(amenity.iconName);

    return InfoRowWidget(
      subtitle: amenity.name,
      title: '',
      icon: icon,
      iconColor: isSelected ? colorScheme.primary : colorScheme.onBackground,
      avatarRadius: 25.h,
      onTap: () {
        final ids = List<String>.from(widget.selectedAmenityIds);
        if (isSelected) {
          // ✅ If already selected, remove it
          ids.remove(amenity.id);
        } else {
          // ✅ If not selected, add it
          ids.add(amenity.id);
        }
        widget.onSelectionChanged(ids);
      },
      showAvatar: false,
      showTrailingArrow: false,
      showDivider: showDivider,
      trailing: Container(
        width: 18.w,
        height: 18.h,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(2.r),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.4),
            width: 2,
          ),
        ),
        child:
            isSelected
                ? Icon(Icons.check, size: 16.sp, color: colorScheme.onPrimary)
                : null,
      ),
    );
  }
}
