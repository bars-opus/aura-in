import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_icon_button.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_template_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_templates_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

class ServiceTemplatesSheet extends ConsumerWidget {
  final String shopType;
  final String? currencySymbol;
  final void Function(AppointmentSlotDTO prefilled) onTemplateSelected;

  const ServiceTemplatesSheet({
    super.key,
    required this.shopType,
    required this.onTemplateSelected,
    this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(serviceTemplatesProvider(shopType));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text('Templates for $shopType', style: theme.textTheme.titleMedium),
        leading: AppIconButton(
          icon: Icons.close,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularLoadingIndicator()),
        error: (_, __) => EmptyStateWidget(
          title: 'Could not load templates',
          subtitle: 'Check your connection and try again',
          icon: Icons.cloud_off,
        ),
        data: (templates) {
          if (templates.isEmpty) {
            return EmptyStateWidget(
              title: 'No templates for $shopType',
              subtitle: 'Add services manually',
              icon: Icons.content_cut,
            );
          }

          // Group by service_name for section headers.
          final grouped = <String, List<ServiceTemplateDTO>>{};
          for (final t in templates) {
            grouped.putIfAbsent(t.serviceName, () => []).add(t);
          }

          return ListView(
            padding: EdgeInsets.all(Spacing.md.h),
            children: [
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: EdgeInsets.only(top: Spacing.md.h, bottom: Spacing.xs.h),
                  child: Text(
                    entry.key,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                for (final t in entry.value)
                  ListTile(
                    title: Text(t.serviceType),
                    subtitle: Text(
                      '${t.durationMinutes} min'
                      '${t.description != null ? ' · ${t.description}' : ''}',
                    ),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      final prefilled = AppointmentSlotDTO(
                        id: '',
                        serviceName: t.serviceName,
                        serviceType: t.serviceType,
                        duration: '${t.durationMinutes} minutes',
                        price: t.suggestedPriceMinor ?? 0,
                        slotType: 'in-person',
                        maxClients: 1,
                        daysOfWeek: const [],
                        selectPreferredWorker: false,
                        workerIds: const [],
                        bufferMinutes: 0,
                        description: t.description,
                      );
                      Navigator.pop(context);
                      onTemplateSelected(prefilled);
                    },
                  ),
                const Divider(height: 1),
              ],
              Gap(Spacing.lg.h),
            ],
          );
        },
      ),
    );
  }
}
