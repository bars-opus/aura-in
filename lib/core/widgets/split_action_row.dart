import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class SplitActionRowItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const SplitActionRowItem({
    required this.label,
    required this.icon,
    this.onTap,
  });
}

/// Reusable equal-width action row with dividers between actions.
/// Useful for compact "Message / Call" or similar paired controls.
class SplitActionRow extends StatelessWidget {
  final List<SplitActionRowItem> actions;
  final EdgeInsetsGeometry? padding;
  final double dividerHeight;

  const SplitActionRow({
    super.key,
    required this.actions,
    this.padding,
    this.dividerHeight = 30,
  }) : assert(actions.length >= 2, 'SplitActionRow needs at least 2 actions');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: Spacing.xs.h),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            Expanded(child: _ActionTile(action: actions[i])),
            if (i != actions.length - 1)
              Container(
                height: dividerHeight.h,
                width: 0.5,
                color: colorScheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final SplitActionRowItem action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = action.onTap != null;
    final foregroundColor =
        enabled
            ? colorScheme.primary
            : colorScheme.onSurface.withValues(alpha: 0.4);

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 18.sp, color: foregroundColor),
            Gap(Spacing.xs.w),
            Flexible(
              child: Text(
                action.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
