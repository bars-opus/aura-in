import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/constants/freelancer_tags.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';

/// Multi-select tag picker for freelancers. Curated chips + custom add.
/// Selection is owned by the parent (persisted into the `specialties` column).
class FreelancerTagsSelector extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;

  const FreelancerTagsSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  State<FreelancerTagsSelector> createState() => _FreelancerTagsSelectorState();
}

class _FreelancerTagsSelectorState extends State<FreelancerTagsSelector> {
  final _customController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool _isSelected(String tag) => widget.selectedTags
      .any((t) => t.toLowerCase() == tag.toLowerCase());

  void _toggle(String tag, bool select) {
    final next = List<String>.from(widget.selectedTags);
    if (select) {
      if (next.length >= FreelancerTags.maxTags) {
        setState(() => _error = 'You can select at most ${FreelancerTags.maxTags} tags');
        return;
      }
      if (!next.any((t) => t.toLowerCase() == tag.toLowerCase())) {
        next.add(tag);
      }
    } else {
      next.removeWhere((t) => t.toLowerCase() == tag.toLowerCase());
    }
    setState(() => _error = null);
    widget.onTagsChanged(next);
  }

  void _addCustom() {
    final value = FreelancerTags.normalize(_customController.text);
    if (value.isEmpty) {
      setState(() => _error = 'Enter a tag');
      return;
    }
    if (value.length > FreelancerTags.maxTagLength) {
      setState(() => _error = 'Tag too long (max ${FreelancerTags.maxTagLength})');
      return;
    }
    if (_isSelected(value)) {
      setState(() => _error = 'Already added');
      return;
    }
    if (widget.selectedTags.length >= FreelancerTags.maxTags) {
      setState(() => _error = 'You can select at most ${FreelancerTags.maxTags} tags');
      return;
    }
    final next = List<String>.from(widget.selectedTags)..add(value);
    _customController.clear();
    setState(() => _error = null);
    widget.onTagsChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Custom tags = selected tags not present in the curated list.
    final customTags = widget.selectedTags
        .where((t) => !FreelancerTags.curated
            .any((c) => c.toLowerCase() == t.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.sm.h,
          children: FreelancerTags.curated.map((tag) {
            return AppFilterChip(
              label: tag,
              selected: _isSelected(tag),
              labelColor: colorScheme.onSurface.withValues(alpha: 0.7),
              onSelected: (sel) => _toggle(tag, sel),
            );
          }).toList(),
        ),
        Gap(Spacing.md.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                decoration: InputDecoration(
                  hintText: 'Add a custom tag',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(BorderRadiusTokens.md.r),
                  ),
                ),
                onSubmitted: (_) => _addCustom(),
              ),
            ),
            Gap(Spacing.sm.w),
            IconButton(
              onPressed: _addCustom,
              icon: Icon(Icons.add_circle, color: colorScheme.primary),
            ),
          ],
        ),
        if (_error != null) ...[
          Gap(Spacing.xs.h),
          Text(
            _error!,
            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.error),
          ),
        ],
        if (customTags.isNotEmpty) ...[
          Gap(Spacing.sm.h),
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.sm.h,
            children: customTags.map((tag) {
              return Chip(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(BorderRadiusTokens.md.r),
                ),
                label: Text(
                  tag,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                onDeleted: () => _toggle(tag, false),
                deleteIcon: Icon(Icons.close, size: 14.h, color: colorScheme.error),
              );
            }).toList(),
          ),
        ],
        Gap(Spacing.sm.h),
        Text(
          'Select all that apply, or add your own. Up to ${FreelancerTags.maxTags}.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
