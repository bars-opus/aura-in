// lib/features/chat/presentation/widgets/chat_sort_dialog.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/chat_ui_providers.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ChatSortDialog extends ConsumerWidget {
  final VoidCallback? onClearSearch; // Optional callback for clearing search
  final TextEditingController? searchController; // Optional controller

  const ChatSortDialog({super.key, this.onClearSearch, this.searchController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(sortCriteriaProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    IconData _getSortIcon(SortCriteria criteria) {
      switch (criteria) {
        case SortCriteria.recent:
          return Icons.access_time;
        case SortCriteria.unread:
          return Icons.mark_chat_unread;
        case SortCriteria.groups:
          return Icons.group;
        case SortCriteria.individuals:
          return Icons.person;
        case SortCriteria.alphabetical:
          return Icons.sort_by_alpha;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sort',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppTextButton(),
          ],
        ),
        Gap(Spacing.xl.h),

        // Sort Options
        ...SortCriteria.values.map((criteria) {
          return Padding(
            padding: EdgeInsets.only(bottom: Spacing.md),
            child: InfoRowWidget(
              subtitle: '',
              title: criteria.label,
              // showDivider: false,
              showAvatar: false,
              icon: _getSortIcon(criteria),
              trailing:
                  currentSort == criteria
                      ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24.h,
                      )
                      : SizedBox.shrink(),
              onTap: () {
                ref.read(sortCriteriaProvider.notifier).state = criteria;
                Navigator.pop(context);
              },
              showTrailingArrow: false,
            ),
          );
        }).toList(),
      ],
    );
  }
}
