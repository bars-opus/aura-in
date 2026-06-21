import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_role.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/home/widgets/owner_tab_shop_switcher.dart';

class OwnerDashboardTab extends ConsumerStatefulWidget {
  final AccountType role;

  const OwnerDashboardTab({super.key, required this.role});

  @override
  ConsumerState<OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}

/// Thin banner shown to the shop/worker owner while their entity is pending or
/// rejected. Dismissed automatically once approved.
class _VerificationBanner extends ConsumerWidget {
  final String entityType; // 'shop' | 'worker'
  final String entityId;

  const _VerificationBanner({
    required this.entityType,
    required this.entityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(
      entityVerificationStatusProvider(
        (entityType: entityType, entityId: entityId),
      ),
    );

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (vs) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        if (vs.status == 'approved') return const SizedBox.shrink();

        if (vs.status == 'rejected') {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xs,
            ),
            child: SemanticContainerWidget(
              icon: Icons.cancel_outlined,
              title: 'Verification rejected',
              content:
                  'Rejected: ${vs.rejectionReason ?? 'No reason provided.'}',
              backgroundColor: colorScheme.error.withOpacity(0.1),
              borderColor: colorScheme.error,
              iconColor: colorScheme.error,
              textTheme: theme.textTheme,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _resubmit(context, ref),
                  child: const Text('Re-upload & resubmit'),
                ),
              ),
            ),
          );
        }

        // pending
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs,
          ),
          child: SemanticContainerWidget(
            icon: Icons.hourglass_top_outlined,
            title: 'Under review',
            content: 'Pending review — hidden from clients until approved.',
            backgroundColor: colorScheme.primary.withOpacity(0.08),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),
        );
      },
    );
  }

  Future<void> _resubmit(BuildContext context, WidgetRef ref) async {
    await context.push(RouteNames.manageDocuments);
    // After returning from doc upload, re-submit for review.
    if (!context.mounted) return;
    try {
      await ref
          .read(verificationActionsProvider)
          .submit(entityType: entityType, entityId: entityId);
      ref.invalidate(
        entityVerificationStatusProvider(
          (entityType: entityType, entityId: entityId),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not resubmit for review: $e')),
        );
      }
    }
  }
}

class _OwnerDashboardTabState extends ConsumerState<OwnerDashboardTab> {
  bool _redirecting = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      ref.invalidate(userShopsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(userShopsProvider);
    final currentShop = ref.watch(currentShopProvider);
    final isFreelancer =
        ref.watch(currentUserIsFreelancerProvider).valueOrNull ?? false;

    return shopsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(
        title: 'Could not load shops',
        subtitle: e.toString(),
        type: ErrorStateType.genericError,
      ),
      data: (shops) {
        if (shops.isEmpty) {
          if (!_redirecting) {
            _redirecting = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go(RouteNames.shopCreation);
            });
          }
          return const Center(child: CircularProgressIndicator());
        }

        // currentShopProvider holds full ShopDetailsDTO, needed for all params.
        // OwnerScheduleTab initialises it; we wait if it's still null.
        if (currentShop == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            final full =
                await ref.read(shopByIdProvider(shops.first.id).future);
            if (full != null && mounted) {
              ref.read(currentShopProvider.notifier).state = full;
            }
          });
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            OwnerTabShopSwitcher(shops: shops),
            _VerificationBanner(
              entityType: 'shop',
              entityId: currentShop.id,
            ),
            Expanded(
              child: OwnerDashboardScreen(
                shopId: currentShop.id,
                shopOwnerId: currentShop.userId,
                accountType: widget.role.value,
                shopName: currentShop.shopName,
                shopCurrencyCode: currentShop.currency ?? '',
                shopCountry: currentShop.country ?? '',
                isFreelancer: isFreelancer,
              ),
            ),
          ],
        );
      },
    );
  }
}
