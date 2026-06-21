// lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tag_chips.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_discovery_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/selected_freelancer_tags_provider.dart';

/// Multi-select tag filter row for freelancer discovery. "All" clears the
/// selection; each tag toggles membership. Hidden when no tags / on error.
class FreelancerTagChips extends ConsumerWidget {
  const FreelancerTagChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(freelancerTagsProvider);
    final selected = ref.watch(selectedFreelancerTagsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return tagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: Spacing.sm.w),
                child: AppFilterChip(
                  label: 'All',
                  selected: selected.isEmpty,
                  backgroundColor: colorScheme.surface,
                  labelColor: colorScheme.onSurface,
                  borderWidth: 0.3,
                  onSelected: (_) =>
                      ref.read(selectedFreelancerTagsProvider.notifier).state = {},
                ),
              ),
              ...tags.map((tc) {
                final isSel = selected.contains(tc.tag);
                return Padding(
                  padding: EdgeInsets.only(right: Spacing.sm.w),
                  child: AppFilterChip(
                    label: tc.tag,
                    selected: isSel,
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.surface,
                    labelColor: colorScheme.onSurface,
                    borderWidth: 0.3,
                    onSelected: (_) {
                      final next = Set<String>.from(selected);
                      if (isSel) {
                        next.remove(tc.tag);
                      } else {
                        next.add(tc.tag);
                      }
                      ref.read(selectedFreelancerTagsProvider.notifier).state = next;
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
