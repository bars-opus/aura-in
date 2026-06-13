import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_addon_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_addons_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

class ServiceAddonsSheet extends ConsumerWidget {
  final AppointmentSlotDTO service;
  final String currency;
  final VoidCallback onDone;

  const ServiceAddonsSheet({
    super.key,
    required this.service,
    required this.currency,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addonsAsync = ref.watch(slotAddonsProvider(service.id));
    final selected = ref.watch(selectedAddonsProvider
        .select((m) => m[service.id] ?? const <ServiceAddonDTO>[]));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text('Add-ons for ${service.serviceName}',
            style: theme.textTheme.titleMedium),
        actions: [
          TextButton(
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ],
      ),
      body: addonsAsync.when(
        loading: () => const Center(child: CircularLoadingIndicator()),
        error: (_, __) => EmptyStateWidget(
          title: 'Could not load add-ons',
          icon: Icons.cloud_off,
        ),
        data: (addons) {
          if (addons.isEmpty) {
            return Column(
              children: [
                EmptyStateWidget(
                  title: 'No add-ons available',
                  subtitle: 'This service has no optional extras',
                  icon: Icons.add_circle_outline,
                ),
                Gap(Spacing.md.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                  child: AppButton(
                    label: 'Continue',
                    onPressed: onDone,
                    width: double.infinity,
                  ),
                ),
              ],
            );
          }

          final extraMinor = selected.fold(0, (s, a) => s + a.priceMinor);
          final extraMins =
              selected.fold(0, (s, a) => s + (a.durationMinutes ?? 0));

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(Spacing.md.h),
                  itemCount: addons.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final addon = addons[index];
                    final isSelected =
                        selected.any((a) => a.id == addon.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => ref
                          .read(selectedAddonsProvider.notifier)
                          .toggle(service.id, addon),
                      title: Text(addon.name,
                          style: theme.textTheme.bodyMedium),
                      subtitle: Text(
                        [
                          '+${formatMoney(addon.priceMinor, currency)}',
                          if (addon.durationMinutes != null &&
                              addon.durationMinutes! > 0)
                            '+${addon.durationMinutes} min',
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      activeColor: theme.colorScheme.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              if (selected.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Spacing.md.w, vertical: Spacing.sm.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    border: Border(
                        top: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${selected.length} add-on${selected.length > 1 ? 's' : ''} selected',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '+${formatMoney(extraMinor, currency)}'
                              '${extraMins > 0 ? ' · +$extraMins min' : ''}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        label: 'Done',
                        onPressed: onDone,
                        size: ButtonSize.small,
                      ),
                    ],
                  ),
                ),
              if (selected.isEmpty)
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.md.h),
                    child: AppButton(
                      label: 'Skip, no extras',
                      onPressed: onDone,
                      width: double.infinity,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
