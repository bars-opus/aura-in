// lib/core/widgets/icon_avatar.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// A versatile icon component that can display as either a simple icon or within a circular avatar.
///
/// This widget provides a unified interface for displaying icons across the application,
/// supporting two distinct visual modes with automatic sizing and color coordination.
/// It's commonly used in list items, buttons, and UI elements requiring consistent
/// icon presentation with optional background containers.
///
/// ## Visual Modes
///
/// ### 1. Simple Icon Mode (`showAvatar: false`)
/// Displays a standard Material icon without background decoration.
/// ```
/// [icon] (colored, sized appropriately)
/// ```
///
/// ### 2. Avatar Mode (`showAvatar: true`)
/// Displays an icon centered within a circular container with background color.
/// ```
///   ┌─────────────────┐
///   │                 │
///   │      [icon]     │
///   │                 │
///   └─────────────────┘
/// ```
///
/// ## Key Features
/// - **Dual display modes**: Simple icon or circular avatar container
/// - **Automatic sizing**: Responsive icon sizing based on mode and available space
/// - **Color coordination**: Background color automatically derived from icon color
/// - **Theme integration**: Uses theme color scheme for sensible defaults
/// - **Responsive design**: Uses `ScreenUtil` for consistent scaling across devices
/// - **Proportional scaling**: Avatar icons maintain 80% size relative to container
///
/// ## Sizing Behavior
/// | Mode | Default Size | Description |
/// |------|--------------|-------------|
/// | **Simple Icon** | `24.h` | Standard icon size (24 responsive pixels) |
/// | **Avatar Mode** | `20.h` icon in `20.r` circle | Icon at 80% of container radius |
///
/// ## Color Behavior
/// - **Icon color**: Defaults to theme's primary color
/// - **Background color**: Defaults to primary color with 10% opacity (for subtle contrast)
///
/// ## Usage Examples
/// ```dart
/// // Simple icon (default mode)
/// IconAvatar(
///   icon: Icons.notifications,
///   iconColor: Colors.blue,
///   size: 28,
/// )
///
/// // Circular avatar icon
/// IconAvatar(
///   icon: Icons.person,
///   showAvatar: true,
///   backgroundColor: Colors.blue[50],
///   iconColor: Colors.blue,
///   avatarRadius: 24, // Custom radius
/// )
///
/// // Theme-aware avatar
/// IconAvatar(
///   icon: Icons.settings,
///   showAvatar: true,
///   // Uses theme.primary color for icon, primary.withOpacity(0.1) for background
/// )
///
/// // Compact list item icon
/// IconAvatar(
///   icon: Icons.check_circle,
///   showAvatar: true,
///   size: 16, // Smaller overall size
/// )
/// ```
class IconAvatar extends StatelessWidget {
  /// The Material icon to display.
  ///
  /// Uses Flutter's built-in Material Icons or custom icon fonts.
  /// The icon is displayed in the center when in avatar mode.
  final IconData icon;

  /// Color of the icon.
  ///
  /// Defaults to the theme's primary color (`colorScheme.primary`).
  /// Use custom colors for specific visual emphasis or branding.
  final Color? iconColor;

  /// Background color of the circular avatar (when `showAvatar` is `true`).
  ///
  /// Defaults to primary color with 10% opacity (`colorScheme.primary.withOpacity(0.1)`).
  /// Creates subtle contrast that coordinates with the icon color.
  /// Ignored when `showAvatar` is `false`.
  final Color? backgroundColor;

  /// Overall size control for the component.
  ///
  /// In **simple icon mode**: Directly sets the icon size in logical pixels.
  /// In **avatar mode**: Sets the icon size (circle radius is calculated proportionally).
  /// Defaults to `20.h` for avatar mode, `24.h` for simple icon mode.
  /// Uses `ScreenUtil` for responsive scaling (.h extension).
  final double? size;

  /// Whether to display the icon within a circular avatar container.
  ///
  /// When `true`: Icon appears centered in a circular background.
  /// When `false` (default): Icon displays without background decoration.
  /// This switch dramatically changes the visual appearance and layout behavior.
  final bool showAvatar;

  /// Radius of the circular avatar container (when `showAvatar` is `true`).
  ///
  /// If not provided, defaults to `20.r` (20 responsive pixels).
  /// The icon size inside will be 80% of this radius for balanced proportions.
  /// Uses `ScreenUtil` for responsive scaling (.r extension).
  final double? avatarRadiusSize;
  final double circularRadius;

  /// Creates an icon component with optional circular avatar container.
  ///
  /// [icon] is required. All other parameters have sensible defaults that
  /// integrate with the application's theme and design system.
  ///
  /// The widget adapts its appearance based on the `showAvatar` parameter,
  /// providing two distinct visual modes with appropriate sizing and coloring.
  const IconAvatar({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.showAvatar = false,
    required this.circularRadius,
    this.avatarRadiusSize,
  });

  @override
  Widget build(BuildContext context) {
    // Access theme for consistent styling defaults
    final colorScheme = Theme.of(context).colorScheme;

    // Determine colors with fallbacks to theme values
    final icoColor = iconColor ?? colorScheme.primary;
    final bgColor = backgroundColor ?? colorScheme.primary.withOpacity(0.1);

    // Calculate icon size based on mode and parameters
    final iconSize = size ?? (showAvatar ? 20.h : 24.h);

    // Branch based on display mode
    if (showAvatar) {
      // AVATAR MODE: Icon inside circular container
      final radius = avatarRadiusSize ?? 40.r;

      return Container(
        // Circular container with responsive radius
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(circularRadius),
        ),

        // Icon centered inside, sized proportionally to container
        child: Icon(icon, size: radius * 0.8, color: icoColor),
      );
    } else {
      // SIMPLE ICON MODE: Standard icon without decoration
      return Icon(icon, size: iconSize, color: icoColor);
    }
  }
}
