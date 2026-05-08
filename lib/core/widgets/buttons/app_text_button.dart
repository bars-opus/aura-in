// lib/core/widgets/app_text_button.dart
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_packages.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';


/// A minimalist, text-only button component for simple actions with clean typography.
///
/// This widget provides a text-based button that integrates with the application's
/// design system and typography hierarchy. It's ideal for subtle actions like
/// "Done", "Cancel", or navigation links where a full button appearance isn't needed.
///
/// ## Features
/// - **Clean typography**: Uses the app's text theme and design token system
/// - **Flexible positioning**: Can be aligned anywhere via the `alignment` parameter
/// - **Sensible defaults**: Provides reasonable fallbacks for common use cases
/// - **Navigation integration**: Default tap action navigates back for modal flows
/// - **Responsive sizing**: Uses `ScreenUtil` for scalable font sizes
///
/// ## Design Philosophy
/// Unlike traditional buttons with backgrounds and borders, `AppTextButton` relies
/// purely on typography and color to indicate interactivity. This makes it ideal
/// for interfaces where visual density needs to be minimized.
///
/// ## Usage Examples
/// ```dart
/// // Basic "Done" button aligned top-right (common for modal headers)
/// AppTextButton(
///   text: 'Done',
///   onPressed: () => saveChanges(),
/// )
///
/// // Left-aligned "Cancel" button
/// AppTextButton(
///   text: 'Cancel',
///   onPressed: () => Navigator.pop(context),
///   alignment: Alignment.centerLeft,
///   textColor: Colors.grey,
/// )
///
/// // Custom-styled action button
/// AppTextButton(
///   text: 'View All',
///   textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
///     color: Colors.blue,
///     decoration: TextDecoration.underline,
///   ),
///   padding: EdgeInsets.symmetric(vertical: 8.h),
/// )
/// ```
///
/// ## Accessibility Note
/// Text buttons should maintain sufficient color contrast against their background.
/// Consider using the theme's `primary` color or another high-contrast color option.
class AppTextButton extends StatelessWidget {
  /// The text label displayed on the button.
  ///
  /// Defaults to 'Done', making this component ideal for common modal completion
  /// actions. Choose clear, action-oriented text that describes what happens when tapped.
  final String? text;

  /// Callback function triggered when the text is tapped.
  ///
  /// If not provided, defaults to navigating back (`Navigator.pop(context)`),
  /// making this component particularly useful for modal dialog completion actions.
  final VoidCallback? onPressed;

  /// Color of the text.
  ///
  /// If not provided, defaults to the theme's primary color (`colorScheme.primary`).
  /// Use this to create visual hierarchy or match specific interface needs.
  final Color? textColor;

  /// Font weight of the text.
  ///
  /// Defaults to `FontWeight.bold` to provide clear visual distinction from
  /// surrounding text. Consider using regular weight for less prominent actions.
  final FontWeight? fontWeight;
    final double? fontSize;


  /// Padding applied around the text.
  ///
  /// Defaults to `Spacing.horizontalMd` (medium horizontal spacing token).
  /// Adjust this to increase touch target size or create visual separation.
  final EdgeInsetsGeometry? padding;

  /// Alignment of the button within its parent container.
  ///
  /// Defaults to `Alignment.topRight`, making this component ideal for modal
  /// completion buttons. Change to align left, center, or other positions as needed.
  final AlignmentGeometry alignment;

  /// Complete text style override.
  ///
  /// If provided, this completely replaces the default text styling, ignoring
  /// `textColor` and `fontWeight` parameters. Use for highly customized button appearances.
  final TextStyle? textStyle;

  /// Creates a minimalist text button with clean typography.
  ///
  /// All parameters are optional with sensible defaults optimized for common
  /// modal completion patterns and Material Design guidelines.
  const AppTextButton({
    super.key,
    this.text ,
    this.onPressed,
    this.fontSize,
    this.textColor,
    this.fontWeight = FontWeight.bold,
    this.padding,
    this.alignment = Alignment.topRight,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Extract theme elements for consistent styling
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
   // Access localization for language prefence
    final loc = AppLocalizations.of(context)!;
    return Align(
      alignment: alignment,
      child: GestureDetector(
        // Use provided callback or default to navigation back
        // This default makes the component particularly useful for modal flows
        onTap: onPressed ?? () => Navigator.pop(context),
        child: Padding(
          // Apply custom padding or use standard horizontal spacing
          padding: padding ?? Spacing.horizontalMd,
          child: Text(
            text ?? loc.commonDone,
            style:
                // Use custom text style if provided, otherwise build from theme
                textStyle ??
                textTheme.titleMedium?.copyWith(
                  // Default to primary color for clear visual hierarchy
                  color: textColor ?? colorScheme.primary,
                  fontWeight: fontWeight,
                  // Responsive font size using ScreenUtil
                  fontSize: fontSize?? 16.sp,
                ),
          ),
        ),
      ),
    );
  }
}
