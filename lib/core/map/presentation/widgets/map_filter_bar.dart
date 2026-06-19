import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';
import 'package:nano_embryo/core/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/core/utils/animations/shake_transition.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/core/widgets/feedback/error_state.dart';
import 'package:nano_embryo/core/widgets/horizontal_category_tabs.dart';

/// Filter bar for the engine — primary tabs above, optional secondary
/// chip row below. Layout is fixed; values come from
/// `MapConfig.filterSchema`. The chip row hides entirely if
/// `secondaryFilterKey` is `null`.
///
/// Error state: replaces filter bar content entirely with [ErrorStateWidget].
/// Empty state: appends [EmptyStateWidget] below the chip row.
class MapFilterBar extends ConsumerWidget {
  const MapFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(mapConfigProvider);
    final mapState = ref.watch(mapControllerProvider);
    final schema = config.filterSchema;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
      margin: EdgeInsets.symmetric(horizontal: Spacing.lg.h),

      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(BorderRadiusTokens.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: _buildContent(context, ref, mapState, config, schema),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MapState mapState,
    MapConfig config,
    MapFilterSchema schema,
  ) {
    // Error state: replace content entirely.
    if (mapState.error != null) {
      return Padding(
        padding: EdgeInsets.all(Spacing.md.w),
        child: ErrorStateWidget(
          subtitle: mapState.error,
          onPrimaryAction: () {
            final controller = ref.read(mapControllerProvider.notifier);
            controller.clearError();
            controller.refreshForCurrentViewport(ref.read(mapFiltersProvider));
          },
        ),
      );
    }

    // Empty state: tabs + chips + empty widget below.
    final showEmpty =
        !mapState.isLoading && !mapState.isFetching && mapState.pins.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPrimaryTabs(context, ref, config, schema),
        if (schema.secondaryFilterKey != null) ...[
          Gap(Spacing.xs),
          _buildSecondaryChips(context, ref, schema),
        ],
        if (showEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.md.h,
            ),
            child: EmptyStateWidget(
              icon: Icons.map_outlined,
              subtitle: config.copy.emptyStateSubtitle,
              actionLabel: config.copy.errorRetryLabel,
              onAction: () {
                ref
                    .read(mapControllerProvider.notifier)
                    .refreshForCurrentViewport(ref.read(mapFiltersProvider));
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPrimaryTabs(
    BuildContext context,
    WidgetRef ref,
    MapConfig config,
    MapFilterSchema schema,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final selectedPrimary = ref.watch(selectedPrimaryFilterProvider);

    final primaryEntries = <FilterOption>[
      if (schema.primaryAllOption != null) schema.primaryAllOption!,
      ...schema.primaryTabs,
    ];
    final primaryLabels =
        primaryEntries.map((e) => _getLocalizedLabel(e.value, loc)).toList();
    final selectedPrimaryLabel =
        selectedPrimary != null
            ? _getLocalizedLabel(selectedPrimary.value, loc)
            : _getLocalizedLabel(schema.primaryAllOption?.value ?? 'all', loc);

    return ShakeTransition(
      duration: const Duration(milliseconds: 700),
      child: HorizontalCategoryTabs(
        categories: primaryLabels,
        selectedCategory: selectedPrimaryLabel,
        onCategorySelected: (label) {
          final picked = primaryEntries.firstWhere(
            (e) => _getLocalizedLabel(e.value, loc) == label,
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
    );
  }

  Widget _buildSecondaryChips(
    BuildContext context,
    WidgetRef ref,
    MapFilterSchema schema,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final selectedSecondary = ref.watch(selectedSecondaryFilterProvider);

    return ShakeTransition(
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
                  label: _getLocalizedLabel(
                    schema.secondaryAllOption!.value,
                    loc,
                  ),
                  selected: selectedSecondary == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(selectedSecondaryFilterProvider.notifier).state =
                          null;
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
                  label: _getLocalizedLabel(opt.value, loc),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(selectedSecondaryFilterProvider.notifier).state =
                        selected ? opt : null;
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
    );
  }

  String _getLocalizedLabel(String value, AppLocalizations loc) {
    if (value == 'all') return loc.categoriesAll;
    switch (value) {
      case 'salon':
        return loc.categoriesSalon;
      case 'barbershop':
        return loc.categoriesBarbershop;
      case 'spa':
        return loc.categoriesSpa;
      case 'nail_salon':
        return loc.categoriesNailSalon;
      case 'lash_studio':
        return loc.categoriesLashStudio;
      case 'waxing':
        return loc.categoriesWaxing;
      case 'massage':
        return loc.categoriesMassage;
      case 'Moderate':
        return loc.luxuryLevelModerate;
      case 'Luxury':
        return loc.luxuryLevelLuxury;
      case 'UltraLuxury':
        return loc.luxuryLevelUltraLuxury;
      default:
        return value;
    }
  }
}
