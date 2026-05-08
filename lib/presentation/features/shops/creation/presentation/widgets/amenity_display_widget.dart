import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/app_divider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/amenity_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/amenity.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';

class AmenityDisplayWidget extends ConsumerWidget {
  final List<String> selectedAmenityIds;
  // final bool shouldBeCategorised;

  const AmenityDisplayWidget({
    super.key,
    required this.selectedAmenityIds,
    // this.shouldBeCategorised = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(amenitiesByCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        // Sort categories alphabetically by name
        final sortedCategories = List<AmenityCategory>.from(categories)
          ..sort((a, b) => a.name.compareTo(b.name));

        // Get all selected amenities and sort alphabetically by name
        final allSelectedAmenities =
            sortedCategories
                .expand((c) => c.amenities)
                .where((amenity) => selectedAmenityIds.contains(amenity.id))
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        if (allSelectedAmenities.isEmpty) {
          return _buildEmptyState();
        }

        return ShopDetailsSection(
          title: 'Amenities',
          seeAllOnperssed:
              selectedAmenityIds.length > 5
                  ? () {
                    BottomSheetUtils.showDocumentationBottomSheet(
                      context: context,
                      widget: _categoryWidget(context, sortedCategories),
                    );
                  }
                  : null,
          widget: SizedBox(
            height: allSelectedAmenities.length * 30,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allSelectedAmenities.length,
              separatorBuilder: (context, index) => AppDivider(),
              itemBuilder: (context, index) {
                final amenity = allSelectedAmenities[index];
                return _buildAmenityTile(context, amenity);
              },
            ),
          ),
        );
      },
      loading:
          () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularLoadingIndicator(),
            ),
          ),
      error:
          (error, stack) => Center(
            child: ErrorStateWidget(
              subtitle: 'Failed to load amenities',
              onPrimaryAction: () {
                ref.invalidate(amenitiesByCategoryProvider);
              },
            ),
          ),
    );
  }

  Widget _categoryWidget(
    BuildContext context,
    List<AmenityCategory> categories,
  ) {
    final categoriesWithSelectedAmenities =
        categories
            .map(
              (category) => AmenityCategory(
                name: category.name,
                amenities:
                    category.amenities
                        .where(
                          (amenity) => selectedAmenityIds.contains(amenity.id),
                        )
                        .toList()
                      ..sort(
                        (a, b) => a.name.compareTo(b.name),
                      ), // Sort amenities alphabetically within category
              ),
            )
            .where((category) => category.amenities.isNotEmpty)
            .toList();

    if (categoriesWithSelectedAmenities.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoriesWithSelectedAmenities.length,
      itemBuilder: (context, categoryIndex) {
        final category = categoriesWithSelectedAmenities[categoryIndex];
        return _buildCategorySection(context, category);
      },
    );
  }

  Widget _buildCategorySection(BuildContext context, AmenityCategory category) {
    final theme = Theme.of(context);

    return CardInkWell(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          AppDivider(),
          ...category.amenities.asMap().entries.map((entry) {
            final index = entry.key;
            final amenity = entry.value;
            return Column(
              children: [
                _buildAmenityTile(context, amenity),
                if (index < category.amenities.length - 1)
                  Padding(
                    padding: EdgeInsets.only(left: Spacing.xl.h + 10.w),
                    child: AppDivider(),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAmenityTile(BuildContext context, Amenity amenity) {
  final theme = Theme.of(context);
  
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (amenity.icon != null) ...[
        Icon(amenity.icon, size: 16.sp, color: theme.colorScheme.primary),
        SizedBox(width: 6.w),
      ],
      Text(
        amenity.name,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    ],
  );
}
  Widget _buildEmptyState() {
    return Center(
      child: Center(
        child: EmptyStateWidget(
          title: '',
          subtitle: 'No amenities available',
          icon: Icons.hotel_outlined,
        ),
      ),
    );
  }
}
