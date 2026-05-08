import 'package:nano_embryo/core/utils/exports/export_packages.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
// =============================================================================
// EXTENSION: AppThemeExtension
// =============================================================================
// Purpose: Provides easy access to theme-aware colors from any ThemeData context
//
// How it works:
// - This extension adds a new property `appColors` to all ThemeData objects
// - It detects if the current theme is dark or light via `this.brightness`
// - Creates and returns an AppColors instance configured for the current theme
//
// Usage Example:
//   Theme.of(context).appColors.primary       // Gets primary color for current theme
//   Theme.of(context).appColors.textPrimary   // Gets text color for current theme
//
// Why use an extension?
// - Clean syntax: No need to check theme mode manually
// - Type-safe: Compile-time checking
// - Reusable: Works anywhere you have a ThemeData context
// =============================================================================

extension AppThemeExtension on ThemeData {
  AppColors get appColors {
    final brightness = this.brightness; // Get current theme brightness
    return AppColors(
      brightness == Brightness.dark,
    ); // Create theme-aware colors
  }
}

// =============================================================================
// CLASS: AppTheme
// =============================================================================
// Purpose: Central theme configuration for the entire application
// Contains both light and dark theme configurations that can be switched
// =============================================================================
class AppTheme {
  // ===========================================================================
  // STATIC PROPERTY: lightTheme
  // ===========================================================================
  // The complete light theme configuration for the application
  // Built using Flutter's ThemeData class with Material Design 3 enabled
  //
  // Key Components:
  // 1. COLOR SYSTEM: Uses LightColors from app_colors.dart
  //    - ColorScheme defines the core color palette
  //    - Each color role (primary, background, surface) mapped to LightColors
  //
  // 2. COMPONENT THEMES: Custom styling for specific widgets
  //    - AppBarTheme: Styling for app bars
  //    - CardTheme: Styling for cards
  //    - ButtonThemes: Styling for elevated and text buttons
  //    - InputDecorationTheme: Styling for text fields
  //    - DividerTheme: Styling for dividers
  //
  // 3. TEXT THEME: Applied via .copyWith() at the end
  //    - Uses AppTextTheme.lightTextTheme for consistent typography
  //    - Applied separately to avoid overriding other theme properties
  //
  // Theme Structure:
  //   ThemeData(...all component themes...).copyWith(textTheme: ...)
  //   ^ Base theme with colors/component styling    ^ Adds text styles
  //
  // Color References:
  //   LightColors.primary      -> Primary brand color (e.g., #6C63FF)
  //   LightColors.background   -> Main background color
  //   LightColors.surface      -> Surface/card backgrounds
  //   LightColors.textPrimary  -> Primary text color
  //   LightColors.error        -> Error state color
  //
  // Usage in MaterialApp:
  //   MaterialApp(theme: AppTheme.lightTheme, ...)
  // ===========================================================================
  static ThemeData lightTheme = ThemeData(
    // Enable Material Design 3 features
    useMaterial3: true,

    // Set overall brightness to light
    brightness: Brightness.light,

    // ================= COLOR SCHEME =================
    // Defines the core color roles for Material Design
    // All colors sourced from LightColors class
    colorScheme: ColorScheme.light(
      primary: LightColors.primary, // Primary brand color
      secondary: LightColors.primaryLight, // Secondary/accent color
      background: LightColors.background, // Main background color
      surface: LightColors.surface, // Surface/card backgrounds
      onPrimary: LightColors.white, // Text/icons on primary color
      onSecondary: LightColors.white, // Text/icons on secondary color
      onBackground: LightColors.textPrimary, // Text on background
      onSurface: LightColors.textPrimary, // Text on surfaces
      error: LightColors.error,
      primaryContainer: LightColors.foreground, // Error color
      surfaceDim: LightColors.surface,
    ),

    // Scaffold (main screen) background
    scaffoldBackgroundColor: LightColors.surface,

    // ================= APP BAR THEME =================
    appBarTheme: AppBarTheme(
      backgroundColor: LightColors.surface, // App bar background
      elevation: 0, // No shadow (flat design)
      centerTitle: true, // Center the title
      iconTheme: IconThemeData(color: LightColors.textPrimary), // Icon color
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: LightColors.textPrimary, // Title text color
      ),
    ),

