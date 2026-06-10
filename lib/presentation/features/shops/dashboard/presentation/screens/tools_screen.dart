// lib/features/dashboard/presentation/screens/tools_screen.dart
//
// Tools tab for the shop-owner dashboard. Six cards:
//   0. Automated Reminders   -> ReminderSettingsScreen
//   1. Promotions Manager    -> PromotionsScreen
//   2. Export Reports        -> ExportReportsScreen
//   3. Payment Settings      -> /paymentSettingsScreen via context.push
//                              (extras sourced from shopDetailsProvider)
//   4. Business Hours        -> BusinessHoursScreen (Phase 11)
//   5. Service Management    -> ServiceManagementScreen (Phase 11)
//
// Phase 10.5 fixed three dead-route bugs where cards 3, 4, 5 all opened
// ExportReportsScreen via the now-deleted _openExport helper.
// Phase 11 promoted cards 4 and 5 from disabled "Coming Soon"
// placeholders to working editors. The Snackbar import stays because
// case 3 (Payment Settings) still uses Snackbar.info while the shop
// details async is loading.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/link/providers/link_providers.dart';
import 'package:nano_embryo/core/link/widgets/shareable_link_section.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_details_provider.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/broadcasts_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/export_reports_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/loyalty_rule_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/reminder_settings_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/tools/kpi_card.dart';

class ToolsScreen extends ConsumerWidget {
  final String shopId;

  const ToolsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    final shopDetailsAsync = ref.watch(shopDetailsProvider(shopId));
    final shop = shopDetailsAsync.maybeWhen(
      data: (s) => s,
      orElse: () => null,
    );
    final shopName = shop?.shopName ?? '';
    final bookingSlug = shop?.bookingSlug;

    return Scaffold(
      body: CardInkWell(
        elevation: 0,
        onTap: () {},
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
                loc.toolsAdminTools,
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
                itemCount: 8,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return KpiCard(
                        title: loc.toolsConfigure,
                        value: loc.toolsAutomatedReminders,
                        icon: Icons.notifications_active,
                        iconColor: colorScheme.error,
                        onTap: () => _openReminderSettings(context),
                      );
                    case 1:
                      return KpiCard(
                        title: loc.toolsManage,
                        value: loc.toolsPromotionsManager,
                        icon: Icons.local_offer,
                        iconColor: colorScheme.success,
                        onTap: () => _openPromotions(context),
                      );
                    case 2:
                      return KpiCard(
                        title: loc.toolsExport,
                        value: loc.toolsExportReports,
                        icon: Icons.download,
                        iconColor: colorScheme.warning,
                        onTap: () => _openExport(context),
                      );
                    case 3:
                      // Payment Settings. Gate on shopDetailsAsync being
                      // loaded — tapping during the first ~200ms after tab
                      // open would otherwise push with empty extras.
                      final paymentEnabled = shop != null;
                      return KpiCard(
                        title: loc.toolsConfigure,
                        value: loc.toolsPaymentSettings,
                        icon: Icons.payment,
                        iconColor: colorScheme.info,
                        enabled: paymentEnabled,
                        onTap: () {
                          if (shop == null) {
                            Snackbar.info(
                              context,
                              loc.toolsLoadingDetails,
                            );
                            return;
                          }
                          // DTO -> route extras mapping (locked by RESEARCH
                          // Finding 1): the route's keys differ from the DTO
                          // field names. shopOwnerId <- shop.userId,
                          // shopCurrencyCode <- shop.currency, etc.
                          context.push(
                            '/paymentSettingsScreen',
                            extra: {
                              'shopId': shopId,
                              'shopName': shop.shopName,
                              'shopOwnerId': shop.userId,
                              'shopCurrencyCode': shop.currency ?? '',
                              'shopCountry': shop.country ?? '',
                            },
                          );
                        },
                      );
                    case 4:
                      // Phase 11: Business Hours editor — routes to the
                      // new BusinessHoursScreen which performs an atomic
                      // DELETE+INSERT rebuild via the
                      // rebuild_shop_opening_hours RPC.
                      return KpiCard(
                        title: loc.toolsConfigure,
                        value: loc.toolsBusinessHours,
                        icon: Icons.access_time,
                        iconColor: colorScheme.error,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BusinessHoursScreen(shopId: shopId),
                          ),
                        ),
                      );
                    case 5:
                      // Phase 11: Service Management — list/edit/archive
                      // via the new ServiceManagementScreen.
                      return KpiCard(
                        title: loc.toolsManage,
                        value: loc.toolsServiceManagement,
                        icon: Icons.cut,
                        iconColor: colorScheme.error,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceManagementScreen(shopId: shopId),
                          ),
                        ),
                      );
                    case 6:
                      // Phase 13: Loyalty rule editor — per-shop config
                      // for the silent visit-count loyalty engine.
                      return KpiCard(
                        title: loc.toolsConfigure,
                        value: loc.toolsLoyaltyRule,
                        icon: Icons.card_giftcard,
                        iconColor: colorScheme.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LoyaltyRuleScreen(shopId: shopId),
                          ),
                        ),
                      );
                    case 7:
                      // Phase 14: Broadcasts — owner-driven messaging
                      // surface (push for registered, WhatsApp for guests).
                      return KpiCard(
                        title: loc.toolsConfigure,
                        value: loc.broadcastsToolsCardLabel,
                        icon: Icons.campaign_outlined,
                        iconColor: colorScheme.secondary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BroadcastsScreen(shopId: shopId),
                          ),
                        ),
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

  void _openPromotions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromotionsScreen(shopId: shopId),
      ),
    );
  }

  void _openExport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExportReportsScreen(shopId: shopId),
      ),
    );
  }
}
