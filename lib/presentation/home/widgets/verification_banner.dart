import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';

/// Thin banner shown to the shop/worker owner while their entity is pending or
/// rejected. Dismissed automatically once approved.
class VerificationBanner extends ConsumerWidget {
  final String entityType; // 'shop' | 'worker'
  final String entityId;

  const VerificationBanner({required this.entityType, required this.entityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(
      entityVerificationStatusProvider((
        entityType: entityType,
        entityId: entityId,
      )),
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
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: SemanticContainerWidget(
              icon: Icons.cancel_outlined,
              title: 'Verification rejected',
              content:
                  'Rejected: ${vs.rejectionReason ?? 'No reason provided.'}',
              backgroundColor: colorScheme.error.withValues(alpha: 0.1),
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
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: SemanticContainerWidget(
            icon: Icons.hourglass_top_outlined,
            title: 'Under review',
            content: 'Pending review — hidden from clients until approved.',
            backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
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
        entityVerificationStatusProvider((
          entityType: entityType,
          entityId: entityId,
        )),
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
