import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/duration_utils.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/service_selection/service_category_chips.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_addon_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_template_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_addons_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_templates_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

class ServiceTemplatesSheet extends ConsumerStatefulWidget {
  final String shopType;
  final String? currencySymbol;
  final void Function(AppointmentSlotDTO prefilled) onTemplateSelected;

  /// When true, renders as a plain scrollable widget (no Scaffold/AppBar).
  final bool inline;

  const ServiceTemplatesSheet({
    super.key,
    required this.shopType,
    required this.onTemplateSelected,
    this.currencySymbol,
    this.inline = false,
  });

  @override
  ConsumerState<ServiceTemplatesSheet> createState() =>
      _ServiceTemplatesSheetState();
}

class _ServiceTemplatesSheetState extends ConsumerState<ServiceTemplatesSheet> {
  String _selectedCategory = 'All';

  Future<void> _selectTemplate(
    BuildContext context,
    ServiceTemplateDTO t,
  ) async {
    final templateAddons = await ref
        .read(templateAddonsProvider(t.id).future)
        .catchError((_) => <dynamic>[]);

    final pendingAddons =
        templateAddons
            .map(
              (a) => ServiceAddonDTO(
                id: '',
                slotId: '',
                name: a.name as String,
                priceMinor: (a.suggestedPriceMinor as int?) ?? 0,
                durationMinutes: a.durationMinutes as int?,
              ),
            )
            .toList();

    final prefilled = AppointmentSlotDTO(
      id: '',
      serviceName: t.serviceName,
      serviceType: t.serviceType,
      duration: DurationUtils.format(Duration(minutes: t.durationMinutes)),
      price: t.suggestedPriceMinor ?? 0,
      slotType: 'in-person',
      maxClients: 1,
      daysOfWeek: const [],
      selectPreferredWorker: false,
      workerIds: const [],
      bufferMinutes: 0,
      description: t.description,
      pendingAddons: pendingAddons,
    );

    if (!context.mounted) return;
    if (!widget.inline) Navigator.pop(context);
    widget.onTemplateSelected(prefilled);
  }

  List<String> _extractCategories(List<ServiceTemplateDTO> templates) {
    final names = templates.map((t) => t.serviceName).toSet().toList()..sort();
    return names;
  }

  List<ServiceTemplateDTO> _filtered(List<ServiceTemplateDTO> templates) {
    if (_selectedCategory == 'All') return templates;
    return templates.where((t) => t.serviceName == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(serviceTemplatesProvider(widget.shopType));

    final body = async.when(
      loading: () => const Center(child: CircularLoadingIndicator()),
      error:
          (_, __) => EmptyStateWidget(
            title: 'Could not load templates',
            subtitle: 'Check your connection and try again',
            icon: Icons.cloud_off,
          ),
      data: (templates) {
        if (templates.isEmpty) {
          return EmptyStateWidget(
            title: 'No templates for ${widget.shopType}',
            subtitle: 'Add services manually',
            icon: Icons.content_cut,
          );
        }

        final categories = _extractCategories(templates);
        final visible = _filtered(templates);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category chips ────────────────────────────────────────────
            ServiceCategoryChips(
              categories: categories,
              selectedCategory: _selectedCategory,
              showAllOption: true,
              onCategorySelected:
                  (cat) => setState(() => _selectedCategory = cat),
            ),
            Gap(Spacing.sm.h),

            // ── Template cards ────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w,
                  vertical: Spacing.sm.h,
                ),
                itemCount: visible.length,
                // separatorBuilder: (_, __) => Gap(Spacing.sm.h),
                itemBuilder: (context, index) {
                  final t = visible[index];
                  return _TemplateCard(
                    template: t,
                    currencySymbol: widget.currencySymbol,
                    onTap: () => _selectTemplate(context, t),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    if (widget.inline) return body;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Templates for ${widget.shopType}',
          style: theme.textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: body,
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final ServiceTemplateDTO template;
  final String? currencySymbol;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = currencySymbol ?? '';
    final hasPrice = (template.suggestedPriceMinor ?? 0) > 0;
    final priceLabel =
        hasPrice
            ? '$currency${(template.suggestedPriceMinor! / 100).toStringAsFixed(2)}'
            : null;

    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm),
      onTap: onTap,
      child: Row(
        children: [
          // Icon badge
          Icon(
            Icons.content_cut,
            size: 40.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          Gap(Spacing.sm.w),

          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.serviceType,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (priceLabel != null)
                      Text(
                        priceLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                Gap(2.h),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 12.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    Gap(4.w),
                    Text(
                      '${template.durationMinutes} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (template.description != null) ...[
                      Text(
                        '  ·  ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          template.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Gap(Spacing.sm.w),
          Icon(
            Icons.add_circle_outline,
            color: colorScheme.primary,
            size: 22.sp,
          ),
        ],
      ),
    );
  }
}
