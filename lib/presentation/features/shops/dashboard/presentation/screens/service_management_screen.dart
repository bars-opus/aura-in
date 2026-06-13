// lib/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart
//
// Tools-tab service management list. Lists active (non-archived)
// services for a shop. Each row links to ServiceEditScreen for edit;
// the FAB launches the same screen in create mode. Archive flows
// through a confirmation dialog.
//
// Data is sourced from `activeServicesProvider(shopId)` (a
// FutureProvider.family); the controller-less FutureProvider shape is
// intentional — the only mutations on this screen are archive and
// (after returning from ServiceEditScreen) save, both of which simply
// `ref.invalidate(activeServicesProvider(shopId))` to refetch.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/confirmation_dialog.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

class ServiceManagementScreen extends ConsumerWidget {
  final String shopId;
  const ServiceManagementScreen({super.key, required this.shopId});

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    AppointmentSlotDTO? initial,
  }) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceEditScreen(shopId: shopId, initial: initial),
      ),
    );
    if (result == true) {
      ref.invalidate(activeServicesProvider(shopId));
    }
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    AppointmentSlotDTO dto,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      type: ConfirmationType.warning,
      title: 'Archive service?',
      message:
          '"${dto.serviceName}" will no longer be bookable. Existing bookings are unaffected.',
      confirmText: 'Archive',
    );
    if (confirmed != true) return;
    try {
      await ref.read(dashboardRepositoryProvider).archiveAppointmentSlot(dto.id);
      if (!context.mounted) return;
      ref.invalidate(activeServicesProvider(shopId));
      Snackbar.success(context, 'Service archived');
    } on ServiceManagementException catch (e) {
      if (!context.mounted) return;
      Snackbar.error(context, e.userMessage);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(activeServicesProvider(shopId));
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Service Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, ref),
        tooltip: 'Add service',
        child: const Icon(Icons.add),
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "We couldn't load your services.",
                  style: theme.textTheme.titleMedium,
                ),
                Gap(Spacing.md.h),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(activeServicesProvider(shopId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.lg.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cut,
                      size: 56.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    Gap(Spacing.md.h),
                    Text(
                      'No services yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    Gap(Spacing.sm.h),
                    Text(
                      'Tap + to add one.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
            itemBuilder: (context, i) {
              final svc = services[i];
              return ListTile(
                title: Text(svc.serviceName),
                subtitle: Text(
                  '${(svc.price / 100).toStringAsFixed(2)} · ${svc.duration}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'archive') _archive(context, ref, svc);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'archive',
                      child: Text('Archive'),
                    ),
                  ],
                ),
                onTap: () => _openEditor(context, ref, initial: svc),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: services.length,
          );
        },
      ),
    );
  }
}
