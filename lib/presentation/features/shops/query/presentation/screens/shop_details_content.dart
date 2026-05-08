import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/tab_bar_delegate.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/client/booking_flow_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_pageview.dart';

class ShopDetailsContent extends ConsumerWidget {
  final ShopDetailsDTO shop;
  final TabController tabController;
  final List<AppTabItem> tabs;
  final String mode;

  const ShopDetailsContent({
    super.key,
    required this.shop,
    required this.tabController,
    required this.tabs,
    this.mode = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 400.h,
              leading: Center(
                child: AppIconButton(
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: colorScheme.background.withOpacity(.6),
                  icon:
                      Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                ),
              ),
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: ShopImagePageview(
                  isPreview: mode.isNotEmpty,
                  shopImageUrls: shop.professionalImages ?? [],
                ),
              ),
              actions: [
                AppIconButton(
                  onPressed: () {
                    BottomSheetUtils.showDocumentationBottomSheet(
                      padding: Spacing.md,
                      maxHeight: 570.h,
                      context: context,
                      widget: MoreScreen(
                        shopId: shop.id,
                        shopOwnerId: shop.userId,
                        accountType: 'shop',
                        shopName: shop.shopName,
                        shopCurrencyCode: 'GHS',
                        // shop.currency??'',
                        shopCountry: 'Gh',
                        isFreelancer: false,
                        //  shop.country??'',
                      ),
                    );
                  },
                  backgroundColor: colorScheme.background.withOpacity(.6),
                  icon: Icons.more_vert,
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: TabBarDelegate(
                tabs: tabs,
                tabController: tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: tabs.map((tab) => tab.content ?? const SizedBox()).toList(),
        ),
      ),
      bottomNavigationBar:
          mode.isNotEmpty ? null : _buildBookingBar(context, shop),
    );
  }

  Widget _buildBookingBar(BuildContext context, ShopDetailsDTO shop) {
    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            return AppButton(
              elevation: 0,
              label: 'Book now',
              onPressed: () {
                ref.read(selectedShopIdProvider.notifier).setShopId(shop.id);

                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  widget: BookingFlowScreen(
                    shopId: shop.id,
                    shopAddress: shop.address ?? '',
                    shopType: shop.shopType ?? '',
                    shopName: shop.shopName,
                    shopCurrency: shop.currency ?? '',
                    shopLogoUrl: shop.shopLogoUrl ?? '',
                    latitude: shop.latitude ?? 0,
                    longitude: shop.longitude ?? 0,
                  ),
                );
              },
              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 35.h,
            );
          },
        ),
      ),
    );
  }
}
