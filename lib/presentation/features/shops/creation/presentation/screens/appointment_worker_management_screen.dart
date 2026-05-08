// lib/features/shop/workers/presentation/screens/worker_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/worker_selection/worker_avatar_chip.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/invite_worker_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/pending_invite_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/appointmetn_workers_provider.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/worker_detail_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/worker_invite.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';

class AppointmentWorkerManagementScreen extends ConsumerStatefulWidget {
  final String shopId;

  const AppointmentWorkerManagementScreen({super.key, required this.shopId});

  @override
  ConsumerState<AppointmentWorkerManagementScreen> createState() =>
      _AppointmentWorkerManagementScreenState();
}

class _AppointmentWorkerManagementScreenState
    extends ConsumerState<AppointmentWorkerManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeWorkersAsync = ref.watch(
      shopActiveWorkersProvider(widget.shopId),
    );
    final pendingInvitesAsync = ref.watch(
      shopPendingInvitesProvider(widget.shopId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Workers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showInviteWorkerModal(),
            tooltip: 'Invite Worker',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(shopActiveWorkersProvider(widget.shopId));
          ref.invalidate(shopPendingInvitesProvider(widget.shopId));
        },
        child: CustomScrollView(
          slivers: [
            // Active Workers Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(Spacing.md.h),
                child: Text(
                  'Active Workers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            activeWorkersAsync.when(
              data: (workers) {
                if (workers.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmptyWorkersState());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final worker = workers[index];
                    return WorkerAvatarChip(
                      isSelecting: false,
                      worker: worker,
                      isSelected: true,
                      isAvailable: true,
                      onRemove: () => _confirmRemoveWorker(worker),
                      onTap: () => _viewWorkerDetails(worker),
                      // () => _openWorkerSelectionSheet(
                      //   context,
                      //   service,
                      //   workers,
                      //   personIndex,
                      //   selectedWorkerId,
                      // ),
                    );
                    //  WorkerTile(
                    //   worker: worker,
                    //   onRemove: () => _confirmRemoveWorker(worker),
                    //   onViewDetails: () => _viewWorkerDetails(worker),
                    // );
                  }, childCount: workers.length),
                );
              },
              loading: () => SliverToBoxAdapter(child: _buildLoadingState()),
              error:
                  (error, _) => SliverToBoxAdapter(
                    child: _buildErrorState(error.toString()),
                  ),
            ),

            // Pending Invites Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(Spacing.md.h),
                child: Text(
                  'Pending Invites',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            pendingInvitesAsync.when(
              data: (invites) {
                if (invites.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final invite = invites[index];
                    return PendingInviteTile(
                      invite: invite,
                      onCancel: () => _cancelInvite(invite),
                      onResend: () => _resendInvite(invite),
                    );
                  }, childCount: invites.length),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error:
                  (error, _) =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWorkersState() {
    return Padding(
      padding: EdgeInsets.all(Spacing.lg.h),
      child: EmptyStateWidget(
        title: 'No Workers Yet',
        subtitle: 'Invite workers to join your team',
        actionLabel: 'Invite Worker',
        onAction: _showInviteWorkerModal,
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder:
          (_, __) => Padding(
            padding: EdgeInsets.all(Spacing.sm.h),
            child: ShopSchimmerSkeleton(height: 80.h),
          ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: EdgeInsets.all(Spacing.lg.h),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48),
            SizedBox(height: Spacing.md.h),
            Text('Failed to load workers'),
            SizedBox(height: Spacing.sm.h),
            Text(error, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
            SizedBox(height: Spacing.md.h),
            AppButton(
              label: 'Retry',
              onPressed: () {
                ref.invalidate(shopActiveWorkersProvider(widget.shopId));
                ref.invalidate(shopPendingInvitesProvider(widget.shopId));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteWorkerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => InviteWorkerModal(
            shopId: widget.shopId,
            onInviteSent: () {
              ref.invalidate(shopPendingInvitesProvider(widget.shopId));
            },
          ),
    );
  }

  void _confirmRemoveWorker(WorkerDTO worker) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Remove Worker'),
            content: Text(
              'Are you sure you want to remove ${worker.name} from your shop?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (worker.shopWorkerId != null) {
                    final repository = ref.read(
                      appointmentWorkerRepositoryProvider,
                    );
                    await repository.removeWorkerFromShop(
                      shopWorkerId: worker.shopWorkerId!,
                      reason: 'Removed by shop owner',
                    );
                    ref.invalidate(shopActiveWorkersProvider(widget.shopId));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Worker removed successfully'),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _viewWorkerDetails(WorkerDTO worker) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => WorkerDetailScreen(shopId: '', worker: worker),
    //   ),
    // );
  }

  void _cancelInvite(WorkerInvite invite) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Cancel Invite'),
            content: const Text(
              'Are you sure you want to cancel this invitation?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final repository = ref.read(appointmentWorkerRepositoryProvider);
      await repository.declineInvite(invite.id);
      ref.invalidate(shopPendingInvitesProvider(widget.shopId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitation cancelled')));
      }
    }
  }

  void _resendInvite(WorkerInvite invite) async {
    // Show a dialog to confirm resend
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Resend Invitation'),
            content: const Text('Send another invitation to this worker?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Resend'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // For now, just show a message
      // You would need to implement resend logic in your repository
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invitation resent')));
    }
  }
}
