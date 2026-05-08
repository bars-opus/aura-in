import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// A universal, animated tab bar widget that can be used anywhere in the app.
///
/// Features:
/// - Works with Riverpod providers OR local state
/// - Animated icon scaling on selection
/// - Animated underline indicator
/// - Customizable colors, sizes, and animations
/// - Supports any number of tabs
///
/// Example usage with Riverpod:
/// ```dart
/// CustomUniversalTabs(
///   tabs: [
///     TabItem(label: 'Shops', icon: Icons.storefront_outlined, selectedIcon: Icons.storefront_rounded),
///     TabItem(label: 'Freelancers', icon: Icons.person_outline, selectedIcon: Icons.person),
///   ],
///   provider: selectedProviderTypeProvider,
///   onTabSelected: (index, value) {
///     // Optional additional logic
///   },
/// )
/// ```
///
/// Example with local state:
/// ```dart
/// CustomUniversalTabs(
///   tabs: myTabs,
///   selectedIndex: _selectedIndex,
///   onIndexChanged: (index) => setState(() => _selectedIndex = index),
/// )
/// ```
class CustomUniversalTabs extends ConsumerStatefulWidget {
  /// List of tabs to display
  final List<TabItem> tabs;

  /// [Option 1] For local state: Currently selected tab index
  final int? selectedIndex;

  /// [Option 1] For local state: Callback when index changes
  final ValueChanged<int>? onIndexChanged;

  /// [Option 2] For Riverpod: Provider that holds the selected value
  final StateProvider<dynamic>? provider;

  /// [Option 2] For Riverpod: Optional custom provider for the selected value type
  final StateProvider<dynamic>? selectedValueProvider;

  /// [Option 3] For custom state management: Callback with selected tab value
  final void Function(int index, dynamic value)? onTabSelected;

  /// Callback when a tab is selected (for additional side effects)
  final void Function(int index, TabItem tab)? onTabTap;

  /// Optional refresh callback when tab changes
  final VoidCallback? onRefreshContent;

  /// Height of the tab bar (default: 80)
  final double height;

  /// Whether to show the underline indicator (default: true)
  final bool showUnderline;

  /// Color of the selected tab text and icon
  final Color? selectedColor;

  /// Color of the unselected tab text and icon
  final Color? unselectedColor;

  /// Color of the underline indicator
  final Color? underlineColor;

  /// Duration of the animation (default: 250ms)
  final Duration animationDuration;

  /// Whether to animate the icon scale (default: true)
  final bool animateIconScale;

  /// Icon size (default: 30)
  final double iconSize;

  /// Font size for labels (default: 12)
  final double fontSize;

  /// Padding at the top of the tab bar
  final EdgeInsetsGeometry? padding;

  /// Whether to show a bottom border (default: true)
  final bool showBottomBorder;

  /// Background color of the tab bar
  final Color? backgroundColor;

  /// Whether to show the tab labels (default: true)
  final bool showLabels;

  const CustomUniversalTabs({
    super.key,
    required this.tabs,
    // Option 1: Local state
    this.selectedIndex,
    this.onIndexChanged,
    // Option 2: Riverpod
    this.provider,
    this.selectedValueProvider,
    // Option 3: Custom callback
    this.onTabSelected,
    // Optional
    this.onTabTap,
    this.onRefreshContent,
    this.height = 80,
    this.showUnderline = true,
    this.selectedColor,
    this.unselectedColor,
    this.underlineColor,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animateIconScale = true,
    this.iconSize = 30,
    this.fontSize = 12,
    this.padding,
    this.showBottomBorder = true,
    this.backgroundColor,
    this.showLabels = true,
  }) : assert(
         (selectedIndex != null && onIndexChanged != null) ||
             provider != null ||
             onTabSelected != null,
         'Either provide (selectedIndex + onIndexChanged), provider, or onTabSelected',
       );

  @override
  ConsumerState<CustomUniversalTabs> createState() =>
      _CustomUniversalTabsState();
}

