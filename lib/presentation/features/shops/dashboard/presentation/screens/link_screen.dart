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

import 'package:nano_embryo/core/link/providers/link_providers.dart';
import 'package:nano_embryo/core/link/widgets/shareable_link_section.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_details_provider.dart';

class LinkScreen extends ConsumerStatefulWidget {
  final String shopId;

  const LinkScreen({super.key, required this.shopId});

  @override
  ConsumerState<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends ConsumerState<LinkScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final shopDetailsAsync = ref.watch(shopDetailsProvider(widget.shopId));
    final shop = shopDetailsAsync.maybeWhen(data: (s) => s, orElse: () => null);
    final shopName = shop?.shopName ?? '';
    final bookingSlug = shop?.bookingSlug;
    final productsSlug = shop?.productsSlug;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(Spacing.md),
        children: [
          SemanticContainerWidget(
            content:
                'Share your shop page or the products you sell on you social media pages for wider outreach. Customers don\'t have to download the app to access your page through the link',
            icon: Icons.share,
            title: 'Share shop links',
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),
          Gap(Spacing.md),
          ShareableLinkSection(
            currentSlug: bookingSlug,
            entityName: shopName,
            onEditSlug: (newSlug) async {
              final svc = ref.read(linkServiceProvider);
              final result = await svc.createShopLink(
                shopId: widget.shopId,
                customSlug: newSlug,
                metadata: {'name': shopName},
              );
              if (!result.success) {
                throw Exception(result.error ?? 'Failed to update slug');
              }
              // Trigger from Plan A syncs shops.booking_slug; reload to pick
              // it up in the UI.
              await ref
                  .read(shopDetailsProvider(widget.shopId).notifier)
                  .loadShop(widget.shopId);
            },
          ),

          ShareableLinkSection(
            kind: ShareableLinkKind.products,
            currentSlug: productsSlug,
            entityName: shopName,
            onEditSlug: (newSlug) async {
              final svc = ref.read(linkServiceProvider);
              final result = await svc.createShopProductsLink(
                shopId: widget.shopId,
                customSlug: newSlug,
                metadata: {'name': shopName},
              );
              if (!result.success) {
                throw Exception(result.error ?? 'Failed to update slug');
              }
              // sync_products_slug_to_shop trigger mirrors the slug into
              // shops.products_slug; reload the provider so the UI picks it up.
              await ref
                  .read(shopDetailsProvider(widget.shopId).notifier)
                  .loadShop(widget.shopId);
            },
          ),
          Gap(Spacing.xxl * 3),
        ],
      ),
    );
  }
}
