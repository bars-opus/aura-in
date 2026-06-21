import 'package:nano_embryo/core/feedback/config/feedback_config.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class FeedbackTypeSelector extends StatelessWidget {
  final List<FeedbackTypeOption> options;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const FeedbackTypeSelector({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback Type',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        Gap(Spacing.sm.h),
        CardInkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                options.map((opt) {
                  final isSelected = selectedKey == opt.key;
                  return RadioListTile<String>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (opt.icon != null) ...[
                          Text(opt.label),
                          SizedBox(width: Spacing.sm.w),
                          Icon(
                            opt.icon,
                            size: 20.w,
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                          ),
                        ],
                      ],
                    ),
                    value: opt.key,
                    groupValue: selectedKey,
                    onChanged: (value) => onSelected(opt.key),
                    activeColor: theme.colorScheme.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
