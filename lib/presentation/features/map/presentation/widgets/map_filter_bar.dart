import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/animations/shake_transition.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';
import 'package:nano_embryo/core/widgets/shop_category_tabs.dart';
import 'package:nano_embryo/presentation/features/map/presentation/providers/map_filter_providers.dart';

class MapFilterBar extends ConsumerWidget {
  const MapFilterBar({super.key});

  static const List<String> _categories = [
    'all',
    'salon',
    'barbershop',
    'spa',
    'nail_salon',
    'lash_studio',
    'waxing',
    'massage',
  ];

  static const List<String> _luxuryLevels = [
    'Moderate',
    'Luxury',
    'UltraLuxury',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedMapCategoryProvider);
    final selectedLuxury = ref.watch(selectedMapLuxuryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BorderRadiusTokens.xl),
          topRight: Radius.circular(BorderRadiusTokens.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category Tabs
          ShakeTransition(
            // curve: Curves.easeInOut,
            duration: Duration(milliseconds: 700),
            child: ShopCategoryTabs(
              noTopIndcatorPadding: true,
              categories: _categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                ref.read(selectedMapCategoryProvider.notifier).state = category;
              },
              isLoading: false,
              tabWidth: 90.w,
              containerHeight: 40.h,
              showBottomBorder: false,
              selectedIndicatorColor: colorScheme.primary,
              selectedTextColor: colorScheme.primary,
              unselectedTextColor: colorScheme.onSurfaceVariant,
            ),
          ),

          Gap(Spacing.xs),
          // Luxury Level Row using AppFilterChip
          ShakeTransition(
            // curve: Curves.easeInOut,
            offset: -140,
            // duration: Duration(milliseconds: 700),
            child: SizedBox(
              height: 48.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "All" chip
                  Padding(
                    padding: EdgeInsets.only(right: Spacing.sm.w),
                    child: AppFilterChip(
                      label: 'All',
                      selected: selectedLuxury == null,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedMapLuxuryProvider.notifier).state =
                              null;
                        }
                      },
                      selectedColor: colorScheme.primary,
                      backgroundColor: Colors.transparent,
                      borderWidth: 0.3,
                    ),
                  ),

                  // Luxury level chips
                  ..._luxuryLevels.map((level) {
                    final isSelected = selectedLuxury == level;

                    return Padding(
                      padding: EdgeInsets.only(right: Spacing.sm.w),
                      child: AppFilterChip(
                        label: level,
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedMapLuxuryProvider.notifier).state =
                                level;
                          } else if (!selected && isSelected) {
                            ref.read(selectedMapLuxuryProvider.notifier).state =
                                null;
                          }
                        },
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.background,
                        labelColor: colorScheme.onSurface,
                        borderWidth: 0.3,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
