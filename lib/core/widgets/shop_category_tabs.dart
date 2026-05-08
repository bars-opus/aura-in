import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';

/// A universal category tabs widget for shop categories.
///
/// Features:
/// - Horizontal scrolling tabs with underline indicator for selected tab
/// - Loading state support
/// - Disabled state for categories with no shops
/// - Customizable formatting
class ShopCategoryTabs extends ConsumerStatefulWidget {
  /// List of category keys (e.g., ['salon', 'barbershop', ...])
  final List<String> categories;

  /// Currently selected category (null means "All")
  final String? selectedCategory;

  /// Callback when a category is selected
  final Function(String?) onCategorySelected;

  /// Optional map to check which categories have shops (for disabling)
  final Map<String, bool>? hasShopsMap;

  /// Whether the widget is in loading state
  final bool isLoading;

  /// Custom formatter for category names (if null, uses default formatting)
  final String Function(String)? categoryFormatter;

  /// Custom width for each tab
  final double? tabWidth;

  /// Custom height for the tabs container
  final double? containerHeight;

  /// Whether to show a bottom border
  final bool showBottomBorder;

  /// Color for selected tab underline indicator
  final Color? selectedIndicatorColor;

  /// Color for selected text
  final Color? selectedTextColor;

  /// Color for unselected text
  final Color? unselectedTextColor;

  /// Color for disabled text
  final Color? disabledTextColor;

  final bool noTopIndcatorPadding;

  const ShopCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.hasShopsMap,
    this.isLoading = false,
    this.categoryFormatter,
    this.tabWidth,
    this.containerHeight,
    this.showBottomBorder = true,
    this.selectedIndicatorColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.disabledTextColor,
    this.noTopIndcatorPadding = false,
  });

  @override
  ConsumerState<ShopCategoryTabs> createState() => _ShopCategoryTabsState();
}

class _ShopCategoryTabsState extends ConsumerState<ShopCategoryTabs> {
  // Track previous selected category to detect changes
  String? _previousSelectedCategory;

  @override
  void initState() {
    super.initState();
    _previousSelectedCategory = widget.selectedCategory;
  }

  @override
  void didUpdateWidget(ShopCategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Store previous value for animation reference
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _previousSelectedCategory = oldWidget.selectedCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final effectiveContainerHeight = widget.containerHeight ?? 44.h;
    final effectiveTabWidth = widget.tabWidth ?? 90.w;

    return Container(
      height: effectiveContainerHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border:
            widget.showBottomBorder
                ? Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                )
                : null,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: Spacing.sm),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];

          // Determine if this tab is selected
          final isSelected =
              !widget.isLoading &&
              ((category == 'all' && widget.selectedCategory == null) ||
                  (category != 'all' && category == widget.selectedCategory));

          final hasShops =
              widget.isLoading ? true : (widget.hasShopsMap?[category] ?? true);
          final displayName =
              widget.categoryFormatter != null
                  ? widget.categoryFormatter!(category)
                  : _defaultFormatCategoryName(category);

          // Calculate indicator width
          final indicatorWidth =
              (isSelected && hasShops) ? effectiveTabWidth * 0.6 : 0;

          return GestureDetector(
            onTap:
                (!widget.isLoading && hasShops)
                    ? () => widget.onCategorySelected(
                      category == 'all' ? null : category,
                    )
                    : null,
            child: Container(
              width:
                  category == 'all'
                      ? effectiveTabWidth - 30.w
                      : effectiveTabWidth,
              padding: EdgeInsets.only(top: Spacing.sm.h),
              margin: EdgeInsets.only(right: Spacing.sm.w),
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tab text
                  Text(
                    displayName,
                    style: textTheme.labelLarge?.copyWith(
                      color:
                          widget.isLoading
                              ? (widget.disabledTextColor ??
                                  colorScheme.onBackground.withOpacity(0.3))
                              : isSelected
                              ? (widget.selectedTextColor ??
                                  colorScheme.primary)
                              : (widget.unselectedTextColor ??
                                  colorScheme.onBackground.withOpacity(
                                    hasShops ? 0.8 : 0.3,
                                  )),
                      fontWeight:
                          (!widget.isLoading && isSelected && hasShops)
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Animated Underline indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.only(
                      top: widget.noTopIndcatorPadding ? 0 : Spacing.sm.h + 1,
                    ),
                    height: 2.h,
                    width: indicatorWidth.toDouble(),
                    decoration: BoxDecoration(
                      color:
                          (isSelected && hasShops)
                              ? (widget.selectedIndicatorColor ??
                                  colorScheme.primary)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _defaultFormatCategoryName(String category) {
    if (category == 'all') return 'All';
    switch (category) {
      case 'salon':
        return 'Salons';
      case 'barbershop':
        return 'Barbershops';
      case 'spa':
        return 'Spas';
      case 'nail_salon':
        return 'Nail Salons';
      case 'lash_studio':
        return 'Lash Studios';
      case 'waxing':
        return 'Waxing';
      case 'massage':
        return 'Massage';
      case 'makeup':
        return 'Makeup';
      case 'skincare':
        return 'Skincare';
      default:
        return category
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }
}
