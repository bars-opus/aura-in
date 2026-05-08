import 'package:flutter/material.dart';

// =============================================================================
// CLASS: AppTextTheme
// =============================================================================
// Purpose: Centralized typography system for the entire application
// Defines all text styles (font sizes, weights, spacing) used throughout the app
//
// Key Concepts:
// 1. TEXT HIERARCHY: Organizes text styles from largest (display) to smallest (label)
// 2. CONSISTENCY: Ensures consistent typography across all screens
// 3. THEME-AWARE: Separate light and dark text themes for different color schemes
// 4. MATERIAL DESIGN: Follows Material Design 3 text theme structure
//
// Design Philosophy:
// - Text sizes follow a modular scale (e.g., 12, 14, 16, 18, 20, 24, 32)
// - Font weights follow semantic meaning (bold for titles, regular for body)
// - Line heights ensure proper readability (1.2-1.5 times font size)
// =============================================================================
class AppTextTheme {
  // ===========================================================================
  // STATIC PROPERTY: lightTextTheme
  // ===========================================================================
  // Complete text style definitions for light theme mode
  // Note: Text colors are NOT defined here - they come from the Theme's colorScheme
  // This separation allows text colors to adapt to light/dark themes automatically
  //
  // Material Design Text Theme Categories:
  // 1. DISPLAY: Largest text, used for major headlines/sections
  // 2. TITLE: Section headings and important labels
  // 3. BODY: Main content text
  // 4. LABEL: UI controls, buttons, captions
  //
  // Why use Material Design categories?
  // - Standardized naming convention
  // - Automatic adaptation by Flutter widgets
  // - Built-in accessibility support
  // ===========================================================================
  static TextTheme lightTextTheme = TextTheme(
    // ================= DISPLAY STYLES (Headlines) =================
    // Largest text in the app - used sparingly for major emphasis
    // Typically used for: Hero sections, main page titles, major announcements
    displayLarge: TextStyle(
      fontSize: 32, // Largest font size
      fontWeight: FontWeight.w700, // Heavy/bold weight for maximum impact
      height: 1.2, // Line height: 1.2 × 32px = 38.4px
      letterSpacing: -0.5, // Negative spacing for tighter headlines
    ),
    displayMedium: TextStyle(
      fontSize: 24, // Large but smaller than displayLarge
      fontWeight: FontWeight.w600, // Semi-bold for strong emphasis
      height: 1.3, // 1.3 × 24px = 31.2px line height
    ),
    displaySmall: TextStyle(
      fontSize: 20, // Medium-large for sub-headlines
      fontWeight: FontWeight.w600, // Semi-bold
      height: 1.4, // 1.4 × 20px = 28px line height
    ),

    // ================= TITLE STYLES (Headings) =================
    // Used for section headings, card titles, dialog titles
    // Smaller than display styles but still prominent
    titleLarge: TextStyle(
      fontSize: 18, // Large section headings
      fontWeight: FontWeight.w600, // Semi-bold for prominence
      height: 1.4, // 1.4 × 18px = 25.2px
    ),
    titleMedium: TextStyle(
      fontSize: 16, // Standard heading size
      fontWeight: FontWeight.w600, // Semi-bold
      height: 1.5, // 1.5 × 16px = 24px
    ),
    titleSmall: TextStyle(
      fontSize: 14, // Smaller headings/sub-headings
      fontWeight: FontWeight.w500, // Medium weight for subtle emphasis
      height: 1.5, // 1.5 × 14px = 21px
    ),

    // ================= BODY STYLES (Content) =================
    // Used for paragraphs, lists, and general content
    // Designed for optimal readability at typical reading distances
    bodyLarge: TextStyle(
      fontSize: 16, // Large body text (lead paragraphs)
      fontWeight: FontWeight.w400, // Regular weight for readability
      height: 1.5, // 1.5 × 16px = 24px (standard reading line height)
    ),
    bodyMedium: TextStyle(
      fontSize: 14, // Standard body text size
      fontWeight: FontWeight.w400, // Regular weight
      height: 1.5, // 1.5 × 14px = 21px
    ),
    bodySmall: TextStyle(
      fontSize: 12, // Small body text (captions, footnotes)
      fontWeight: FontWeight.w400, // Regular weight
      height: 1.5, // 1.5 × 12px = 18px
    ),

    // ================= LABEL STYLES (UI Elements) =================
    // Used for buttons, form labels, tabs, and interactive elements
    // Typically includes letter spacing for better legibility at small sizes
    labelLarge: TextStyle(
      fontSize: 14, // Large labels (button text)
      fontWeight: FontWeight.w600, // Semi-bold for emphasis
      height: 1.5, // 1.5 × 14px = 21px
      letterSpacing: 0.5, // Increased spacing for uppercase/all-caps
    ),
    labelMedium: TextStyle(
      fontSize: 12, // Medium labels (form labels, tabs)
      fontWeight: FontWeight.w600, // Semi-bold
      height: 1.5, // 1.5 × 12px = 18px
      letterSpacing: 0.5, // Increased spacing for readability
    ),
    labelSmall: TextStyle(
      fontSize: 10, // Small labels (captions, badges)
      fontWeight: FontWeight.w600, // Semi-bold for visibility
      height: 1.5, // 1.5 × 10px = 15px
      letterSpacing: 0.5, // Maximum spacing for small text
    ),
  );

