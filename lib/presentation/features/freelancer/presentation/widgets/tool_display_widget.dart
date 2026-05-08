import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/tool.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/tool_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';

class ToolDisplayWidget extends ConsumerWidget {
  final List<String> selectedToolIds;

  const ToolDisplayWidget({super.key, required this.selectedToolIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsAsync = ref.watch(toolsByCategoryProvider);

    return toolsAsync.when(
      data: (categories) {
        final selected =
            categories
                .expand((c) => c.tools)
                .where((t) => selectedToolIds.contains(t.id))
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        if (selected.isEmpty) return const SizedBox.shrink();

        return ShopDetailsSection(
          title: 'Tools & Equipment',
          seeAllOnperssed: null,
          widget: SizedBox(
            height: selected.length * 36,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selected.length,
              separatorBuilder: (_, __) => AppDivider(),
              itemBuilder: (context, index) => _buildTile(context, selected[index]),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTile(BuildContext context, Tool tool) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(tool.icon, size: 20, color: theme.colorScheme.primary),
        SizedBox(width: Spacing.md.w),
        Expanded(
          child: Text(tool.name, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
