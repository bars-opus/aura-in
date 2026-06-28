// lib/features/settings/screens/settings_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/presentation/widgets/shop_schedule_hub.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/edit_shop_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/owner_dashboard_screen.dart';

/// The "More" or "Settings" screen displaying user preferences and app configurations.
///
/// This screen serves as a centralized hub for user settings, preferences, and
/// additional app functionality beyond the main navigation tabs. It organizes
/// settings into logical sections with appropriate visual grouping and provides
/// a clean, scrollable interface for accessing various app configurations.
///
/// ## Screen Structure
/// ```
/// ┌─────────────────────────────────────┐
/// │           Transparent AppBar        │
/// │  [Title]                [Done Button] │
/// ├─────────────────────────────────────┤
/// │                                     │
/// │        CustomScrollView             │
/// │                                     │
/// │  ┌─────────────────────────────┐   │
/// │  │     Section 1 (CardInkWell) │   │
/// │  │  ┌───────────────────────┐  │   │
/// │  │  │   SettingsItem        │  │   │
/// │  │  ├───────────────────────┤  │   │
/// │  │  │   SettingsItem        │  │   │
/// │  │  └───────────────────────┘  │   │
/// │  └─────────────────────────────┘   │
/// │                                     │
/// │  ┌─────────────────────────────┐   │
/// │  │     Section 2 (CardInkWell) │   │
/// │  │  ┌───────────────────────┐  │   │
/// │  │  │   SettingsItem        │  │   │
/// │  │  └───────────────────────┘  │   │
/// │  └─────────────────────────────┘   │
/// │                                     │
/// │               ...                   │
/// │                                     │
/// └─────────────────────────────────────┘
/// ```
///
/// ## Key Design Decisions
/// 1. **Transparent AppBar**: Creates a seamless look with the content
/// 2. **CustomScrollView with Slivers**: Enables smooth scrolling and efficient
///    rendering of multiple sections
/// 3. **CardInkWell grouping**: Each settings section is wrapped in a tappable
///    card for visual grouping (though tap is currently empty)
/// 4. **Section-based organization**: Settings are logically grouped by function
/// 5. **Done button**: Uses `AppTextButton` with default "Done" label for modal completion
///
/// ## Usage Context
/// This screen is typically accessed from:
/// - Bottom navigation tab labeled "More" or "Settings"
/// - Profile screen overflow menu
/// - Modal presentation for preference editing
///
/// ## Data Flow
/// Settings data is sourced from `ProfileMoreData.getSettingsSections(context)`,
/// which should return a structured list of settings sections and items appropriate
/// for the current context (user role, feature flags, etc.).
///
/// ## Example Extension Points
/// ```dart
/// // 1. Add pull-to-refresh
/// RefreshIndicator(
///   onRefresh: _refreshSettings,
///   child: CustomScrollView(...),
/// )
///
/// // 2. Add section headers
/// SliverToBoxAdapter(
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold)),
///   ),
/// )
///
/// // 3. Implement section tap actions
/// CardInkWell(
///   onTap: () => _expandCollapseSection(section.id),
///   child: ...
/// )
/// ```
class MoreScreen extends ConsumerWidget {
  /// Creates a More/Settings screen with dynamically loaded settings sections.
  ///
  /// The screen structure is fixed, but content is dynamically loaded from
  /// `ProfileMoreData.getSettingsSections` to support different user contexts,
  /// feature flags, or localization requirements.

  final ModerationTarget? moderationTarget;

  /// Public web URL for the entity, used by Share / Copy / Send. When null,
  /// those actions fall back to the app's home URL (e.g. profiles and
  /// freelancers have no dedicated web page). Callers that have a real
  /// destination (a shop with a booking/products slug) should pass it.
  final String? shareUrl;

  const MoreScreen({super.key, this.moderationTarget, this.shareUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Retrieve structured settings data for the current context
    // This method should handle localization, feature flags, and user permissions
    final sections = ProfileMoreData.getSettingsSections(
      context,
      moderationTarget: moderationTarget,
      shareUrl: shareUrl,
    );

    return Scaffold(
      // AppBar with minimal styling for clean interface
      appBar: AppBar(
        // Transparent background for seamless integration with content
        backgroundColor: Colors.transparent,
        // Hide back button - this is typically a root screen or modal completion
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: AppIconButton(
          icon: Icons.close,
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // "Done" button for modal contexts (uses default AppTextButton behavior)
      ),
      // Body uses CustomScrollView for efficient rendering of multiple sections
      body: CustomScrollView(
        slivers: [
         
          // Dynamically generate sliver lists for each settings section
          // Using spread operator (...) to flatten the list of SliverList widgets
          ...sections.map((section) {
            return SliverList(
              delegate: SliverChildListDelegate([
                // Each section is wrapped in a CardInkWell for visual grouping
                CardInkWell(
                  // Bottom margin separates sections visually
                  margin: EdgeInsets.only(bottom: 10.h),
                  elevation: .5,

                  // Currently empty - could expand/collapse or navigate
                  child: Column(
                    // Generate SettingsItem widgets for each item in the section
                    children:
                        section.items
                            .map(
                              (item) => SettingsItem(
                                // showDivider:false,
                                config: item,
                                // Show dividers between items, but not after the last one
                                showDivider: false,
                              ),
                            )
                            .toList(),
                  ),
                ),
              ]),
            );
          }),
          // Additional slivers could be added here:
          // - SliverToBoxAdapter for headers/footers
          // - SliverPadding for additional spacing
          // - SliverAppBar for sticky headers
        ],
      ),
    );
  }
}