  // ===========================================================================
  // STATIC PROPERTY: darkTextTheme
  // ===========================================================================
  // Text style definitions for dark theme mode
  //
  // Design Decision: Using same font styles as light theme
  // Why?
  // 1. Consistency: Users expect same text sizes regardless of theme
  // 2. Accessibility: Font weights/sizes optimized for readability
  // 3. Simplicity: Easier maintenance (change once, affects both)
  //
  // Important: Text COLORS are different in dark theme
  // - Colors come from Theme.of(context).colorScheme.onBackground/surface
  // - This happens automatically when using Material Design text styles
  //
  // The .copyWith() pattern:
  // - Creates new TextStyle instances from lightTextTheme
  // - Allows future customization for dark mode if needed
  // - Maintains type safety with null assertion (!) operator
  // ===========================================================================
  static TextTheme darkTextTheme = TextTheme(
    // Copy all styles from lightTextTheme
    // This ensures identical typography between light and dark modes
    // Color adaptation happens automatically via Flutter's theme system
    displayLarge: lightTextTheme.displayLarge!.copyWith(),
    displayMedium: lightTextTheme.displayMedium!.copyWith(),
    displaySmall: lightTextTheme.displaySmall!.copyWith(),

    titleLarge: lightTextTheme.titleLarge!.copyWith(),
    titleMedium: lightTextTheme.titleMedium!.copyWith(),
    titleSmall: lightTextTheme.titleSmall!.copyWith(),

    bodyLarge: lightTextTheme.bodyLarge!.copyWith(),
    bodyMedium: lightTextTheme.bodyMedium!.copyWith(),
    bodySmall: lightTextTheme.bodySmall!.copyWith(),

    labelLarge: lightTextTheme.labelLarge!.copyWith(),
    labelMedium: lightTextTheme.labelMedium!.copyWith(),
    labelSmall: lightTextTheme.labelSmall!.copyWith(),
  );
  // ===========================================================================
  // STATIC METHOD: of
  // ===========================================================================
  // Retrieves the appropriate text theme based on current theme context
  //
  // Usage:
  //   final textTheme = AppTextTheme.of(context);
  //   Text('Hello', style: textTheme.headlineLarge)
  //
  // Benefits:
  // 1. Type-safe access to text styles
  // 2. Automatic light/dark theme selection
  // 3. Consistent with Flutter's Theme.of(context) pattern
  // 4. Centralized theme switching logic
  //
  // Implementation Details:
  // - Checks current theme brightness
  // - Returns lightTextTheme for light mode
  // - Returns darkTextTheme for dark mode
  // - Falls back to lightTextTheme if brightness cannot be determined
  // ===========================================================================
  static TextTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkTextTheme : lightTextTheme;
  }

  // Optional: Method to get text theme for a specific brightness
  static TextTheme forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextTheme : lightTextTheme;
  }
}