class _CustomUniversalTabsState extends ConsumerState<CustomUniversalTabs>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<double> _scales;
  int _internalSelectedIndex = 0;
  bool _isInitialized = false;

  /// Get the current selected index
  int get _selectedIndex {
    // Priority: Provider > External selectedIndex > Internal
    if (widget.provider != null) {
      final selectedValue = ref.watch(widget.provider!);
      final index = widget.tabs.indexWhere((tab) => tab.value == selectedValue);
      return index >= 0 ? index : 0;
    }
    if (widget.selectedIndex != null) {
      return widget.selectedIndex!;
    }
    return _internalSelectedIndex;
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
  }

  void _initializeAnimationControllers() {
    _animationControllers = List.generate(
      widget.tabs.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      )..addListener(_handleAnimationUpdate),
    );
    _scales = List.filled(widget.tabs.length, 0.8);
  }

  void _handleAnimationUpdate() {
    if (mounted) {
      for (int i = 0; i < _animationControllers.length; i++) {
        _scales[i] = _animationControllers[i].value;
      }
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(CustomUniversalTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIndex = oldWidget.selectedIndex ?? _internalSelectedIndex;
    final newIndex = _selectedIndex;

    if (oldIndex != newIndex) {
      if (oldIndex < _animationControllers.length) {
        _animationControllers[oldIndex]?.reverse();
      }
      if (newIndex < _animationControllers.length) {
        _animationControllers[newIndex]?.forward();
      }
    }
  }

  void _handleTabSelected(int index) {
    final tab = widget.tabs[index];

    // Animate the tab
    if (index < _animationControllers.length) {
      _animationControllers[index].forward();
    }

    // Option 1: Local state
    if (widget.selectedIndex != null && widget.onIndexChanged != null) {
      widget.onIndexChanged!(index);
    }

    // Option 2: Riverpod provider
    if (widget.provider != null && tab.value != null) {
      ref.read(widget.provider!.notifier).state = tab.value;
      widget.onRefreshContent?.call();
    }

    // Option 3: Custom callback
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(index, tab.value);
    }

    // Always call onTabTap if provided
    widget.onTabTap?.call(index, tab);

    // Update internal state if needed
    if (widget.selectedIndex == null && widget.provider == null) {
      setState(() {
        _internalSelectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectedColor = widget.selectedColor ?? colorScheme.primary;
    final unselectedColor =
        widget.unselectedColor ?? colorScheme.onSurface.withOpacity(0.6);
    final underlineColor = widget.underlineColor ?? colorScheme.primary;

    final tabWidth = MediaQuery.of(context).size.width / widget.tabs.length;

    return Container(
      height: widget.height.h,
      padding: widget.padding ?? EdgeInsets.only(top: Spacing.md),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.tabs.length, (index) {
          final tab = widget.tabs[index];
          final isSelected = index == _selectedIndex;
          final scale =
              widget.animateIconScale
                  ? (_scales.isNotEmpty
                      ? _scales[index]
                      : (isSelected ? 1.0 : 0.8))
                  : 1.0;

          return GestureDetector(
            onTap: () => _handleTabSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: tabWidth,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with optional scale animation
                  widget.animateIconScale
                      ? Transform.scale(
                        scale: isSelected ? scale : 0.9,
                        child: AnimatedContainer(
                          duration: widget.animationDuration,
                          curve: Curves.easeInOut,
                          child: Icon(
                            isSelected
                                ? (tab.selectedIcon ?? tab.icon)
                                : tab.icon,
                            color: isSelected ? selectedColor : unselectedColor,
                            size: widget.iconSize.sp,
                          ),
                        ),
                      )
                      : AnimatedContainer(
                        duration: widget.animationDuration,
                        curve: Curves.easeInOut,
                        child: Icon(
                          isSelected
                              ? (tab.selectedIcon ?? tab.icon)
                              : tab.icon,
                          color: isSelected ? selectedColor : unselectedColor,
                          size: widget.iconSize.sp,
                        ),
                      ),
                  if (widget.showLabels) ...[
                    Gap(Spacing.xs.h),
                    // Label
                    Text(
                      tab.label,
                      style: textTheme.labelMedium?.copyWith(
                        color: isSelected ? selectedColor : unselectedColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: widget.fontSize.sp,
                      ),
                    ),
                  ],
                  // Animated Underline indicator
                  if (widget.showUnderline) ...[
                    Gap(Spacing.sm),
                    AnimatedContainer(
                      duration: widget.animationDuration,
                      curve: Curves.easeInOut,
                      height: 1.5.h,
                      width: isSelected ? 40.w : 0,
                      decoration: BoxDecoration(
                        color: isSelected ? underlineColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(1.r),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Enhanced TabItem with optional value for provider support
class TabItem {
  /// The label text displayed below the icon
  final String label;

  /// The icon displayed when the tab is not selected
  final IconData icon;

  /// Optional different icon when the tab is selected (defaults to [icon])
  final IconData? selectedIcon;

  /// Optional value to use with Riverpod providers
  final dynamic value;

  /// Optional custom widget for the tab content (not used by the tabs bar itself)
  final Widget? content;

  const TabItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.value,
    this.content,
  });
}
