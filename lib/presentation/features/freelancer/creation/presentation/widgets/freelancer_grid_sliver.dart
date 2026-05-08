// lib/features/freelancer/presentation/widgets/freelancer_grid_sliver.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_discovery_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_card.dart';

/// Sliver list of freelancers for the Discover screen.
///
/// Uses a proper SliverList so items are lazily rendered as they scroll into
/// view — no shrinkWrap / NeverScrollableScrollPhysics nesting needed.
/// allFreelancersProvider is a FutureProvider that watches the selected
/// category and location, so it auto-reloads when either changes.
class FreelancerGridSliver extends ConsumerWidget {
  const FreelancerGridSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freelancersAsync = ref.watch(allFreelancersProvider);

    return freelancersAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(
          child: LoadingStateWidget(type: LoadingStateType.inline),
        ),
      ),

      error: (error, stack) => SliverFillRemaining(
        child: Center(
          child: ErrorStateWidget(
            subtitle:
                'Failed to load freelancers. This might be temporary — try again later.',
            title: '',
            onPrimaryAction: () => ref.invalidate(freelancerDiscoveryProvider),
          ),
        ),
      ),

      data: (freelancers) {
        if (freelancers.isEmpty) {
          return SliverFillRemaining(
            child: CardInkWell(
              elevation: 0,
              padding: const EdgeInsets.all(0),
              child: Center(
                child: EmptyStateWidget(
                  icon: Icons.person,
                  title: 'No freelancers found',
                  subtitle: 'Try adjusting your search or location',
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.only(bottom: Spacing.md.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final freelancer = freelancers[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: Spacing.sm.h),
                  child: FreelancerCard(
                    freelancer: freelancer,
                    onTap: () => context.push(
                      '/freelancerDetailsScreen',
                      extra: {
                        'freelancerId': freelancer.id,
                        'coverImageUrl': freelancer.profileImage,
                      },
                    ),
                  ),
                );
              },
              childCount: freelancers.length,
            ),
          ),
        );
      },
    );
  }
}