// =============================================================================
// HOW TO USE APP TEXT THEME IN WIDGETS
// =============================================================================
// Example 1: Basic usage with theme
//   Text('Headline', style: Theme.of(context).textTheme.displayLarge)
//
// Example 2: With custom color (if needed)
//   Text(
//     'Title',
//     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//       color: Theme.of(context).appColors.textPrimary,
//     ),
//   )
//
// Example 3: Direct access (without theme context)
//   Text('Label', style: AppTextTheme.lightTextTheme.labelMedium)
//
// =============================================================================
// MATERIAL DESIGN TEXT STYLE HIERARCHY REFERENCE
// =============================================================================
// | Category       | Typical Use Case                  | Size Example |
// |----------------|-----------------------------------|--------------|
// | displayLarge   | Hero text, major headlines       | 32-57px      |
// | displayMedium  | Page titles, major sections      | 24-45px      |
// | displaySmall   | Section headlines                | 20-36px      |
// | titleLarge     | Card titles, dialog titles       | 18-28px      |
// | titleMedium    | List headings, important labels  | 16-24px      |
// | titleSmall     | Sub-headings, minor labels       | 14-20px      |
// | bodyLarge      | Lead paragraphs, important text   | 16-20px      |
// | bodyMedium     | Standard paragraphs, lists       | 14-16px      |
// | bodySmall      | Captions, secondary information  | 12-14px      |
// | labelLarge     | Button text, prominent labels    | 14-16px      |
// | labelMedium    | Form labels, tabs                | 12-14px      |
// | labelSmall     | Badges, tiny labels              | 10-12px      |
//
// =============================================================================
// TYPOGRAPHY BEST PRACTICES IMPLEMENTED HERE
// =============================================================================
// 1. MODULAR SCALE: Font sizes follow a ratio (approximately 1.25)
//    - 10, 12, 14, 16, 18, 20, 24, 32
//
// 2. LINE HEIGHT: Proportional to font size for readability
//    - Display: 1.2-1.4 (tighter for headlines)
//    - Body: 1.5 (standard for reading)
//    - Labels: 1.5 (consistent with body)
//
// 3. FONT WEIGHT HIERARCHY:
//    - w700 (bold): Maximum emphasis (displayLarge)
//    - w600 (semi-bold): Strong emphasis (headings, buttons)
//    - w500 (medium): Subtle emphasis (small titles)
//    - w400 (regular): Normal text (body content)
//
// 4. LETTER SPACING:
//    - Negative for large display text (-0.5 to -0.1)
//    - Positive for small labels (0.5 for better legibility)
//    - Zero for body text (optimal for reading)
//
// =============================================================================
// CUSTOMIZATION EXAMPLE
// =============================================================================
// To add a custom text style or modify existing ones:
//
// 1. Add new style to lightTextTheme:
//    headlineLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
//
// 2. Don't forget to add to darkTextTheme:
//    headlineLarge: lightTextTheme.headlineLarge!.copyWith(),
//
// 3. Use in widget:
//    Text('Big Hero', style: Theme.of(context).textTheme.headlineLarge)
//
// =============================================================================
// ACCESSIBILITY CONSIDERATIONS
// =============================================================================
// 1. Minimum font size: 10px (labelSmall) - absolute minimum for readability
// 2. Sufficient contrast: Colors handled by Theme colorScheme
// 3. Weight variations: Different weights for visual hierarchy
// 4. Line height: Minimum 1.2 for all text, 1.5 for body text
// 5. Letter spacing: Adjusted for small text to improve legibility
//
// =============================================================================
// PERFORMANCE NOTES
// =============================================================================
// - Static properties: Loaded once at app start, not rebuilt
// - Immutable: TextStyle objects are immutable, safe for const
// - Theme inheritance: Efficiently passed down widget tree
// - Hot reload: Changes to text styles update immediately
// =============================================================================
