// lib/presentation/features/admin/presentation/screens/verification_review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/admin/data/verification_submission.dart';
import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';

class VerificationReviewScreen extends ConsumerWidget {
  const VerificationReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final queue = ref.watch(pendingVerificationsProvider);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Verification queue',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: queue.when(
        loading: () => const Center(child: CircularLoadingIndicator()),
        error: (e, _) => Center(
          child: ErrorStateWidget(
            subtitle: 'Could not load the queue.',
            onPrimaryAction: () =>
                ref.invalidate(pendingVerificationsProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                icon: Icons.verified_outlined,
                title: 'No pending submissions',
                subtitle: 'New verification requests will appear here.',
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(Spacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) => Gap(Spacing.sm),
            itemBuilder: (_, i) => _SubmissionCard(item: items[i]),
          );
        },
      ),
    );
  }
}

class _SubmissionCard extends ConsumerStatefulWidget {
  const _SubmissionCard({required this.item});
  final VerificationSubmission item;

  @override
  ConsumerState<_SubmissionCard> createState() => _SubmissionCardState();
}

class _SubmissionCardState extends ConsumerState<_SubmissionCard> {
  bool _busy = false;

  Future<void> _decide(String decision, {String? reason}) async {
    setState(() => _busy = true);
    try {
      await ref.read(verificationActionsProvider).review(
            entityType: widget.item.entityType,
            entityId: widget.item.entityId,
            decision: decision,
            rejectionReason: reason,
          );
      if (mounted) {
        context.showSuccessSnackbar(
          decision == 'approved' ? 'Approved' : 'Rejected',
        );
      }
    } catch (_) {
      if (mounted) context.showErrorSnackbar('Action failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _promptReject() async {
    final controller = TextEditingController();
    final String? reason;
    try {
      reason = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reject submission'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Reason (shown to the producer)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final r = controller.text.trim();
                if (r.isNotEmpty) Navigator.pop(ctx, r);
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    if (reason != null && reason.isNotEmpty) {
      await _decide('rejected', reason: reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    return CardInkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.ownerName} · ${item.entityLabel}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${item.documentUrls.length} doc(s)',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (item.overview != null && item.overview!.isNotEmpty) ...[
            Gap(Spacing.xs),
            Text(item.overview!, style: theme.textTheme.bodySmall),
          ],
          if (item.documentUrls.isNotEmpty) ...[
            Gap(Spacing.sm),
            SizedBox(
              height: 90.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.documentUrls.length,
                separatorBuilder: (_, __) => Gap(Spacing.xs),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _openDocument(item.documentUrls[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      item.documentUrls[i],
                      width: 90.h,
                      height: 90.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90.h,
                        height: 90.h,
                        color: theme.colorScheme.surface,
                        child: const Icon(Icons.description),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          Gap(Spacing.sm),
          if (_busy)
            const Center(child: CircularLoadingIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Approve',
                    onPressed: () => _decide('approved'),
                  ),
                ),
                Gap(Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _promptReject,
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openDocument(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(
            url,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Could not load document.'),
            ),
          ),
        ),
      ),
    );
  }
}
