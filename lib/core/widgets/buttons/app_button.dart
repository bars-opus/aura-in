import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// Universal button widget with multiple variants
/// Supports: Primary, Secondary, Outline, Text, Icon, Loading states

// =============================================================================
// CLASS: AppButton
// =============================================================================
// Purpose: Universal button component with consistent styling across the app
//
// Key Features:
// 1. Theme Integration: Automatically adapts to app's color scheme and text theme
// 2. Multiple Variants: Primary, Secondary, Outline, Text, and Custom styles
// 3. Responsive Sizes: Small, Medium (default), Large, XLarge presets
// 4. State Management: Loading, Disabled, and Normal states
// 5. Icon Support: Optional icons with proper spacing and sizing
// 6. Customizable: Override any styling with custom parameters
//
// Design System Integration:
// - Uses Spacing, BorderRadiusTokens, ElevationTokens from design tokens
// - Responsive sizing with .h, .w, .sp units
// - Automatic light/dark theme adaptation via Theme.of(context)
//
// Best Practices Implemented:
// - Null safety throughout
// - Proper contrast ratios for accessibility
// - Consistent tap target sizes (Material Design)
// - Loading states with appropriate indicators
// =============================================================================
class AppButton extends StatelessWidget {
  /// The text label displayed on the button
  final String label;

  /// Callback function when the button is pressed
  final VoidCallback? onPressed;

  /// Visual style variant of the button
  final ButtonVariant variant;

  /// Size preset for consistent button dimensions
  final ButtonSize size;

  /// Whether to show a loading indicator instead of content
  final bool isLoading;

  /// Whether the button is disabled (non-interactive)
  final bool isDisabled;

  /// Optional custom icon widget
  final Widget? icon;

  /// Optional icon from Material Icons library
  final IconData? iconData;

  /// Custom width override (defaults to full width)
  final double? width;

  /// Custom height override (defaults to size-based height)
  final double? height;

  /// Custom padding override (defaults to size-based padding)
  final EdgeInsetsGeometry? padding;

  /// Custom border radius override (defaults to medium from tokens)
  final BorderRadiusGeometry? borderRadius;

  /// Custom background color override (takes precedence over variant colors)
  final Color? customColor;

  /// Custom text style override (takes precedence over theme styles)
  final TextStyle? customTextStyle;

  /// Custom outlineColor override (takes precedence over variant colors)
  final Color? outlineColor;

  /// Custom textColor override (takes precedence over variant colors)
  final Color? textColor;

  /// Align contents in center override (takes precedence over MainAxisAlignment.start)
  final bool? center;

  /// Icon displayed at the start of the input field.
  ///
  /// Typically used to indicate the type of input expected (e.g., mail icon for email).
  /// Size adapts based on `isSmall` parameter for consistent visual hierarchy.
  final IconData? prefixIcon;

  /// The above code is declaring a variable `prefixIconColor` of type `Color?` in Dart. The `?`
  /// indicates that the variable can be `null`.
  final Color? prefixIconColor;

  final double? elevation;

