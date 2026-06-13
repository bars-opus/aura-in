// lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart
//
// Tools-tab service editor. Hosts the refactored ServiceFormModal
// (Phase 11 locked correction 8) and wires its onSave callback to a
// single Postgrest INSERT (create mode) or UPDATE (edit mode). Both
// are atomic by construction (single statements); no RPC needed for
// the create/edit paths.
//
// Archive is NOT handled here — it lives on ServiceManagementScreen's
// row action. Doing the destructive op from the list screen keeps the
// edit screen's surface small.
//
// The screen reads the shop's openingHours from `shopDetailsProvider`
// and passes them explicitly as ServiceFormModal.availableHours. This
// replaces the global `hoursProvider` read the form widget used to do,
// which could silently pick up another shop's draft hours.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_details_provider.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/pricing_overrides_list_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceEditScreen extends ConsumerWidget {
  final String shopId;
  final AppointmentSlotDTO? initial;

  const ServiceEditScreen({
    super.key,
    required this.shopId,
    this.initial,
  });

  bool get _isEdit => initial != null;

  Future<void> _handleSave(
    BuildContext context,
    AppointmentSlotDTO dto,
  ) async {
    final supabase = Supabase.instance.client;
    try {
      if (_isEdit) {
        // Atomic single-statement UPDATE keyed on the existing id.
        await supabase
            .from('appointment_slots')
            .update(_rowFor(dto, includeId: false))
            .eq('id', dto.id);
      } else {
        // Atomic single-statement INSERT. We do NOT pass dto.id (empty
        // string in create mode); the DB default generates the UUID.
        await supabase
            .from('appointment_slots')
            .insert({..._rowFor(dto, includeId: false), 'shop_id': shopId});
      }
      if (!context.mounted) return;
      Snackbar.success(
        context,
        _isEdit ? 'Service updated' : 'Service added',
      );
      Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'service.save_failed',
        fields: {
          'shop_id': shopId,
          'slot_id': dto.id,
          'edit_mode': _isEdit,
          'error': e.toString(),
        },
      );
      if (!context.mounted) return;
      Snackbar.error(context, ServiceSaveFailedException().userMessage);
    } catch (e) {
      AppLogger.warn(
        'service.save_failed',
        fields: {
          'shop_id': shopId,
          'slot_id': dto.id,
          'edit_mode': _isEdit,
          'error': e.toString(),
        },
      );
      if (!context.mounted) return;
      Snackbar.error(context, ServiceSaveFailedException().userMessage);
    }
  }

  /// Build the row map. We canonicalize column names here (the existing
  /// `AppointmentSlotDTO.toJson()` uses camelCase for `bufferMinutes`
  /// — that doesn't match the live DB column `buffer_minutes`).
  Map<String, dynamic> _rowFor(
    AppointmentSlotDTO dto, {
    required bool includeId,
  }) {
    final row = <String, dynamic>{
      'service_name': dto.serviceName,
      'service_type': dto.serviceType,
      'description': dto.description,
      'duration': dto.duration,
      'price': dto.price,
      'slot_type': dto.slotType,
      'max_clients': dto.maxClients,
      'days_of_week': dto.daysOfWeek,
      'select_preferred_worker': dto.selectPreferredWorker,
      'worker_ids': dto.workerIds,
      'buffer_before_minutes': dto.bufferBeforeMinutes,
      'buffer_minutes': dto.bufferMinutes,
      'is_online_booking_enabled': dto.isOnlineBookingEnabled,
    };
    if (includeId) row['id'] = dto.id;
    return row;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopDetailsProvider(shopId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit service' : 'New service'),
        actions: [
          if (_isEdit && initial != null)
            IconButton(
              tooltip: AppLocalizations.of(context)!.pricingOverridesTitle,
              icon: const Icon(Icons.price_change_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PricingOverridesListScreen(
                    shopId: shopId,
                    slot: initial!,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: shopAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            "We couldn't load this shop.",
            style: theme.textTheme.titleMedium,
          ),
        ),
        data: (shop) {
          final hours = shop == null
              ? const <OpeningHoursDraft>[]
              : shop.openingHours
                  .map((h) => OpeningHoursDraft(
                        dayOfWeek: h.dayOfWeek,
                        opensAt: h.opensAt,
                        closesAt: h.closesAt,
                        isClosed: h.isClosed,
                      ))
                  .toList();
          return ServiceFormModal(
            initialService: initial,
            shopId: shopId,
            availableWorkers: shop?.workers,
            availableHours: hours,
            onSave: (dto) => _handleSave(context, dto),
          );
        },
      ),
    );
  }
}
