import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/amenity_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/amenity.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';

class AmenityDisplayWidget extends ConsumerWidget {
  static const int _previewLimit = 6;

  final List<String> selectedAmenityIds;

  const AmenityDisplayWidget({super.key, required this.selectedAmenityIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(amenitiesByCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        final selectedIds = selectedAmenityIds.toSet();
        final selectedCategories = _selectedCategories(categories, selectedIds);
        final selectedAmenities =
            selectedCategories.expand((category) => category.amenities).toList()
              ..sort(_compareAmenities);

        if (selectedAmenities.isEmpty) return const SizedBox.shrink();

        final previewAmenities = selectedAmenities.take(_previewLimit).toList();

        return ShopDetailsSection(
          title: 'Amenities',
          showCard: false,
          seeAllOnperssed:
              selectedAmenities.length > _previewLimit
                  ? () => _showAllAmenities(context, selectedCategories)
                  : null,
          widget: Container(
            width: double.infinity,
            padding: EdgeInsets.all(Spacing.md.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadiusTokens.lgAll,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.12),
                width: BorderWidthTokens.hairline,
              ),
            ),
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < previewAmenities.length;
                  index++
                ) ...[
                  _AmenityChip(amenity: previewAmenities[index]),
                  if (index < previewAmenities.length - 1) Gap(Spacing.sm.h),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const _AmenityLoadingPreview(),
      error:
          (error, stack) => ErrorStateWidget(
            subtitle: 'Failed to load amenities',
            compact: true,
            onPrimaryAction: () {
              ref.invalidate(amenitiesByCategoryProvider);
            },
          ),
    );
  }

  List<AmenityCategory> _selectedCategories(
    List<AmenityCategory> categories,
    Set<String> selectedIds,
  ) {
    final selectedCategories =
        categories
            .map(
              (category) => AmenityCategory(
                name: category.name,
                amenities:
                    category.amenities
                        .where((amenity) => selectedIds.contains(amenity.id))
                        .toList()
                      ..sort(_compareAmenities),
              ),
            )
            .where((category) => category.amenities.isNotEmpty)
            .toList();

    selectedCategories.sort((a, b) => a.name.compareTo(b.name));
    return selectedCategories;
  }

  int _compareAmenities(Amenity a, Amenity b) {
    final orderComparison = a.displayOrder.compareTo(b.displayOrder);
    return orderComparison != 0 ? orderComparison : a.name.compareTo(b.name);
  }

  void _showAllAmenities(
    BuildContext context,
    List<AmenityCategory> categories,
  ) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: _AllAmenitiesSheet(categories: categories),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final Amenity amenity;

  const _AmenityChip({required this.amenity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: amenity.name,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(width: .1, color: colorScheme.onBackground),
          borderRadius: BorderRadiusTokens.mdAll,
        ),
        child: Row(
          children: [
            Icon(
              amenity.icon ?? Icons.check_circle_outline_rounded,
              size: 18.r,
              color: colorScheme.primary,
            ),
            Gap(Spacing.sm.w),
            Flexible(
              child: Text(
                amenity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllAmenitiesSheet extends StatelessWidget {
  final List<AmenityCategory> categories;

  const _AllAmenitiesSheet({required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amenityCount = categories.fold<int>(
      0,
      (count, category) => count + category.amenities.length,
    );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          'Amenities',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(Spacing.xs.h),
        Text(
          '$amenityCount available at this shop',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Gap(Spacing.xl.h),
        for (final category in categories) ...[
          Text(
            category.name,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.sm.h),
          Column(
            children: [
              for (
                var index = 0;
                index < category.amenities.length;
                index++
              ) ...[
                _AmenityChip(amenity: category.amenities[index]),
                if (index < category.amenities.length - 1) Gap(Spacing.sm.h),
              ],
            ],
          ),
          Gap(Spacing.xl.h),
        ],
      ],
    );
  }
}

class _AmenityLoadingPreview extends StatelessWidget {
  const _AmenityLoadingPreview();

  @override
  Widget build(BuildContext context) {
    return ShopDetailsSection(
      title: 'Amenities',
      seeAllOnperssed: null,
      showCard: false,
      widget: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == 3 ? 0 : Spacing.sm.h),
            child: ShopSchimmerSkeleton(width: double.infinity, height: 44.h),
          ),
        ),
      ),
    );
  }
}
