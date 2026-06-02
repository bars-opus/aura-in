import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ClientServiceTable extends StatelessWidget {
  final List<TableRowData> rows;

  const ClientServiceTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      // padding: EdgeInsets.all(Spacing.sm.w),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Table(
        border: TableBorder(
          verticalInside: BorderSide(width: 1, color: Colors.grey.shade300),
          // Keep other borders as needed
          top: BorderSide.none,
          bottom: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
        ),
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
        children:
            rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;

              return TableRow(
                decoration:
                    index % 2 == 1
                        ? BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.r),
                            bottomRight: Radius.circular(10.r),
                          ),
                        )
                        : null,
                children: [
                  Padding(
                    padding: EdgeInsets.all(Spacing.sm.w),
                    child:
                        index % 2 == 1
                            ? _buildPriceDurationRow(
                              context: context,
                              icon: Icons.payment,
                              label: row.leftLabel,
                            )
                            : _buildServiceWorkerRow(
                              context,
                              label: row.leftLabel,
                              value: row.leftValue,
                            ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Spacing.sm.w),
                    child:
                        index % 2 == 1
                            ? _buildPriceDurationRow(
                              context: context,
                              icon: Icons.schedule,
                              label: row.rightLabel,
                            )
                            : _buildServiceWorkerRow(
                              context,
                              label: row.rightLabel,
                              value: row.rightValue,
                            ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

Widget _buildServiceWorkerRow(
  BuildContext context, {
  required String label,
  required String value,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  // No Expanded — TableRow cells are sized by Table.columnWidths. Expanded
  // requires a Flex parent and casts BoxParentData → FlexParentData on mount;
  // in a Table cell that cast threw in release ("BoxParentData is not a
  // subtype of FlexParentData") and blanked the whole card.
  return RichText(
    text: TextSpan(
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      children: [
        TextSpan(
          text: '$label:\n',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onBackground.withOpacity(.7),
            fontWeight: FontWeight.normal,
          ),
        ),
        TextSpan(
          text: value,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onBackground,
          ),
        ),
      ],
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

Widget _buildPriceDurationRow({
  required BuildContext context,
  required IconData icon,
  required String label,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  // Same as the row helper above — Expanded inside a TableRow cell breaks
  // in release. Row is fine as a TableRow child.
  return Row(
    children: [
      Icon(icon, size: 15.h, color: colorScheme.background),
      Gap(10.w),
      Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.background,
          fontWeight: FontWeight.normal,
        ),
      ),
    ],
  );
}

class TableRowData {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  TableRowData({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });
}

// Usage:
