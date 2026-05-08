// lib/features/freelancer/presentation/widgets/freelancer_service_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';

/// Widget displaying freelancer's services
class FreelancerServiceList extends ConsumerWidget {
  final String freelancerId;

  const FreelancerServiceList({
    super.key,
    required this.freelancerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(freelancerServicesProvider(freelancerId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services & Pricing',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              separatorBuilder: (_, __) => Gap(Spacing.sm.h),
              itemBuilder: (context, index) {
                final service = services[index];
                return CardInkWell(
                  onTap: () {
                    // TODO: Show service details
                  },
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: Row(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.content_cut,
                          color: colorScheme.primary,
                          size: 24.h,
                        ),
                      ),
                      Gap(Spacing.md.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.serviceName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (service.description != null)
                              Text(
                                service.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              '${service.duration} min',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${service.price.toStringAsFixed(0)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (service.maxClients > 1)
                            Text(
                              'Up to ${service.maxClients} clients',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
