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
    final selected = ref.watch(
      selectedAddonsProvider.select(
        (m) => m[service.id] ?? const <ServiceAddonDTO>[],
      ),
    );

    // Hosted inside BottomSheetUtils.showDocumentationBottomSheet, which provides
    // a Scaffold + bounded Expanded host AND a PrimaryScrollController for the
    // DraggableScrollableSheet. A LayoutBuilder anchors a finite width so the
    // footer Row (which uses Expanded) always has bounded cross-axis constraints —
    // without it, certain drag frames pass unbounded width and the decorated
    // footer Container fails layout ("RenderBox was not laid out").
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
        return SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: Spacing.sm.h),
                child: Text(
                  'Add-ons for ${service.serviceName}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Flexible(
                child: addonsAsync.when(
                  loading:
                      () => const Center(child: CircularLoadingIndicator()),
                  error:
                      (_, __) => EmptyStateWidget(
                        title: 'Could not load add-ons',
                        icon: Icons.cloud_off,
                      ),
                  data: (addons) {
                    if (addons.isEmpty) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmptyStateWidget(
                            title: 'No add-ons available',
                            subtitle: 'This service has no optional extras',
                            icon: Icons.add_circle_outline,
                          ),
                          Gap(Spacing.md.h),
                          AppButton(
                            label: 'Continue',
                            onPressed: onDone,
                            width: double.infinity,
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                      itemCount: addons.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final addon = addons[index];
                        final isSelected = selected.any(
                          (a) => a.id == addon.id,
                        );
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isSelected,
                          onChanged:
                              (_) => ref
                                  .read(selectedAddonsProvider.notifier)
                                  .toggle(service.id, addon),
                          title: Text(
                            addon.name,
                            style: theme.textTheme.bodyMedium,
                          ),
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
                    );
                  },
                ),
              ),
              _buildFooter(context, theme, selected),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter(
    BuildContext context,
    ThemeData theme,
    List<ServiceAddonDTO> selected,
  ) {
    if (selected.isEmpty) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: Spacing.md.h),
          child: AppButton(
            elevation: 0,
            label: 'Skip, no extras',
            onPressed: onDone,
            size: ButtonSize.small,
            width: double.infinity,
            padding: Spacing.horizontalMd,
            height: 40.h,
          ),
        ),
      );
    }

    final extraMinor = selected.fold(0, (s, a) => s + a.priceMinor);
    final extraMins = selected.fold(0, (s, a) => s + (a.durationMinutes ?? 0));

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.only(top: Spacing.sm.h),
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SizedBox(
          height: 100,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(Spacing.sm.w),
              // AppButton defaults to width: double.infinity, which is unbounded
              // inside a Row — give it an explicit finite width.
              AppButton(
                label: 'Done',
                onPressed: onDone,
                size: ButtonSize.small,
                width: 96.w,
                height: 40.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
