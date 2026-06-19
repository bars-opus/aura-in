// lib/features/shops/presentation/widgets/shop_filter_bottom_sheet.dart

import 'package:flutter/services.dart' show HapticFeedback;
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/luxury_level_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';

class ShopFilterBottomSheet extends ConsumerStatefulWidget {
  final String selectedCategory;
  final String? initialLuxuryLevel;
  final bool initialVerifiedOnly;
  final bool initialSortByRating;
  final double initialRadiusKm;
  final VoidCallback onReset;
  final Function(
    String? luxuryLevel,
    bool verifiedOnly,
    bool sortByRating,
    double radiusKm,
  )
  onApply;

  const ShopFilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.initialLuxuryLevel,
    required this.initialVerifiedOnly,
    required this.initialSortByRating,
    required this.initialRadiusKm,
    required this.onReset,
    required this.onApply,
  });

  @override
  ConsumerState<ShopFilterBottomSheet> createState() =>
      _ShopFilterBottomSheetState();
}

class _ShopFilterBottomSheetState extends ConsumerState<ShopFilterBottomSheet> {
  late String? _selectedLuxuryLevel;
  late bool _verifiedOnly;
  late bool _sortByRating;
  late double _radiusKm;

  @override
  void initState() {
    super.initState();
    _selectedLuxuryLevel = widget.initialLuxuryLevel;
    _verifiedOnly = widget.initialVerifiedOnly;
    _sortByRating = widget.initialSortByRating;
    _radiusKm = widget.initialRadiusKm;
  }

  void _handleReset() {
    setState(() {
      _selectedLuxuryLevel = null;
      _verifiedOnly = false;
      _sortByRating = true;
      _radiusKm = kSearchRadiusDefaultKm;
    });
    widget.onReset();
  }

  void _handleApply() {
    widget.onApply(
      _selectedLuxuryLevel,
      _verifiedOnly,
      _sortByRating,
      _radiusKm,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get luxury levels with counts for this category
    final luxuryAsync = ref.watch(
      luxuryLevelListProvider(shopType: widget.selectedCategory),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          AppTextButton(text: 'Apply',onPressed: _handleApply, ),
        // BottomSheetHeader(title: 'Filter & Sort'),
        Gap(Spacing.md.h),
        // Sort Options Section
        CardInkWell(
          onTap: () {},
        
          child: Column(
            children: [
              InfoRowWidget(
                subtitle: '',
                title: 'Rating (highest first)',
                icon: Icons.star,
                iconColor:
                    !_sortByRating
                        ? colorScheme.onBackground.withOpacity(.5)
                        : null,
                avatarRadius: 25.h,
                onTap: () {},
                showAvatar: false,
                showDivider: false,
                showTrailingArrow: false,
                trailing: AppToggleSwitch(
                  toggleValue: _sortByRating,
                  onToggleChanged: (value) {
                    setState(() {
                      _sortByRating = value;
                    });
                  },
                ),
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Rating (highest first)', style: textTheme.bodyMedium),
              //     Switch(
              //       value: _sortByRating,
              //       onChanged: (value) {
              //         setState(() {
              //           _sortByRating = value;
              //         });
              //       },
              //       activeColor: colorScheme.primary,
              //     ),
              //   ],
              // ),
              InfoRowWidget(
                subtitle: '',
                title: 'Verified only',
                icon: Icons.check_circle,
                iconColor:
                    !_verifiedOnly
                        ? colorScheme.onBackground.withOpacity(.5)
                        : null,
                avatarRadius: 25.h,
                onTap: () {},
                showAvatar: false,
                showTrailingArrow: false,
                showDivider: false,
                trailing: AppToggleSwitch(
                  toggleValue: _verifiedOnly,
                  onToggleChanged: (value) {
                    setState(() {
                      _verifiedOnly = value;
                    });
                  },
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Verified only', style: textTheme.bodyMedium),
              //     Switch(
              //       value: _verifiedOnly,
              //       onChanged: (value) {
              //         setState(() {
              //           _verifiedOnly = value;
              //         });
              //       },
              //       activeColor: colorScheme.primary,
              //     ),
              //   ],
              // ),
              // Gap(20.h),
            ],
          ),
        ),

        // Search radius slider
        CardInkWell(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search radius',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    MiniContainerIndicator(
                      color: colorScheme.primary,
                      text: '${_radiusKm.toInt()} km',
                      fontSize: 16,
                    ),
                  ],
                ),
                Slider(
                  value: _radiusKm,
                  min: kSearchRadiusMinKm,
                  max: kSearchRadiusMaxKm,
                  divisions:
                      (kSearchRadiusMaxKm - kSearchRadiusMinKm).toInt(),
                  label: '${_radiusKm.toInt()} km',
                  onChanged: (value) {
                    if (value.toInt() != _radiusKm.toInt()) {
                      HapticFeedback.selectionClick();
                    }
                    setState(() => _radiusKm = value);
                  },
                  onChangeEnd: (_) => HapticFeedback.lightImpact(),
                ),
                Text(
                  'Showing results within ${_radiusKm.toInt()}km of your location',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Luxury Level Section
        CardInkWell(
          onTap: () {},
          child: luxuryAsync.when(
            data: (luxuryLevels) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.md.w),
                child: SizedBox(
                  width: double.infinity,

                  child: Wrap(
                    spacing: Spacing.sm.w,
                    runSpacing: Spacing.sm.h,
                    children: [
                      // All option chip
                      AppFilterChip(
                        label: 'All',
                        selected: _selectedLuxuryLevel == null,
                        onSelected: (_) {
                          setState(() {
                            _selectedLuxuryLevel = null;
                          });
                        },
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        borderWidth: 0.5,
                      ),
                      // Luxury levels with counts
                      ...luxuryLevels.map(
                        (level) => AppFilterChip(
                          label: '${level.level} (${level.count})',
                          selected: _selectedLuxuryLevel == level.level,
                          onSelected: (_) {
                            setState(() {
                              _selectedLuxuryLevel = level.level;
                            });
                          },
                          selectedColor: colorScheme.primary,
                          backgroundColor: colorScheme.surface,
                          borderWidth: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading:
                () => Padding(
                  padding: EdgeInsets.all(Spacing.md.w),
                  child: const Center(child: CircularLoadingIndicator()),
                ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: AppButton(
                height: 40.h,
                label: 'Reset',
                onPressed: _handleReset,
                padding: Spacing.horizontalMd,
                variant: ButtonVariant.outline,
                size: ButtonSize.small,
                width: double.infinity,
              ),
            ),
            // Expanded(
            //   child: OutlinedButton(
            //     onPressed: _handleReset,
            //     child: const Text('Reset'),
            //   ),
            // ),
            // Gap(Spacing.md.w),
            // Expanded(
            //   child: AppButton(
            //     elevation: 0,
            //     label: 'Apply',
            //     onPressed: _handleApply,
            //     size: ButtonSize.small,
            //     width: double.infinity,
            //     padding: Spacing.horizontalMd,
            //     height: 40.h,
            //   ),
            // ),
            // Expanded(
            //   child: ElevatedButton(
            //     onPressed: _handleApply,
            //     child: const Text('Apply'),
            //   ),
            // ),
          ],
        ),

        Gap(Spacing.lg.h),
      ],
    );
  }
}