  /// Main constructor for AppButton
  ///
  /// Required parameters:
  /// - label: Text to display on button
  /// - onPressed: Action when button is tapped
  ///
  /// Optional parameters with sensible defaults:
  /// - variant: ButtonVariant.primary
  /// - size: ButtonSize.medium
  /// - isLoading/isDisabled: false
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconData,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.customColor,
    this.customTextStyle,
    this.outlineColor,
    this.textColor,
    this.center = true,
    this.prefixIcon,
    this.elevation,
    this.prefixIconColor,
  });

  // ===========================================================================
  // BUILD METHOD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    // Extract theme values from current context
    // These automatically update when theme changes (light/dark mode)
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Container that enforces button dimensions
    return AnimatedScaleFade(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      child: SizedBox(
        width: width ?? _getWidth(size),
        height: height ?? _getHeight(size),
        child: _buildButton(context, colorScheme, textTheme),
      ),
    );
  }

  // ===========================================================================
  // PRIVATE HELPER: _buildButton
  // ===========================================================================
  /// Creates the appropriate Material button widget based on variant
  ///
  /// Parameters:
  /// - context: BuildContext for theme access
  /// - colorScheme: Current app color scheme (light/dark)
  /// - textTheme: Current app text theme
  ///
  /// Returns: Either ElevatedButton, OutlinedButton, or TextButton
  Widget _buildButton(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Generate button styling based on variant and theme
    final buttonStyle = _getButtonStyle(colorScheme);
    final textStyle = _getTextStyle(textTheme, colorScheme);
    final content = _buildContent(context, textStyle);

    // Pattern matching to select correct button type
    // This is more readable than if-else chains
    return switch (variant) {
      // Elevated buttons (primary and secondary variants)
      ButtonVariant.primary || ButtonVariant.secondary => ElevatedButton(
        onPressed: _getOnPressed(),
        style: buttonStyle,
        child: content,
      ),

      // Outlined button (border with transparent fill)
      ButtonVariant.outline => OutlinedButton(
        onPressed: _getOnPressed(),
        style: buttonStyle,
        child: content,
      ),

      // Text button (minimal styling, text only)
      ButtonVariant.text => TextButton(
        onPressed: _getOnPressed(),
        style: buttonStyle,
        child: content,
      ),

      // Custom variant (same as primary but allows color override)
      ButtonVariant.custom => ElevatedButton(
        onPressed: _getOnPressed(),
        style: buttonStyle,
        child: content,
      ),
    };
  }

  // ===========================================================================
  // PRIVATE HELPER: _buildContent
  // ===========================================================================
  /// Builds the button's visual content (icon + text or loading indicator)
  ///
  /// Parameters:
  /// - context: BuildContext for theme access
  /// - textStyle: Pre-calculated text styling
  ///
  /// Returns: Loading indicator or icon+text row
  Widget _buildContent(BuildContext context, TextStyle textStyle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Show loading indicator when isLoading is true
    if (isLoading) {
      return CircularLoadingIndicator();
    }

    // Build icon+text row when not loading
    return Padding(
      padding: EdgeInsets.only(left: center == true ? 0 : Spacing.lg),
      child:
          prefixIcon != null
              ? Row(
                children: [
                  Expanded(child: _mainButton(context, textStyle)),
                  prefixIcon != null
                      ? Icon(
                        prefixIcon,
                        // Icon size adapts to field size
                        size: IconSizes.xs.h + 2.h,
                        color:
                            prefixIconColor ??
                            colorScheme.onBackground.withOpacity(0.5),
                      )
                      : SizedBox.shrink(),
                ],
              )
              : _mainButton(context, textStyle),
    );
  }

  _mainButton(BuildContext context, TextStyle textStyle) {
    return Row(
      mainAxisAlignment:
          center == true ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      children: [
        // Custom icon widget (highest priority)
        if (icon != null) ...[
          icon!,
          Gap(Spacing.sm.w), // Consistent spacing from design tokens
        ]
        // Material icon (second priority)
        else if (iconData != null) ...[
          Icon(
            iconData,
            size: _getIconSize(),
            color: textColor ?? _getIconColor(context),
          ),
          Gap(Spacing.sm.w),
        ],

        // Text label (always required)
        Flexible(
          child: Text(
            label,
            style: textStyle,
            textAlign: TextAlign.center,

            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Prevent text overflow
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // STATE MANAGEMENT: _getOnPressed
  // ===========================================================================
  /// Determines if button should be interactive based on state
  ///
  /// Returns: null if button is loading or disabled, otherwise onPressed callback
  /// This disables the button visually and functionally during loading/disabled states
  VoidCallback? _getOnPressed() {
    if (isLoading || isDisabled) return null;
    return onPressed;
  }

  MaterialStateProperty<Color?> _getOverlayColor(ColorScheme colorScheme) {
    return MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) return null;

      // For customColor, use a contrasting color for splash
      if (customColor != null) {
        // Calculate a contrasting color (darker or lighter version)
        final contrastColor = _getContrastColor(customColor!);
        return contrastColor.withOpacity(0.20);
      }

      // Use app's primary color for ripple based on variant
      return switch (variant) {
        ButtonVariant.primary => colorScheme.onPrimary.withOpacity(0.20),
        ButtonVariant.secondary => colorScheme.onSecondary.withOpacity(0.20),
        ButtonVariant.outline => colorScheme.primary.withOpacity(0.20),
        ButtonVariant.text => colorScheme.primary.withOpacity(0.20),
        ButtonVariant.custom => colorScheme.primary.withOpacity(0.20),
      };
    });
  }

  // Helper method to get contrasting color
  Color _getContrastColor(Color baseColor) {
    // Simple contrast calculation - darken or lighten based on brightness
    final brightness = ThemeData.estimateBrightnessForColor(baseColor);

    if (brightness == Brightness.dark) {
      // For dark colors, use a lighter splash
      return Color.lerp(baseColor, Colors.white, 0.3)!;
    } else {
      // For light colors, use a darker splash
      return Color.lerp(baseColor, Colors.black, 0.3)!;
    }
  }

  // ===========================================================================
  // STYLING: _getButtonStyle
  // ===========================================================================
  /// Creates Material ButtonStyle with all visual properties
  ///
  /// Parameters:
  /// - colorScheme: Current app color scheme
  ///
  /// Returns: Complete ButtonStyle for the selected button variant
  ButtonStyle _getButtonStyle(ColorScheme colorScheme) {
    final backgroundColor = _getBackgroundColor(colorScheme);
    final foregroundColor = _getForegroundColor(colorScheme);
    final side = _getBorderSide(colorScheme);
    final overlayColor = _getOverlayColor(colorScheme);

    // Use different styleFrom methods based on variant
    final baseStyle = switch (variant) {
      ButtonVariant.outline => OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        side: side, // This is important for OutlinedButton
        disabledBackgroundColor: colorScheme.surface.withOpacity(0.12),
        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
        padding: padding ?? _getPadding(size),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadiusTokens.mdAll,
        ),
        elevation: elevation ?? _getElevation(),
        shadowColor: colorScheme.shadow,
        surfaceTintColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
      ),
      _ => ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: colorScheme.surface.withOpacity(0.12),
        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
        padding: padding ?? _getPadding(size),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadiusTokens.mdAll,
          side: side,
        ),
        elevation: elevation ?? _getElevation(),
        shadowColor: colorScheme.shadow,
        surfaceTintColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
      ),
    };

    // Merge with overlayColor using copyWith
    return baseStyle.copyWith(overlayColor: overlayColor);
  }

  // ===========================================================================
  // TEXT STYLING: _getTextStyle
  // ===========================================================================
  /// Creates text styling for button label
  ///
  /// Hierarchy: customTextStyle > theme-based style > fallback style
  TextStyle _getTextStyle(TextTheme textTheme, ColorScheme colorScheme) {
    // Base style from theme with size and color applied
    final baseStyle = textTheme.labelLarge?.copyWith(
      fontSize: _getFontSize(),
      color: textColor ?? _getTextColor(colorScheme),
    );

    // Custom style overrides everything, otherwise use theme style
    return customTextStyle ?? baseStyle ?? const TextStyle();
  }

  // ===========================================================================
  // DIMENSION HELPERS
  // ===========================================================================

  /// Returns width based on size preset (defaults to full width)
  double _getWidth(ButtonSize size) => double.infinity;

  /// Returns height based on size preset with responsive units
  double _getHeight(ButtonSize size) {
    return switch (size) {
      ButtonSize.small => 40.h,
      ButtonSize.medium => 56.h,
      ButtonSize.large => 64.h,
      ButtonSize.xlarge => 72.h,
    };
  }

  /// Returns padding based on size preset
  EdgeInsets _getPadding(ButtonSize size) {
    return switch (size) {
      ButtonSize.small => Spacing.allMd,
      ButtonSize.medium => Spacing.allLg,
      ButtonSize.large => EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.lg.h,
      ),
      ButtonSize.xlarge => EdgeInsets.symmetric(
        horizontal: Spacing.xxl.w,
        vertical: Spacing.xl.h,
      ),
    };
  }

  /// Returns font size based on size preset with responsive units
  double _getFontSize() {
    return switch (size) {
      ButtonSize.small => 12.sp,
      ButtonSize.medium => 14.sp,
      ButtonSize.large => 16.sp,
      ButtonSize.xlarge => 18.sp,
    };
  }

  /// Returns icon size based on size preset with responsive units
  double _getIconSize() {
    return switch (size) {
      ButtonSize.small => 16.h,
      ButtonSize.medium => 20.h,
      ButtonSize.large => 24.h,
      ButtonSize.xlarge => 28.h,
    };
  }

  /// Returns elevation based on variant
  double? _getElevation() {
    return switch (variant) {
      ButtonVariant.primary => ElevationTokens.sm,
      ButtonVariant.secondary => ElevationTokens.xs,
      ButtonVariant.outline => ElevationTokens.none,
      ButtonVariant.text => ElevationTokens.none,
      ButtonVariant.custom => ElevationTokens.sm, // Same as primary
    };
  }

  // ===========================================================================
  // COLOR HELPERS
  // ===========================================================================

  /// Returns background color with customColor taking precedence
  Color _getBackgroundColor(ColorScheme colorScheme) {
    // Custom color overrides everything
    if (customColor != null) return customColor!;

    return switch (variant) {
      ButtonVariant.primary => colorScheme.primary,
      ButtonVariant.secondary => colorScheme.secondary,
      ButtonVariant.outline => Colors.transparent,
      ButtonVariant.text => Colors.transparent,
      ButtonVariant.custom => colorScheme.primary, // Default for custom
    };
  }

  /// Returns foreground (ripple) color
  Color _getForegroundColor(ColorScheme colorScheme) {
    if (customColor != null) return customColor!;

    return switch (variant) {
      ButtonVariant.primary => colorScheme.onPrimary,
      ButtonVariant.secondary => colorScheme.onSecondary,
      ButtonVariant.outline => colorScheme.primary,
      ButtonVariant.text => colorScheme.primary,
      ButtonVariant.custom => colorScheme.onPrimary,
    };
  }

  /// Returns text color with automatic contrast for custom backgrounds
  Color _getTextColor(ColorScheme colorScheme) {
    if (customColor != null) {
      final brightness = ThemeData.estimateBrightnessForColor(customColor!);
      return brightness == Brightness.dark ? Colors.white : Colors.black;
    }

    return switch (variant) {
      ButtonVariant.primary => colorScheme.onPrimary,
      ButtonVariant.secondary => colorScheme.onSecondary,
      ButtonVariant.outline => colorScheme.primary, // Text stays primary color
      ButtonVariant.text => colorScheme.primary,
      ButtonVariant.custom => colorScheme.onPrimary,
    };
  }

  /// Returns icon color (same as text color for consistency)
  Color _getIconColor(BuildContext context) {
    return _getTextColor(Theme.of(context).colorScheme);
  }

  /// Returns loading indicator color
  Color _getLoadingColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (variant) {
      ButtonVariant.primary => colorScheme.onPrimary,
      ButtonVariant.secondary => colorScheme.onSecondary,
      ButtonVariant.outline => colorScheme.primary,
      ButtonVariant.text => colorScheme.primary,
      ButtonVariant.custom => colorScheme.onPrimary,
    };
  }

  /// Returns border styling for outlined variant
  BorderSide _getBorderSide(ColorScheme colorScheme) {
    return switch (variant) {
      ButtonVariant.primary => BorderSide.none,
      ButtonVariant.secondary => BorderSide.none,
      ButtonVariant.outline => BorderSide(
        color: outlineColor ?? colorScheme.primary,
        width: BorderWidthTokens.thin,
      ),
      ButtonVariant.text => BorderSide.none,
      ButtonVariant.custom => BorderSide.none,
    };
  }
}

// =============================================================================
// ENUM: ButtonVariant
// =============================================================================
/// Defines the visual style variants available for AppButton
///
/// Variants:
/// - primary: Filled button with primary color (main CTAs)
/// - secondary: Filled button with secondary color (alternative actions)
/// - outline: Transparent button with colored border (subtle actions)
/// - text: Text-only button with minimal styling (tertiary actions)
/// - custom: Primary style but allows color override via customColor
enum ButtonVariant { primary, secondary, outline, text, custom }

// =============================================================================
// ENUM: ButtonSize
// =============================================================================
/// Defines size presets for consistent button dimensions
///
/// Sizes (with responsive heights):
/// - small: 40h (compact, for tight spaces)
/// - medium: 56h (standard, most common)
/// - large: 64h (prominent, for important actions)
/// - xlarge: 72h (extra prominent, rarely used)
enum ButtonSize { small, medium, large, xlarge }
