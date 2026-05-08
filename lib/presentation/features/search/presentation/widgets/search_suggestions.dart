// lib/features/search/presentation/widgets/search_suggestions.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/search/presentation/state/search_providers.dart';

class SearchSuggestions extends ConsumerWidget {
  final Function(String) onSuggestionSelected;

  const SearchSuggestions({super.key, required this.onSuggestionSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final recentSearches = ref.watch(searchHistoryProvider);

    if (recentSearches.isEmpty == true) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.search,
          subtitle:
              'Search for shops, professionls for homeservice, or hair products to buy',
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.md.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches Section
          if (recentSearches.isNotEmpty) ...[
            Gap(Spacing.sm.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),

                AppTextButton(
                  text: 'Clear All',
                  fontSize: 12.sp,
                  textColor: Colors.red,
                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).clearHistory();
                  },
                ),
              ],
            ),
            Gap(Spacing.sm.h),
            CardInkWell(
              elevation: 0,
              padding: const EdgeInsets.all(10),
              onTap: () {},
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  final query = recentSearches[index];
                  return InfoRowWidget(
                    subtitle: '',
                    title: query,
                    iconSize: 25.sp,
                    icon: Icons.history,
                    iconColor: colorScheme.onBackground.withOpacity(.5),
                    onTap: () {
                      onSuggestionSelected(query);
                    },
                    disableTrailing: false,
                    showAvatar: false,
                    showTrailingArrow: false,
                    trailing: AppIconButton(
                      icon: Icons.close,
                      iconSize: 25.sp,
                      iconColor: colorScheme.onBackground.withOpacity(.5),
                      onPressed: () {
                        ref
                            .read(searchHistoryProvider.notifier)
                            .removeFromHistory(query);
                      },
                    ),
                  );

                  // ListTile(
                  //   leading: Icon(
                  //     Icons.history,
                  //     size: 20.h,
                  //     color: Colors.grey.shade600,
                  //   ),
                  //   title: Text(query, style: TextStyle(fontSize: 14.sp)),
                  //   trailing: IconButton(
                  //     icon: Icon(
                  //       Icons.close,
                  //       size: 16.h,
                  //       color: Colors.grey.shade400,
                  //     ),
                  // onPressed: () {
                  //   ref
                  //       .read(searchHistoryProvider.notifier)
                  //       .removeFromHistory(query);
                  // },
                  //   ),
                  //   onTap: () => onSuggestionSelected(query),
                  //   contentPadding: EdgeInsets.zero,
                  // );
                },
              ),
            ),
            Gap(Spacing.lg.h),
          ],
        ],
      ),
    );
  }
}
