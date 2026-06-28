import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final IconData? icon;
  final FontWeight fontWeight;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final TextStyle? textStyle;

  const AppTextButton({
    super.key,
    this.text = 'Done',
    this.onPressed,
    this.icon,
    this.textColor,
    this.fontWeight = FontWeight.bold,
    this.padding,
    this.alignment = Alignment.topRight,
    this.textStyle,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final effectiveStyle =
        textStyle ??
        textTheme.titleMedium?.copyWith(
          color: textColor ?? colorScheme.primary,
          fontWeight: fontWeight,
          fontSize: fontSize,
        );

    return Align(
      alignment: alignment,
      child: TextButton.icon(
        icon: Icon(
          icon,
          color: textColor ?? colorScheme.primary,
          size: fontSize,
        ),
        onPressed:
            onPressed ??
            () {
              Navigator.pop(context);
            },
        style: TextButton.styleFrom(
          padding: padding ?? Spacing.horizontalMd,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        label: Text(text, style: effectiveStyle),
      ),
    );
  }
}