    // ================= CARD THEME =================
    cardTheme: CardTheme(
      color: LightColors.card, // Card background
      elevation: 2, // Subtle shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ================= ELEVATED BUTTON THEME =================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColors.primary, // Button background
        foregroundColor: LightColors.white, // Button text/icon color
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0, // Flat design
      ),
    ),

    // ================= TEXT BUTTON THEME =================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: LightColors.primary, // Text color
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // ================= INPUT FIELD THEME =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true, // Fill background
      fillColor: LightColors.surface, // Background color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LightColors.divider), // Border color
      ),
      enabledBorder: OutlineInputBorder(
        // Normal state border
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LightColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        // Focused state border
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LightColors.primary), // Primary color
      ),
      errorBorder: OutlineInputBorder(
        // Error state border
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LightColors.error), // Error color
      ),
    ),

    // ================= DIVIDER THEME =================
    dividerTheme: DividerThemeData(
      color: LightColors.divider, // Divider line color
      thickness: 1, // Line thickness
      space: 1, // Spacing around divider
    ),
  ).copyWith(
    // ========== APPLY TEXT THEME ==========
    // .copyWith() creates a new ThemeData with updated textTheme
    // This applies our custom typography system to the base theme
    textTheme: AppTextTheme.lightTextTheme, // Custom text styles
  ); // Semicolon here completes the static property definition

  // ===========================================================================
  // STATIC PROPERTY: darkTheme
  // ===========================================================================
  // The complete dark theme configuration
  // Mirrors lightTheme structure but uses DarkColors for all color values
  //
  // Important Differences from lightTheme:
  // 1. brightness: Brightness.dark (tells Flutter this is a dark theme)
  // 2. All color references use DarkColors instead of LightColors
  // 3. Same component structure ensures consistent design system
  //
  // Design Philosophy:
  // - Dark theme isn't just inverted colors
  // - Uses different color values optimized for dark backgrounds
  // - Maintains same contrast ratios and accessibility standards
  //
  // Example Color Differences:
  //   Light: background = #F8F9FA (light gray)
  //   Dark:  background = #121212 (dark gray)
  //
  //   Light: textPrimary = #1A1A2E (dark blue/black)
  //   Dark:  textPrimary = #F5F5F5 (light gray/white)
  //
  // Usage in MaterialApp:
  //   MaterialApp(darkTheme: AppTheme.darkTheme, themeMode: ThemeMode.dark, ...)
  //   OR MaterialApp(darkTheme: AppTheme.darkTheme, themeMode: ThemeMode.system)
  // ===========================================================================
  static ThemeData darkTheme = ThemeData(
    // Enable Material Design 3
    useMaterial3: true,

    // Set overall brightness to dark
    brightness: Brightness.dark,

    // ================= COLOR SCHEME =================
    // Uses DarkColors for all color roles
    colorScheme: ColorScheme.dark(
      primary: DarkColors.primary, // Primary for dark mode
      secondary: DarkColors.primaryLight, // Secondary for dark mode
      background: DarkColors.background, // Dark background
      surface: DarkColors.surface, // Dark surface
      onPrimary: DarkColors.white, // Text on primary
      onSecondary: DarkColors.white, // Text on secondary
      onBackground: DarkColors.textPrimary, // Text on dark background
      onSurface: DarkColors.textPrimary, // Text on dark surfaces
      error: DarkColors.error, // Error color for dark mode
      primaryContainer: DarkColors.foreground,
      surfaceDim: DarkColors.background,
    ),

    // Scaffold with dark background
    scaffoldBackgroundColor: DarkColors.background,

    // ================= APP BAR THEME =================
    appBarTheme: AppBarTheme(
      backgroundColor: DarkColors.surface, // Dark app bar
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: DarkColors.textPrimary), // Light icons
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: DarkColors.textPrimary, // Light text on dark
      ),
    ),

    // ================= CARD THEME =================
    cardTheme: CardTheme(
      color: DarkColors.card, // Dark card background
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ================= ELEVATED BUTTON THEME =================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.primary, // Primary on dark
        foregroundColor: DarkColors.white, // Text on primary
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),

    // ================= TEXT BUTTON THEME =================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DarkColors.primary, // Primary colored text
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // ================= INPUT FIELD THEME =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkColors.surface, // Dark input background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DarkColors.divider), // Dark divider
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DarkColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DarkColors.primary), // Primary on focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DarkColors.error), // Error in dark
      ),
    ),

    // ================= DIVIDER THEME =================
    dividerTheme: DividerThemeData(
      color: DarkColors.divider, // Dark divider
      thickness: 1,
      space: 1,
    ),
  ).copyWith(
    // ========== APPLY TEXT THEME ==========
    // Apply dark text theme (could be same or different from light)
    textTheme: AppTextTheme.darkTextTheme, // Text styles for dark mode
  );
}

