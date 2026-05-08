// lib/features/freelancer/creation/presentation/widgets/tool_checkbox_group.dart
import 'package:nano_embryo/presentation/features/freelancer/data/models/tool.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/tool_repository.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// Tool selection widget - similar to AmenityCheckboxGroup
/// Allows freelancers to select their tools/equipment
class ToolCheckboxGroup extends ConsumerStatefulWidget {
  final List<String> selectedToolIds;
  final Function(List<String>) onSelectionChanged;

  const ToolCheckboxGroup({
    super.key,
    required this.selectedToolIds,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<ToolCheckboxGroup> createState() => _ToolCheckboxGroupState();
}

class _ToolCheckboxGroupState extends ConsumerState<ToolCheckboxGroup> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toolsByCategoryAsync = ref.watch(toolsByCategoryProvider);

    return toolsByCategoryAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              title: 'No tools available',
              subtitle: 'Check back later for more options',
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, categoryIndex) {
            final category = categories[categoryIndex];
            return _buildCategorySection(category, theme);
          },
        );
      },
      loading: () => const Center(child: CircularLoadingIndicator()),
      error:
          (error, stack) => Center(
            child: ErrorStateWidget(
              subtitle: 'Failed to load tools: $error',
              onPrimaryAction: () {
                ref.invalidate(toolsByCategoryProvider);
              },
            ),
          ),
    );
  }

  Widget _buildCategorySection(ToolCategory category, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(Spacing.md),
        Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
          child: Text(
            category.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground.withOpacity(.6),
            ),
          ),
        ),
        // AppDivider(),
        CardInkWell(
          // margin: EdgeInsets.only(bottom: Spacing.md.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...category.tools.map(
                (amenity) => _buildToolTile(
                  amenity,
                  theme,
                  category.tools.indexOf(amenity) < category.tools.length - 1,
                ),
              ),

              // Gap(Spacing.md.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolTile(Tool tool, ThemeData theme, bool showDivider) {
    final isSelected = widget.selectedToolIds.contains(tool.id);
    final colorScheme = theme.colorScheme;

    return InfoRowWidget(
      subtitle: tool.name,
      title: '',
      icon: tool.icon,
      iconColor: isSelected ? colorScheme.primary : colorScheme.onBackground,
      avatarRadius: 25.h,
      onTap: () {
        final updatedIds = List<String>.from(widget.selectedToolIds);
        if (isSelected) {
          updatedIds.remove(tool.id);
        } else {
          updatedIds.add(tool.id);
        }
        widget.onSelectionChanged(updatedIds);
      },
      showAvatar: false,
      showTrailingArrow: false,
      showDivider: showDivider,
      trailing: Container(
        width: 18.w,
        height: 18.h,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(2.r),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.4),
            width: 2,
          ),
        ),
        child:
            isSelected
                ? Icon(Icons.check, size: 16.sp, color: colorScheme.onPrimary)
                : null,
      ),
    );
  }

}
