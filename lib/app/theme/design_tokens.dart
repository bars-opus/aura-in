import 'package:flutter/material.dart';

// =============================================================================
// DESIGN TOKENS - Single source of truth for design values
// =============================================================================

// Spacing tokens (8px base unit - Material Design standard)
class Spacing {
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small
  static const double md = 16.0; // Medium (base unit)
  static const double lg = 24.0; // Large
  static const double xl = 32.0; // Extra large
  static const double xxl = 48.0; // Extra extra large

  // Edge insets (pre-defined for consistency)
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: xl);

  static const EdgeInsets pagePadding = EdgeInsets.all(lg);
}

// Border radius tokens (Material Design 3 standard)
class BorderRadiusTokens {
  static const double none = 0;
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small
  static const double md = 12.0; // Medium
  static const double lg = 16.0; // Large
  static const double xl = 28.0; // Extra large
  static const double full = 9999.0; // Full circle/pill

  // Pre-defined BorderRadius objects
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}

// Elevation tokens (Material Design - dp units)
class ElevationTokens {
  static const double none = 0; // No shadow
  static const double xs = 1.0; // Subtle separation
  static const double sm = 3.0; // Cards, dialogs
  static const double md = 6.0; // Navigation drawer
  static const double lg = 8.0; // App bar
  static const double xl = 12.0; // Modal bottom sheet
}

// Animation durations (Material Design timing)
class AnimationDurations {
  static const Duration instant = Duration(
    milliseconds: 50,
  ); // Instant feedback
  static const Duration fastest = Duration(milliseconds: 100); // Very fast
  static const Duration fast = Duration(milliseconds: 200); // Fast
  static const Duration medium = Duration(milliseconds: 300); // Standard
  static const Duration slow = Duration(milliseconds: 500); // Slow/emphasized
  static const Duration slowest = Duration(milliseconds: 700); // Very slow

  // Specific use cases
  static const Duration buttonPress = fastest;
  static const Duration pageTransition = medium;
  static const Duration dialogAnimation = slow;
}

// Animation curves (Material Design 3 easing curves)
class AnimationCurves {
  // Standard easing - most UI elements
  static const Curve standard = Curves.easeInOut;

  // Emphasized easing - for important transitions
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  // Decelerating - elements appearing on screen
  static const Curve decelerate = Curves.decelerate;

  // Accelerating - elements disappearing
  static const Curve accelerate = Curves.fastLinearToSlowEaseIn;

  // Linear - progress indicators, loading
  static const Curve linear = Curves.linear;

  // Playful effects (use sparingly)
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;

  // Specific use cases
  static const Curve buttonPress = Curves.easeOut;
  static const Curve pageTransition = emphasized;
  static const Curve fadeIn = decelerate;
  static const Curve fadeOut = accelerate;
}

// Icon sizes (Material Design standard)
class IconSizes {
  static const double xs = 12.0; // Extra small
  static const double sm = 16.0; // Small
  static const double md = 24.0; // Medium (standard)
  static const double lg = 32.0; // Large
  static const double xl = 48.0; // Extra large
  static const double xxl = 64.0; // Hero icons
}

// Responsive breakpoints (Material Design guidelines)
class Breakpoints {
  // Mobile-first breakpoints
  static const double mobile = 600; // Phones (0-599px)
  static const double tablet = 905; // Tablets (600-904px)
  static const double desktop = 1240; // Desktop (905-1239px)
  static const double large = 1440; // Large screens (1240px+)

  // Alternative (simpler) breakpoints
  static const double small = 480; // Small phones
  static const double medium = 768; // Tablets/landscape phones
  static const double largeAlt = 1024; // Small laptops
  static const double xlarge = 1440; // Desktop monitors
}

// Opacity tokens (for consistent transparency)
class OpacityTokens {
  static const double disabled = 0.38; // Disabled elements
  static const double medium = 0.60; // Secondary text/icons
  static const double high = 0.87; // Primary text
  static const double full = 1.0; // Fully opaque
}

//fontt sizes
class FontSizeTokens {
  static const double xxs = 10;
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;
}

// Border width tokens
class BorderWidthTokens {
  static const double none = 0;
  static const double hairline = 0.3; // Very thin
  static const double thin = 1.0; // Standard thin
  static const double thick = 2.0; // Thick border
}

// Tab specific tokens
class TabTokens {
  // Default tab height
  static const double defaultHeight = 48.0;

  // Default tab padding
  static const double defaultPadding = 16.0;

  // Default indicator height
  static const double defaultIndicatorHeight = 3.0;

  // Border radius for tabs
  static const double defaultBorderRadius = BorderRadiusTokens.md;

  // Animation duration for tab switching
  static const Duration switchDuration = AnimationDurations.fast;

  // Tab animation curve
  static const Curve switchCurve = AnimationCurves.standard;
}
