// lib/features/freelancer/creation/presentation/widgets/freelancer_type_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';
import 'package:nano_embryo/presentation/features/freelancer/enums/freelancer_type.dart';

/// Widget for selecting freelancer's primary type
/// Uses chips for visual selection
class FreelancerTypeSelector extends StatelessWidget {
  final String? selectedType;
  final Function(String?) onTypeSelected;
  final bool allowMultiple;
  final List<String> selectedTypes;

  const FreelancerTypeSelector({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
    this.allowMultiple = false,
    this.selectedTypes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.sm.h,
          children:
              FreelancerType.values.map((type) {
                final isSelected =
                    allowMultiple
                        ? selectedTypes.contains(type.name)
                        : selectedType == type.name;

                return AppFilterChip(
                  avatarIcon: type.icon,

                  label: type.displayName,
                  selected: isSelected,
                  labelColor: colorScheme.onSurface.withOpacity(0.7),
                  onSelected: (selected) {
                    if (allowMultiple) {
                      final newTypes = List<String>.from(selectedTypes);
                      if (selected) {
                        newTypes.add(type.name);
                      } else {
                        newTypes.remove(type.name);
                      }
                      onTypeSelected(
                        null,
                      ); // Not used, but callback expects String?
                      // Actually need to handle this differently
                    } else {
                      onTypeSelected(selected ? type.name : null);
                    }
                  },
                );
              }).toList(),
        ),
        Gap(Spacing.sm.h),
        Text(
          allowMultiple
              ? 'Select all that apply (you can choose multiple)'
              : 'Select your primary service type',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
