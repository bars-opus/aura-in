import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';
import 'package:nano_embryo/core/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/core/utils/animations/shake_transition.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';
import 'package:nano_embryo/core/widgets/horizontal_category_tabs.dart';

/// Filter bar for the engine — primary tabs above, optional secondary
/// chip row below. Layout is fixed; values come from
/// `MapConfig.filterSchema`. The chip row hides entirely if
/// `secondaryFilterKey` is `null`.
class MapFilterBar extends ConsumerWidget {
  const MapFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(mapConfigProvider);
    final schema = config.filterSchema;
    final selectedPrimary = ref.watch(selectedPrimaryFilterProvider);
    final selectedSecondary = ref.watch(selectedSecondaryFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final primaryEntries = <FilterOption>[
      if (schema.primaryAllOption != null) schema.primaryAllOption!,
      ...schema.primaryTabs,
    ];
    final primaryLabels = primaryEntries.map((e) => e.label).toList();
    final selectedPrimaryLabel =
        selectedPrimary?.label ?? schema.primaryAllOption?.label;

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
          ShakeTransition(
            duration: const Duration(milliseconds: 700),
            child: HorizontalCategoryTabs(
              categories: primaryLabels,
              selectedCategory: selectedPrimaryLabel,
              onCategorySelected: (label) {
                final picked = primaryEntries.firstWhere(
                  (e) => e.label == label,
                  orElse: () => primaryEntries.first,
                );
                ref.read(selectedPrimaryFilterProvider.notifier).state =
                    picked == schema.primaryAllOption ? null : picked;
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

          if (schema.secondaryFilterKey != null) ...[
            Gap(Spacing.xs),
            ShakeTransition(
              offset: -140,
              child: SizedBox(
                height: 48.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (schema.secondaryAllOption != null)
                      Padding(
                        padding: EdgeInsets.only(right: Spacing.sm.w),
                        child: AppFilterChip(
                          label: schema.secondaryAllOption!.label,
                          selected: selectedSecondary == null,
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                  .read(selectedSecondaryFilterProvider.notifier)
                                  .state = null;
                            }
                          },
                          selectedColor: colorScheme.primary,
                          backgroundColor: Colors.transparent,
                          borderWidth: 0.3,
                        ),
                      ),
                    ...schema.secondaryChips.map((opt) {
                      final isSelected = selectedSecondary == opt;
                      return Padding(
                        padding: EdgeInsets.only(right: Spacing.sm.w),
                        child: AppFilterChip(
                          label: opt.label,
                          selected: isSelected,
                          onSelected: (selected) {
                            ref
                                .read(selectedSecondaryFilterProvider.notifier)
                                .state = selected ? opt : null;
                          },
                          selectedColor: colorScheme.primary,
                          backgroundColor: colorScheme.surface,
                          labelColor: colorScheme.onSurface,
                          borderWidth: 0.3,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
