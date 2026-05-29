// lib/features/dashboard/presentation/screens/tools_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/link/providers/link_providers.dart';
import 'package:nano_embryo/core/link/widgets/shareable_link_section.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_details_provider.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/export_reports_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/reminder_settings_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/tools/kpi_card.dart';
import 'package:nano_embryo/payment/presentation/screens/payment_settings_screen.dart';

class ToolsScreen extends ConsumerWidget {
  final String shopId;

  const ToolsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add the method:
    void _openPromotions(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PromotionsScreen(shopId: shopId),
        ),
      );
    }

    // Add the method:
    void _openExport(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExportReportsScreen(shopId: shopId),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final shopDetailsAsync = ref.watch(shopDetailsProvider(shopId));
    final shopName = shopDetailsAsync.maybeWhen(
      data: (shop) => shop?.shopName ?? '',
      orElse: () => '',
    );
    final bookingSlug = shopDetailsAsync.maybeWhen(
      data: (shop) => shop?.bookingSlug,
      orElse: () => null,
    );

    return Scaffold(
      body: CardInkWell(
        elevation: 0,
        onTap: () {},
        // borderRadius: BorderRadius.circular(30),
        margin: EdgeInsets.all(Spacing.md),
        child: ListView(
          children: [
            ShareableLinkSection(
              currentSlug: bookingSlug,
              entityName: shopName,
              onEditSlug: (newSlug) async {
                final svc = ref.read(linkServiceProvider);
                final result = await svc.createShopLink(
                  shopId: shopId,
                  customSlug: newSlug,
                  metadata: {'name': shopName},
                );
                if (!result.success) {
                  throw Exception(result.error ?? 'Failed to update slug');
                }
                // Trigger from Plan A syncs shops.booking_slug; reload to pick
                // it up in the UI.
                await ref
                    .read(shopDetailsProvider(shopId).notifier)
                    .loadShop(shopId);
              },
            ),
            Gap(Spacing.sm.h),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Admin tools',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Gap(Spacing.sm.h),
            AppDivider(),

            SizedBox(
              height: 6 * 70,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                itemCount: 6, // Number of tools
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return KpiCard(
                        title: 'Configure →',
                        value: 'Automated Reminders',
                        icon: Icons.notifications_active,
                        iconColor: colorScheme.error,
                        onTap: () => _openReminderSettings(context),

                        // trendUpIsPositive: data.trendUpIsPositive,
                      );
                    case 1:
                      return KpiCard(
                        title: 'Manage →',
                        value: 'Promotions Manager',
                        icon: Icons.local_offer,
                        iconColor: colorScheme.success,
                        onTap: () => _openPromotions(context),

                        // trendUpIsPositive: data.trendUpIsPositive,
                      );

                    case 2:
                      return KpiCard(
                        title: 'Export →',
                        value: 'Export Reports',
                        icon: Icons.download,
                        iconColor: colorScheme.warning,
                        onTap: () => _openExport(context),

                        // trendUpIsPositive: data.trendUpIsPositive,
                      );

                    case 3:
                      return KpiCard(
                        title: 'Configure →',
                        value: 'Payment Settings',
                        icon: Icons.payment,
                        iconColor: colorScheme.info,
                        onTap: () => _openExport(context),

                        // trendUpIsPositive: data.trendUpIsPositive,
                      );

                    case 4:
                      return KpiCard(
                        title: 'Coming Soon',
                        value: 'Business Hours',
                        icon: Icons.access_time,
                        iconColor: colorScheme.error,
                        onTap: () => _openExport(context),

                        // trendUpIsPositive: data.trendUpIsPositive,
                      );

                    case 5:
                      return KpiCard(
                        title: 'Coming Soon',
                        value: 'Service Management',
                        icon: Icons.access_time,
                        iconColor: colorScheme.error,
                        onTap: () => _openExport(context),

                        // trendUpIsPositive: data.trendUpIsPositive,
                      );

                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReminderSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderSettingsScreen(shopId: shopId),
      ),
    );
  }
}