// =============================================================================
// EXTENSION: ColorSchemeExtension
// =============================================================================
// Adds semantic color access to ColorScheme
// This allows us to use colorScheme.success, colorScheme.warning, etc.
// =============================================================================
extension ColorSchemeExtension on ColorScheme {
  Color get success =>
      brightness == Brightness.light ? LightColors.success : DarkColors.success;

  Color get warning =>
      brightness == Brightness.light ? LightColors.warning : DarkColors.warning;

  Color get info =>
      brightness == Brightness.light ? LightColors.info : DarkColors.info;

  Color get neutral =>
      brightness == Brightness.light ? LightColors.neutral : DarkColors.neutral;
}

// =============================================================================
// HOW THE THREE FILES WORK TOGETHER:
// =============================================================================
// 1. app_colors.dart → Defines LightColors and DarkColors classes
//    - Contains static color constants for both themes
//    - Example: LightColors.primary = Color(0xFF6C63FF)
//    - Used directly in AppTheme for color references
//
// 2. app_text_theme.dart → Defines AppTextTheme class
//    - Contains static TextTheme objects for both themes
//    - Defines font sizes, weights, heights for all text styles
//    - Applied via .copyWith() in AppTheme
//
// 3. app_theme.dart (THIS FILE) → Defines AppTheme class
//    - Uses colors from app_colors.dart
//    - Uses text themes from app_text_theme.dart
//    - Combines them into complete ThemeData objects
//    - Provides AppThemeExtension for easy color access
//
// DATA FLOW:
//   Widget → Theme.of(context) → ThemeData →
//     [Colors from app_colors.dart] + [Text from app_text_theme.dart]
//
// =============================================================================
// USAGE EXAMPLES IN WIDGETS:
// =============================================================================
// 1. Accessing theme colors (using extension):
//    Container(color: Theme.of(context).appColors.primary)
//
// 2. Accessing text styles (from text theme):
//    Text('Hello', style: Theme.of(context).textTheme.titleLarge)
//
// 3. Using Material Design colors (from colorScheme):
//    Container(color: Theme.of(context).colorScheme.background)
//
// 4. Complete example widget:
//    class MyWidget extends StatelessWidget {
//      @override
//      Widget build(BuildContext context) {
//        return Container(
//          color: Theme.of(context).appColors.background,
//          child: Text(
//            'Title',
//            style: Theme.of(context).textTheme.titleLarge?.copyWith(
//              color: Theme.of(context).appColors.textPrimary,
//            ),
//          ),
//        );
//      }
//    }
//
// =============================================================================
// THEME SWITCHING IN MAIN APP:
// =============================================================================
// In main.dart:
//   MaterialApp(
//     theme: AppTheme.lightTheme,      // Light theme
//     darkTheme: AppTheme.darkTheme,    // Dark theme
//     themeMode: ThemeMode.system,      // Auto-switch based on system
//     // OR
//     themeMode: ThemeMode.light,       // Force light
//     // OR
//     themeMode: ThemeMode.dark,        // Force dark
//   )
//
// Programmatic switching (using provider/riverpod):
//   context.read(themeProvider).state = ThemeMode.dark
// =============================================================================
