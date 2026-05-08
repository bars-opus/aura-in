import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final int? maxline;

  const InfoRow({required this.label, required this.value, this.valueColor, this.maxline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? colorScheme.onSurface,
            ),
            overflow: TextOverflow.clip,
            maxLines: maxline,
          ),
        ),
      ],
    );
  }
}
