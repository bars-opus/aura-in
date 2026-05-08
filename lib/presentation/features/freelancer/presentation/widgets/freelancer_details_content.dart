import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/tab_bar_delegate.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/client/booking_flow_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_pageview.dart';

class FreelancerDetailsContent extends ConsumerWidget {
  final FreelancerDetailsDTO freelancerDetails;
  final TabController tabController;
  final List<AppTabItem> tabs;
  final String mode;

  const FreelancerDetailsContent({
    super.key,
    required this.freelancerDetails,
    required this.tabController,
    required this.tabs,
    this.mode = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioAsync = ref.watch(
      freelancerPortfolioProvider(freelancerDetails.id),
    );

    return Scaffold(
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
                background: portfolioAsync.when(
                  data: (images) {
                    if (images.isEmpty) return const SizedBox.shrink();
                    return ShopImagePageview(
                      isPreview: mode.isNotEmpty,
                      shopImageUrls: images ?? [],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
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
                        shopId: freelancerDetails.id,
                        shopOwnerId: freelancerDetails.id,
                        accountType: 'shop',
                        shopName: freelancerDetails.name,
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
      bottomNavigationBar: mode.isNotEmpty ? null : _buildBookingBar(context),
    );
  }

  Widget _buildBookingBar(BuildContext context) {
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
                ref
                    .read(selectedShopIdProvider.notifier)
                    .setShopId(freelancerDetails.id);

                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  widget: BookingFlowScreen(
                    shopId: freelancerDetails.id,
                    shopAddress:
                        freelancerDetails.canTravel
                            ? 'Mobile service (up to ${freelancerDetails.travelRadiusKm}km)'
                            : 'Base location service',
                    shopType:
                        freelancerDetails.freelancerType?.displayName ??
                        'Freelancer',
                    shopName: freelancerDetails.name,
                    shopCurrency: 'USD', // Or get from user's location currency
                    shopLogoUrl: freelancerDetails.profileImageUrl ?? '',
                    latitude: freelancerDetails.baseLatitude ?? 0,
                    longitude: freelancerDetails.baseLongitude ?? 0,
                    isFreelancer: true, // ✅ Important flag
                    travelRadiusKm: freelancerDetails.travelRadiusKm,
                    canTravel: freelancerDetails.canTravel,
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
