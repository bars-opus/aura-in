import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';
import 'package:nano_embryo/core/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/core/utils/animations/shake_transition.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';
import 'package:nano_embryo/core/widgets/horizontal_category_tabs.dart';

/// Compact map filter surface. Primary categories remain immediately
/// available; optional secondary filters live in a bounded bottom sheet so
/// the map keeps enough room for browsing on small screens.
class MapFilterBar extends ConsumerWidget {
  const MapFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(mapConfigProvider);
    final mapState = ref.watch(mapControllerProvider);
    final schema = config.filterSchema;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: Spacing.lg.w),
      padding: EdgeInsets.only(bottom: Spacing.md.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(BorderRadiusTokens.floatingNav.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: BorderWidthTokens.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: ElevationTokens.lg.r,
            offset: Offset(0, ElevationTokens.xs.h),
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
    final showEmpty =
        !mapState.isLoading && !mapState.isFetching && mapState.pins.isEmpty;
    final showInitialLoading = mapState.isLoading && mapState.pins.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Gap(Spacing.sm),
        Row(
          children: [
            Expanded(child: _buildPrimaryTabs(context, ref, schema)),
            if (schema.secondaryFilterKey != null)
              Padding(
                padding: EdgeInsets.only(right: Spacing.sm.w),
                child:
                    mapState.isLoading || mapState.isFetching
                        ? Padding(
                          padding: EdgeInsets.only(right: Spacing.sm.w),
                          child: const CircularLoadingIndicator(),
                        )
                        : _buildSecondaryFilterButton(
                          context,
                          ref,
                          config,
                          schema,
                        ),
              ),
          ],
        ),

        if (mapState.error != null)
          _buildStatusRow(
            context,
            icon: Icons.cloud_off_outlined,
            message: config.copy.mapLoadErrorLabel,
            actionLabel: config.copy.errorRetryLabel,
            onAction: () => _retry(ref, config),
          )
        else if (showEmpty)
          _buildStatusRow(
            context,
            icon: Icons.location_searching_outlined,
            message: config.copy.emptyStateSubtitle,
            actionLabel: config.copy.errorRetryLabel,
            onAction: () => _retry(ref, config),
          )
        else if (showInitialLoading)
          Padding(
            padding: EdgeInsets.fromLTRB(
              Spacing.md.w,
              Spacing.xs.h,
              Spacing.md.w,
              Spacing.sm.h,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                config.copy.loadingLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
      ],
    );
  }

  void _retry(WidgetRef ref, MapConfig config) {
    final controller = ref.read(mapControllerProvider.notifier);
    controller.clearError();
    controller.refresh(
      ref.read(mapFiltersProvider),
      radiusKm: config.defaultRadiusKm,
    );
  }

  Widget _buildStatusRow(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md.w,
        Spacing.xs.h,
        Spacing.sm.w,
        Spacing.sm.h,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: colorScheme.onSurfaceVariant),
          Gap(Spacing.sm.w),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }

  Widget _buildPrimaryTabs(
    BuildContext context,
    WidgetRef ref,
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

  Widget _buildSecondaryFilterButton(
    BuildContext context,
    WidgetRef ref,
    MapConfig config,
    MapFilterSchema schema,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedSecondary = ref.watch(selectedSecondaryFilterProvider);

    return Badge(
      isLabelVisible: selectedSecondary != null,
      label: const Text('1'),
      child: IconButton(
        tooltip: config.copy.filtersLabel,
        onPressed: () async {
          BottomSheetUtils.showDocumentationBottomSheet(
            context: context,
            maxHeight: 200,

            widget: Consumer(
              builder: (context, sheetRef, _) {
                final colorScheme = Theme.of(context).colorScheme;
                final loc = AppLocalizations.of(context)!;
                final selected = sheetRef.watch(
                  selectedSecondaryFilterProvider,
                );
                final options = <FilterOption>[
                  if (schema.secondaryAllOption != null)
                    schema.secondaryAllOption!,
                  ...schema.secondaryChips,
                ];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.copy.filtersLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Gap(Spacing.md.h),
                    Wrap(
                      spacing: Spacing.sm.w,
                      runSpacing: Spacing.sm.h,
                      children:
                          options.map((option) {
                            final isAll = option == schema.secondaryAllOption;
                            final isSelected =
                                isAll ? selected == null : selected == option;
                            return AppFilterChip(
                              label: _getLocalizedLabel(option.value, loc),
                              selected: isSelected,
                              onSelected: (_) {
                                sheetRef
                                    .read(
                                      selectedSecondaryFilterProvider.notifier,
                                    )
                                    .state = isAll ? null : option;
                              },
                              selectedColor: colorScheme.primary,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                            );
                          }).toList(),
                    ),
                  ],
                );
              },
            ),
          );
        },

        // () => _showSecondaryFilters(context, ref, config, schema),
        icon: Icon(
          Icons.tune_rounded,
          color:
              selectedSecondary == null
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.primary,
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
