// lib/features/shop/workers/presentation/screens/assign_workers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/providers/booking_data_providers.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/invite_worker_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/service_worker_assignment_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/appointmetn_workers_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/services_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';
import 'package:uuid/uuid.dart';

class AppointmentAssignWorkersScreen extends ConsumerStatefulWidget {
  final String shopId;

  const AppointmentAssignWorkersScreen({super.key, required this.shopId});

  @override
  ConsumerState<AppointmentAssignWorkersScreen> createState() =>
      _AppointmentAssignWorkersScreenState();
}

class _AppointmentAssignWorkersScreenState
    extends ConsumerState<AppointmentAssignWorkersScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final services = ref.watch(servicesProvider);
    final workersAsync = ref.watch(shopActiveWorkersProvider(widget.shopId));
    final slotAssignmentsAsync = ref.watch(
      slotWorkerAssignmentsProvider(shopId: widget.shopId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Workers to Services'),
        actions: [
          if (services.isNotEmpty)
            TextButton(
              onPressed: _saveAllAssignments,
              child: const Text('Save All'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(servicesProvider);
          ref.invalidate(shopActiveWorkersProvider(widget.shopId));
          ref.invalidate(slotWorkerAssignmentsProvider(shopId: widget.shopId));
        },
        child: workersAsync.when(
          data: (workers) {
            if (workers.isEmpty) {
              return _buildNoWorkersState();
            }

            return Column(
              children: [
                // Info banner
                Container(
                  margin: EdgeInsets.all(Spacing.md.h),
                  padding: EdgeInsets.all(Spacing.sm.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16.sp,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: Spacing.sm.w),
                      Expanded(
                        child: Text(
                          'Assign workers to services. Only services with "Allow worker selection" enabled will show worker options to customers.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      services.isEmpty
                          ? _buildNoServicesState()
                          : ListView.builder(
                            padding: EdgeInsets.all(Spacing.md.h),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final service = services[index];
                              return ServiceWorkerAssignmentTile(
                                service: service,
                                availableWorkers: workers,
                                onWorkersChanged: (selectedWorkerIds) {
                                  _updateServiceWorkers(
                                    service,
                                    selectedWorkerIds,
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error.toString()),
        ),
      ),
    );
  }

  Widget _buildNoWorkersState() {
    return Center(
      child: EmptyStateWidget(
        title: 'No Workers Available',
        subtitle: 'Invite workers to your shop first',
        actionLabel: 'Invite Worker',
        onAction: _showInviteWorkerModal, // ✅ Call the method
      ),
    );
  }

  Widget _buildNoServicesState() {
    return Center(
      child: EmptyStateWidget(
        title: 'No Services Yet',
        subtitle: 'Create services first before assigning workers',
        actionLabel: 'Create Service',
        onAction: () {
          Navigator.pop(context);
          // Navigate to service creation
        },
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
              // Refresh the workers list after invite is sent
              ref.invalidate(shopActiveWorkersProvider(widget.shopId));
              ref.invalidate(shopPendingInvitesProvider(widget.shopId));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invitation sent successfully')),
                );
              }
            },
          ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder:
          (_, __) => Padding(
            padding: EdgeInsets.all(Spacing.sm.h),
            child: ShopSchimmerSkeleton(height: 100.h),
          ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48),
          SizedBox(height: Spacing.md.h),
          Text('Failed to load data'),
          SizedBox(height: Spacing.sm.h),
          Text(error, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
          SizedBox(height: Spacing.md.h),
          AppButton(
            label: 'Retry',
            onPressed: () {
              ref.invalidate(servicesProvider);
              ref.invalidate(shopActiveWorkersProvider(widget.shopId));
            },
          ),
        ],
      ),
    );
  }

  void _updateServiceWorkers(
    AppointmentSlotDTO service,
    List<String> selectedWorkerIds,
  ) {
    // Update local state - will be saved when user taps "Save All"
    // For now, just update the service in the provider
    final index = ref.read(servicesProvider).indexOf(service);
    if (index != -1) {
      final updatedService = AppointmentSlotDTO(
        serviceName: service.serviceName,
        price: service.price,
        id: service?.id ?? '',
        duration: service.duration,
        daysOfWeek: service.daysOfWeek,
        description: service.description,
        slotType: 'in-person', // or get from a dropdown if needed
        maxClients: service.maxClients,
        selectPreferredWorker: selectedWorkerIds.isNotEmpty,
        workerIds: service.workerIds,
        bufferMinutes: service.bufferMinutes,
        serviceType: service.serviceType,
      );
      ref.read(servicesProvider.notifier).updateService(index, updatedService);
    }
  }

  void _saveAllAssignments() async {
    // Show loading indicator
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saving assignments...')));

    try {
      // The services provider already has the updated assignments
      // We need to persist them to the database
      final repository = ref.read(shopCreationRepositoryProvider);
      final draft = ref.read(shopCreationProvider);

      // Update the draft with latest service assignments
      await repository.updateServiceWorkerAssignments(
        shopId: widget.shopId,
        services: ref.read(servicesProvider),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignments saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
