// lib/features/freelancer/presentation/screens/near_you_freelancers_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_list_providers.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_card.dart';

class NearYouFreelancersScreen extends ConsumerStatefulWidget {
  const NearYouFreelancersScreen({super.key});

  @override
  ConsumerState<NearYouFreelancersScreen> createState() =>
      _NearYouFreelancersScreenState();
}

class _NearYouFreelancersScreenState
    extends ConsumerState<NearYouFreelancersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nearbyFreelancersListProvider.notifier).loadFirstPage();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(nearbyFreelancersListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(nearbyFreelancersListProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Access localization for language prefence
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Freelancers near you',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ),
      body: stateAsync.when(
        data: (state) {
          if (state.freelancers.isEmpty && state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.freelancers.isEmpty && !state.isLoading) {
            return EmptyStateWidget(
              title: 'No freelancers found nearby',
              subtitle: 'Try expanding your search area or change location',
              onAction:
                  () =>
                      ref
                          .read(nearbyFreelancersListProvider.notifier)
                          .refresh(),
            );
          }

          return RefreshIndicator(
            onRefresh:
                () =>
                    ref.read(nearbyFreelancersListProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(Spacing.md.h),
              itemCount:
                  state.freelancers.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.freelancers.length) {
                  if (!state.hasReachedMax && state.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }
                final freelancer = state.freelancers[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: Spacing.md.h),
                  child: FreelancerCard(
                    freelancer: freelancer,
                    onTap: () {
                      context.push(
                        '/freelancerDetailsScreen',
                        extra: {
                          'freelancerId': freelancer.id,
                          'coverImageUrl': freelancer.profileImage,
                        },
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: ErrorStateWidget(
                showDetails: true,
                errorDetails: 'Failed to load nearby freelancers\n$error',
                type: ErrorStateType.genericError,
                onPrimaryAction:
                    () =>
                        ref
                            .read(nearbyFreelancersListProvider.notifier)
                            .refresh(),
              ),
            ),
      ),
    );
  }
}
