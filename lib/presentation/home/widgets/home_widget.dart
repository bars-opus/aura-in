// lib/core/widgets/home_widget.dart
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_packages.dart';
import 'package:nano_embryo/presentation/home/widgets/home_tab.dart';

/// Simple, scalable home widget with bottom navigation
/// Supports 2-5 tabs with minimal, clean implementation
class HomeWidget extends StatefulWidget {
  final List<HomeTab> tabs;
  final int initialTabIndex;
  final Color? backgroundColor;
  final Color? navigationBarColor;
  final double? navigationBarHeight;
  final double? iconSize;
  final double? activeIconSize;
  final bool showLabels;
  final double? centeredFabMarginBottom;

  const HomeWidget({
    super.key,
    required this.tabs,
    this.initialTabIndex = 0,
    this.backgroundColor,
    this.navigationBarColor,
    this.navigationBarHeight,
    this.iconSize,
    this.activeIconSize,
    this.showLabels = true,
    this.centeredFabMarginBottom,
  }) : assert(
         tabs.length >= 2 && tabs.length <= 5,
         'HomeWidget supports 2-5 tabs',
       ),
       assert(
         initialTabIndex >= 0 && initialTabIndex < tabs.length,
         'Invalid initial tab index',
       );

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late int _currentIndex;
  late final Set<int> _visitedIndices;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _visitedIndices = {widget.initialTabIndex};
  }

  Widget _buildBottomNavigationBarWithCustomFab(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= Breakpoints.tablet;

    // Responsive sizing
    final navBarHeight =
        widget.navigationBarHeight ?? (isWideScreen ? 72.h : 64.h);
    final iconSize = widget.iconSize ?? (isWideScreen ? 26.h : 22.h);
    final activeIconSize =
        widget.activeIconSize ?? (isWideScreen ? 28.h : 24.h);

    // Calculate total height including safe area
    final totalHeight = navBarHeight + MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // Bottom Navigation Bar Background
        Container(
          height: totalHeight,
          decoration: BoxDecoration(
            color: widget.navigationBarColor ?? colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withOpacity(0.1),
                width: BorderWidthTokens.hairline,
              ),
            ),
          ),
        ),

        // Navigation Items
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: MediaQuery.of(context).padding.bottom,
          child: Row(
            children: List.generate(widget.tabs.length, (index) {
              final tab = widget.tabs[index];
              final isActive = index == _currentIndex;

              return _buildTabItem(
                context,
                tab: tab,
                isActive: isActive,
                iconSize: iconSize,
                activeIconSize: activeIconSize,
                colorScheme: colorScheme,
                textTheme: textTheme,
                onTap: () => setState(() {
                  _visitedIndices.add(index);
                  _currentIndex = index;
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? colorScheme.background,
      body: Stack(
        children: List.generate(widget.tabs.length, (index) {
          if (!_visitedIndices.contains(index)) return const SizedBox.shrink();
          return Offstage(
            offstage: index != _currentIndex,
            child: widget.tabs[index].screen,
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNavigationBarWithCustomFab(
        context,
        colorScheme,
        textTheme,
      ), // UPDATED
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required HomeTab tab,
    required bool isActive,
    required double iconSize,
    required double activeIconSize,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    final iconColor =
        isActive
            ? (tab.activeIconColor ?? colorScheme.primary)
            : (tab.iconColor ?? colorScheme.onSurface.withOpacity(0.6));

    final labelColor =
        isActive
            ? (tab.activeLabelColor ?? colorScheme.primary)
            : (tab.labelColor ?? colorScheme.onSurface.withOpacity(0.6));

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional unread badge
              Badge(
                isLabelVisible: tab.badgeCount > 0,
                label: Text(
                  tab.badgeCount > 99 ? '99+' : tab.badgeCount.toString(),
                  style: TextStyle(fontSize: 9.sp),
                ),
                child: Icon(
                  isActive ? (tab.activeIcon ?? tab.icon) : tab.icon,
                  size: isActive ? activeIconSize : iconSize,
                  color: iconColor,
                ),
              ),

              // Label
              if (widget.showLabels) ...[
                Gap(Spacing.xs.h),
                Text(
                  tab.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontSize: 10.sp,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
