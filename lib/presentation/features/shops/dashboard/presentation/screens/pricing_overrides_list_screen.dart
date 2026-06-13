// lib/presentation/features/shops/dashboard/presentation/screens/pricing_overrides_list_screen.dart
//
// Phase 15 — owner-facing list of pricing overrides for a single slot.
//
// Reached from ServiceEditScreen's AppBar IconButton (Wave 3.4). Watches
// `pricingOverridesProvider(slotId)`. Tap a row → edit form. FAB → create.
// PopupMenu → Edit / Archive (archive shows confirm dialog).
//
// Wave 5 swaps the hard-coded EN strings for AppLocalizations getters.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/pricing_override_form_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/pricing_overrides_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

class PricingOverridesListScreen extends ConsumerWidget {
  final String shopId;
  final AppointmentSlotDTO slot;

  const PricingOverridesListScreen({
    super.key,
    required this.shopId,
    required this.slot,
  });

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    PricingOverrideDTO? rule,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PricingOverrideFormScreen(
          slot: slot,
          rule: rule,
        ),
      ),
    );
    ref.invalidate(pricingOverridesProvider(slot.id));
  }

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    PricingOverrideDTO rule,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l.pricingOverrideArchiveConfirmTitle),
          content: Text(l.pricingOverrideArchiveConfirmBody(rule.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.pricingOverrideArchiveConfirmCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.pricingOverrideArchiveConfirmArchive),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    final repo = ref.read(dashboardRepositoryProvider);
    try {
      await repo.archivePricingOverride(overrideId: rule.id);
      ref.invalidate(pricingOverridesProvider(slot.id));
      if (!context.mounted) return;
      Snackbar.success(context, loc.pricingOverrideArchiveSuccess);
    } on PricingOverrideException catch (e) {
      AppLogger.warn(
        'pricing_override.archive_failed',
        fields: {'override_id': rule.id, 'code': e.code},
      );
      if (!context.mounted) return;
      Snackbar.error(context, e.userMessage);
    } catch (e) {
      AppLogger.warn(
        'pricing_override.archive_failed',
        fields: {'override_id': rule.id, 'error': e.toString()},
      );
      if (!context.mounted) return;
      Snackbar.error(context, loc.pricingOverrideArchiveFailed);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final overridesAsync = ref.watch(pricingOverridesProvider(slot.id));

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          loc.pricingOverridesTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: loc.pricingOverridesRefresh,
            onPressed: () => ref.invalidate(pricingOverridesProvider(slot.id)),
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: Text(loc.pricingOverridesNewCta),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pricingOverridesProvider(slot.id));
          await ref.read(pricingOverridesProvider(slot.id).future);
        },
        child: overridesAsync.when(
          loading: () => const Center(child: CircularLoadingIndicator()),
          error: (e, _) => _ErrorState(
            message: loc.pricingOverridesLoadFailed,
            retryLabel: loc.pricingOverridesRetry,
            onRetry: () => ref.invalidate(pricingOverridesProvider(slot.id)),
          ),
          data: (overrides) {
            if (overrides.isEmpty) {
              return _EmptyState(
                serviceName: slot.serviceName,
                onCreate: () => _openForm(context, ref),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                Spacing.md.w,
                Spacing.md.h,
                Spacing.md.w,
                Spacing.xl.h * 2,
              ),
              itemCount: overrides.length,
              separatorBuilder: (_, __) => Gap(Spacing.sm.h),
              itemBuilder: (context, i) {
                final o = overrides[i];
                return _OverrideRow(
                  rule: o,
                  basePrice: slot.price,
                  onEdit: () => _openForm(context, ref, rule: o),
                  onArchive: () => _confirmArchive(context, ref, o),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String serviceName;
  final VoidCallback onCreate;

  const _EmptyState({required this.serviceName, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: Spacing.lg.w, vertical: 80.h),
      children: [
        Icon(
          Icons.price_change_outlined,
          size: 64.w,
          color: scheme.onSurface.withOpacity(0.3),
        ),
        Gap(Spacing.md.h),
        Text(
          loc.pricingOverridesEmptyTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        Gap(Spacing.xs.h),
        Text(
          loc.pricingOverridesEmptyBody(serviceName),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
          ),
        ),
        Gap(Spacing.lg.h),
        Center(
          child: ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: Text(loc.pricingOverridesEmptyCta),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: Spacing.lg.w, vertical: 80.h),
      children: [
        Icon(Icons.error_outline, size: 48.w, color: scheme.error),
        Gap(Spacing.md.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        Gap(Spacing.lg.h),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ),
      ],
    );
  }
}

class _OverrideRow extends StatelessWidget {
  final PricingOverrideDTO rule;
  final int basePrice; // minor units
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const _OverrideRow({
    required this.rule,
    required this.basePrice,
    required this.onEdit,
    required this.onArchive,
  });

  Map<int, String> _dayNames(AppLocalizations loc) => {
        1: loc.pricingOverrideDayShortMon,
        2: loc.pricingOverrideDayShortTue,
        3: loc.pricingOverrideDayShortWed,
        4: loc.pricingOverrideDayShortThu,
        5: loc.pricingOverrideDayShortFri,
        6: loc.pricingOverrideDayShortSat,
        7: loc.pricingOverrideDayShortSun,
      };

  IconData get _kindIcon {
    switch (rule.kind) {
      case AdjustmentKind.percentDiscount:
      case AdjustmentKind.fixedDiscount:
        return Icons.trending_down;
      case AdjustmentKind.percentSurcharge:
      case AdjustmentKind.fixedSurcharge:
        return Icons.trending_up;
    }
  }

  String _formatTime(String hms) {
    // Postgres TIME serializes as "HH:mm:ss" — strip seconds for display.
    final parts = hms.split(':');
    if (parts.length < 2) return hms;
    return '${parts[0]}:${parts[1]}';
  }

  String _summary(AppLocalizations loc) {
    final day = rule.dayOfWeek == null
        ? loc.pricingOverrideAllWeek
        : (_dayNames(loc)[rule.dayOfWeek] ?? '?');
    final window =
        '${_formatTime(rule.timeWindowStart)}–${_formatTime(rule.timeWindowEnd)}';
    final adj = _adjustmentLabel();
    return '$day · $window · $adj';
  }

  String _adjustmentLabel() {
    switch (rule.kind) {
      case AdjustmentKind.percentDiscount:
        return '${rule.value.toStringAsFixed(0)}% off';
      case AdjustmentKind.percentSurcharge:
        return '+${rule.value.toStringAsFixed(0)}%';
      case AdjustmentKind.fixedDiscount:
        return '−${rule.value.toStringAsFixed(2)}';
      case AdjustmentKind.fixedSurcharge:
        return '+${rule.value.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final tint = rule.kind.isDiscount ? scheme.tertiary : scheme.error;
    return Card(
      elevation: 0,
      color: scheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(Spacing.md.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: tint.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_kindIcon, color: tint, size: IconSizes.md.w),
              ),
              Gap(Spacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Gap(2.h),
                    Text(
                      _summary(loc),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: loc.pricingOverrideRowActionsTooltip,
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'archive') onArchive();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(loc.pricingOverrideRowEdit),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(loc.pricingOverrideRowArchive),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
