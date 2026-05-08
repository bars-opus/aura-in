import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// Complete Tabs with Content Switcher
/// Complete Tabs with Content Switcher - Now with NestedScrollView option

class TabsWithContent extends StatefulWidget {
  final List<AppTabItem> tabs;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;
  final AppTabsStyle style;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool scrollable;
  final double contentSpacing;
  final bool showContent;
  final bool useNestedScrollMode;
  // final VoidCallback? onDonePressed;
  final Color? scaffoldBackgroundColor;
  final bool showCloseIcon;
  final String? appBartext;
  final String? headertext;

  final double? tabHeight;
  final VoidCallback? appBarOnPressed;
  final void Function(TabController)? onControllerCreated;
  final bool Function(int fromIndex, int toIndex)? onTabChangeRequest;

  final bool enableSwipe;

  const TabsWithContent({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.style = const AppTabsStyle(),
    this.padding,
    this.backgroundColor,
    this.scrollable = true,
    this.showCloseIcon = false,
    this.contentSpacing = Spacing.lg,
    this.showContent = true,
    this.useNestedScrollMode = false,
    // this.onDonePressed,
    this.scaffoldBackgroundColor,
    this.appBartext,
    this.appBarOnPressed,
    this.enableSwipe = true,
    this.onControllerCreated,
    this.onTabChangeRequest,
    this.tabHeight,
    this.headertext,
  });

  @override
  State<TabsWithContent> createState() => _TabsWithContentState();
}

class _TabsWithContentState extends State<TabsWithContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: _currentIndex,
    );

    // Listen to tab controller changes
    _tabController.addListener(() {
      if (_tabController.index != _currentIndex && mounted) {
        setState(() => _currentIndex = _tabController.index);
        widget.onTabChanged?.call(_tabController.index);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call onControllerCreated AFTER build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onControllerCreated?.call(_tabController);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSwipeableContent() {
    if (!widget.showContent) return const SizedBox.shrink();

    return Expanded(
      child: TabBarView(
        controller: _tabController,
        // ✅ Control swipe with parameter
        physics:
            widget.enableSwipe
                ? const AlwaysScrollableScrollPhysics() // Allows swipe
                : const NeverScrollableScrollPhysics(), // Disables swipe
        children:
            widget.tabs.map((tab) => tab.content ?? const SizedBox()).toList(),
      ),
    );
  }

  Widget _buildTabBarWithInterceptor() {
    return SimpleTabs(
      tabHeight: widget.tabHeight,
      tabs: widget.tabs,
      controller: _tabController, // Pass the controller
      style: widget.style,
      padding: widget.padding,
      backgroundColor: widget.backgroundColor,
      scrollable: widget.scrollable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Regular mode with swipe
    if (!widget.useNestedScrollMode) {
      return Column(
        children: [
          _buildTabBarWithInterceptor(),
          if (widget.showContent) ...[
            // SizedBox(height: widget.contentSpacing.h),
            _buildSwipeableContent(),
          ],
        ],
      );
    }

    // NestedScrollView mode with swipe
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Top content as SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment:
                  widget.showCloseIcon || widget.headertext != null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
              children: [
                if (widget.headertext != null)
                  Text(
                    widget.headertext!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),

                if (widget.showCloseIcon)
                  AppIconButton(
                    icon: Icons.close,
                    onPressed: () => Navigator.pop(context),
                  ),
                AppTextButton(
                  text: widget.appBartext ?? 'Done',
                  onPressed: widget.appBarOnPressed,
                ),
              ],
            ),
          ),

          // Tab bar in its own sliver so SimpleTabs is measured with a
          // min-size Column — avoiding the infinite-height assertion that
          // occurs when a Flex(mainAxisSize: max) is a non-flexible child
          // of another Column with unbounded height.
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Gap(20.h),
                SimpleTabs(
                  tabHeight: widget.tabHeight,
                  tabs: widget.tabs,
                  controller: _tabController,
                  style: widget.style,
                  padding: widget.padding,
                  backgroundColor: widget.backgroundColor,
                  scrollable: widget.scrollable,
                  onTabTap:
                      widget.onTabChangeRequest != null
                          ? (index) {
                            final fromIndex = _currentIndex;
                            final toIndex = index;
                            if (fromIndex == toIndex) return true;
                            final allowChange = widget.onTabChangeRequest!(
                              fromIndex,
                              toIndex,
                            );
                            if (allowChange) _tabController.animateTo(toIndex);
                            return allowChange;
                          }
                          : null,
                ),
                if (widget.showContent)
                  SizedBox(height: widget.contentSpacing.h),
              ],
            ),
          ),

          // Tab content fills whatever remains — no Expanded wrapper needed
          // because SliverFillRemaining provides the height constraint directly.
          if (widget.showContent)
            SliverFillRemaining(
              hasScrollBody: true,
              child: TabBarView(
                controller: _tabController,
                physics: widget.enableSwipe
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                children: widget.tabs
                    .map((tab) => tab.content ?? const SizedBox())
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
