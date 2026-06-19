import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// Universal button widget with multiple variants
/// Supports: Primary, Secondary, Outline, Text, Icon, Loading states

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final IconData? iconData;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? customColor;
  final TextStyle? customTextStyle;
  final Color? outlineColor;
  final Color? textColor;
  final bool center;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final double? elevation;

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

  @override
  Widget build(BuildContext context) {
    // Extract theme values from current context
    // These automatically update when theme changes (light/dark mode)
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedScaleFade(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height ?? _getHeight(size),
        child: _buildButton(context, colorScheme, textTheme),
      ),
    );
  }

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

  Widget _buildContent(BuildContext context, TextStyle textStyle) {
    if (isLoading) {
      return CircularLoadingIndicator();
    }

    return Padding(
      padding: EdgeInsets.only(left: center ? 0 : Spacing.lg),
      child:
          prefixIcon != null
              ? Row(
                children: [
                  Expanded(child: _mainButton(context, textStyle)),
                  Icon(
                    prefixIcon,
                    size: IconSizes.xs.r + 2.r,
                    color:
                        prefixIconColor ??
                        Theme.of(context).colorScheme.background,
                  ),
                ],
              )
              : _mainButton(context, textStyle),
    );
  }

  Widget _mainButton(BuildContext context, TextStyle textStyle) {
    return Row(
      mainAxisAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          Gap(Spacing.sm.w),
        ] else if (iconData != null) ...[
          Icon(
            iconData,
            size: _getIconSize(),
            color: textColor ?? _getIconColor(context),
          ),
          Gap(Spacing.sm.w),
        ],
        Flexible(
          child: Text(
            label,
            style: textStyle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  VoidCallback? _getOnPressed() {
    if (isLoading || isDisabled) return null;
    return onPressed;
  }

  WidgetStateProperty<Color?> _getOverlayColor(ColorScheme colorScheme) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return null;

      if (customColor != null) {
        return _getContrastColor(customColor!).withValues(alpha: 0.20);
      }

      return switch (variant) {
        ButtonVariant.primary => colorScheme.onPrimary.withValues(alpha: 0.20),
        ButtonVariant.secondary => colorScheme.onSecondary.withValues(
          alpha: 0.20,
        ),
        ButtonVariant.outline => colorScheme.primary.withValues(alpha: 0.20),
        ButtonVariant.text => colorScheme.primary.withValues(alpha: 0.20),
        ButtonVariant.custom => colorScheme.primary.withValues(alpha: 0.20),
      };
    });
  }

  Color _getContrastColor(Color baseColor) {
    final brightness = ThemeData.estimateBrightnessForColor(baseColor);
    return brightness == Brightness.dark
        ? Color.lerp(baseColor, Colors.white, 0.3)!
        : Color.lerp(baseColor, Colors.black, 0.3)!;
  }

  ButtonStyle _getButtonStyle(ColorScheme colorScheme) {
    final backgroundColor = _getBackgroundColor(colorScheme);
    final foregroundColor = _getForegroundColor(colorScheme);
    final side = _getBorderSide(colorScheme);
    final overlayColor = _getOverlayColor(colorScheme);

    final baseStyle = switch (variant) {
      ButtonVariant.outline => OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        side: side,
        disabledBackgroundColor: colorScheme.surface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
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
        disabledBackgroundColor: colorScheme.surface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
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

    return baseStyle.copyWith(overlayColor: overlayColor);
  }

  TextStyle _getTextStyle(TextTheme textTheme, ColorScheme colorScheme) {
    final baseStyle = textTheme.labelLarge?.copyWith(
      fontSize: _getFontSize(),
      color: textColor ?? _getTextColor(colorScheme),
    );
    return customTextStyle ?? baseStyle ?? const TextStyle();
  }

  double _getHeight(ButtonSize size) {
    return switch (size) {
      ButtonSize.small => 40.h,
      ButtonSize.medium => 56.h,
      ButtonSize.large => 64.h,
      ButtonSize.xlarge => 72.h,
    };
  }

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

  double _getFontSize() {
    return switch (size) {
      ButtonSize.small => 12.sp,
      ButtonSize.medium => 14.sp,
      ButtonSize.large => 16.sp,
      ButtonSize.xlarge => 18.sp,
    };
  }

  double _getIconSize() {
    return switch (size) {
      ButtonSize.small => 16.r,
      ButtonSize.medium => 20.r,
      ButtonSize.large => 24.r,
      ButtonSize.xlarge => 28.r,
    };
  }

  double? _getElevation() {
    return switch (variant) {
      ButtonVariant.primary => ElevationTokens.sm,
      ButtonVariant.secondary => ElevationTokens.xs,
      ButtonVariant.outline => ElevationTokens.none,
      ButtonVariant.text => ElevationTokens.none,
      ButtonVariant.custom => ElevationTokens.sm,
    };
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (customColor != null) return customColor!;

    return switch (variant) {
      ButtonVariant.primary => colorScheme.primary,
      ButtonVariant.secondary => colorScheme.secondary,
      ButtonVariant.outline => Colors.transparent,
      ButtonVariant.text => Colors.transparent,
      ButtonVariant.custom => colorScheme.primary,
    };
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    if (customColor != null) {
      final brightness = ThemeData.estimateBrightnessForColor(customColor!);
      return brightness == Brightness.dark ? Colors.white : Colors.black;
    }

    return switch (variant) {
      ButtonVariant.primary => colorScheme.onPrimary,
      ButtonVariant.secondary => colorScheme.onSecondary,
      ButtonVariant.outline => colorScheme.primary,
      ButtonVariant.text => colorScheme.primary,
      ButtonVariant.custom => colorScheme.onPrimary,
    };
  }

  Color _getTextColor(ColorScheme colorScheme) {
    if (customColor != null) {
      final brightness = ThemeData.estimateBrightnessForColor(customColor!);
      return brightness == Brightness.dark ? Colors.white : Colors.black;
    }

    return switch (variant) {
      ButtonVariant.primary => colorScheme.onPrimary,
      ButtonVariant.secondary => colorScheme.onSecondary,
      ButtonVariant.outline => colorScheme.primary,
      ButtonVariant.text => colorScheme.primary,
      ButtonVariant.custom => colorScheme.onPrimary,
    };
  }

  Color _getIconColor(BuildContext context) {
    return _getTextColor(Theme.of(context).colorScheme);
  }

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

enum ButtonVariant { primary, secondary, outline, text, custom }

enum ButtonSize { small, medium, large, xlarge }
