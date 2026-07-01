import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/link/config/aurain_link_config.dart';
import 'package:nano_embryo/core/link/widgets/link_qr_view.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/location/route_preview_widget.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/services/business_chat_launcher.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/amenity_display_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/award_display_card.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/display_shop_social_links.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/contact_bottom_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/opening_hours_widget.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_header_widget.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/horizontal_reviews_preview.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/shop_rating_widget.dart';
import 'package:share_plus/share_plus.dart';

class ShopDetailsInfoSection extends ConsumerWidget {
  final ShopDetailsDTO shop;
  final bool isPreview;

  const ShopDetailsInfoSection({
    super.key,
    required this.shop,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access theme for consistent styling
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: Spacing.md),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Gap(Spacing.lg.h),
            // // Header with rating, verified, luxury level
            ShopHeaderWidget(
              name: shop.shopName,
              luxuryLevel: '',
              logoUrl: shop.shopLogoUrl ?? '',
              verified: shop.verified,
              shopType: shop.shopType ?? '',
              latitude: shop.latitude,
              longitude: shop.longitude,
              averageRating: shop.averageRating,
              numberClientsWorked: shop.numberClientsWorked,
              overview: shop.overview,
              id: shop.id,
              isShop: true,
            ),

            Gap(Spacing.md.h),
            AppDivider(),
            Gap(Spacing.sm.h),
            if (shop.amenityIds.isNotEmpty)
              AmenityDisplayWidget(selectedAmenityIds: shop.amenityIds),

            if (shop.workers.isNotEmpty)
              ShopDetailsSection(
                title: 'Workers',
                seeAllOnperssed:
                    shop.workers.length > 4
                        ? () => _navigateToAllWorkers(context)
                        : null,
                widget: SizedBox(
                  height: shop.workers.take(5).length * 75,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shop.workers.take(5).length,
                    separatorBuilder: (context, index) => AppDivider(),
                    itemBuilder: (context, index) {
                      final worker = shop.workers.take(5).elementAt(index);
                      return ProfileHeader(
                        enableOnProfileNavigatePressed: false,
                        mode: ProfileHeaderMode.compact,
                        textColor: colorScheme.onBackground,
                        displayName: worker.name,
                        userId: worker.id,
                        avatarUrl: worker.profileImage,
                        bio:
                            "${worker.bio}\n${worker.specialties.take(2).join(' • ')}",
                      );
                    },
                  ),
                ),
              ),
            ShopDetailsSection(
              title: 'Getting There',
              seeAllOnperssed: null,
              widget: RoutePreviewWidget(
                shopLat: shop.latitude ?? 0,
                shopLng: shop.longitude ?? 0,
                shopName: shop.shopName,
                shopAddress: shop.address ?? '',
              ),
            ),

            DetailedShopRatingWidget(
              onTap: () {
                context.push(
                  '/shopReviewsScreen',
                  extra: {'shopId': shop.id, 'shopName': shop.shopName},
                );
              },
              shopId: shop.id,
              // averageRating: shop.averageRating,
              // totalReviews: shop.totalReviews,
            ),

            HorizontalReviewsPreview(shopId: shop.id, onViewAllPressed: () {}),
            if (shop.openingHours.isNotEmpty) ...[
              Gap(Spacing.md.h),
              AppDivider(),
              Gap(Spacing.md.h),
              OpeningHoursWidget(openingHours: shop.openingHours),
            ],

            if (shop.terms != null && shop.terms!.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  BottomSheetUtils.showDocumentationBottomSheet(
                    context: context,
                    widget: ReadAll(body: shop.terms ?? ''),
                  );
                },
                child: Column(
                  children: [
                    Gap(Spacing.md.h),
                    AppDivider(),
                    Gap(Spacing.md.h),
                    RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms and conditions\n\n',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          TextSpan(
                            text: shop.terms ?? '',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            Gap(Spacing.md.h),
            AppDivider(),
            Gap(Spacing.md.h),
            ShopDetailsSection(
              title: 'Actions',
              seeAllOnperssed: null,
              widget: Column(
                children: [
                  AppButton(
                    height: 35.h,
                    center: false,
                    iconData: Icons.send,
                    label: "Send a message",
                    onPressed: () => BusinessChatLauncher.openForShop(
                      context,
                      ref,
                      shopId: shop.id,
                      shopName: shop.shopName,
                    ),
                    padding: Spacing.horizontalMd,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                    width: double.infinity,
                    elevation: 0,
                  ),
                  Gap(Spacing.sm),
                  AppButton(
                    center: false,
                    iconData: Icons.call,
                    height: 35.h,
                    label: "Call shop",
                    onPressed: () {
                      BottomSheetUtils.showDocumentationBottomSheet(
                        context: context,
                        widget: ContactBottomSheet(
                          shopId: shop.id,
                          shopName: shop.shopName,
                        ),
                      );
                    },
                    padding: Spacing.horizontalMd,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                    width: double.infinity,
                    elevation: 0,
                  ),
                  Gap(Spacing.sm),
                  AppButton(
                    height: 35.h,
                    center: false,
                    iconData: Icons.share,
                    label: "Share link",
                    onPressed: () async {
                      final slug = shop.bookingSlug;
                      if (slug == null || slug.isEmpty) {
                        context.showErrorSnackbar('No shareable link yet');
                        return;
                      }
                      final config = AuraInLinkConfig.getConfig();
                      final url =
                          'https://${config.baseDomain}/book/$slug';
                      // On iOS, shareUri triggers a native link-preview card
                      // using the page's og:image (shop logo), og:title (shop
                      // name), and og:description (overview) — all of which
                      // /book/[slug] now serves dynamically per shop.
                      // On Android, fall back to plain text which shows inline.
                      if (Platform.isIOS) {
                        await Share.shareUri(Uri.parse(url));
                        return;
                      }
                      final overview = shop.overview?.trim() ?? '';
                      final body = StringBuffer(shop.shopName);
                      if (overview.isNotEmpty) body.write('\n$overview');
                      body.write('\n\n$url');
                      Share.share(body.toString());
                    },
                    padding: Spacing.horizontalMd,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                    width: double.infinity,
                    elevation: 0,
                  ),
                  Gap(Spacing.sm),
                  AppButton(
                    center: false,
                    iconData: Icons.qr_code,
                    height: 35.h,
                    label: "Shop QR code",
                    onPressed: () {
                      final slug = shop.bookingSlug;
                      if (slug == null || slug.isEmpty) {
                        context.showErrorSnackbar('No shareable link yet');
                        return;
                      }
                      final config = AuraInLinkConfig.getConfig();
                      final url =
                          'https://${config.baseDomain}/book/$slug';
                      BottomSheetUtils.showDocumentationBottomSheet(
                        context: context,
                        widget: Padding(
                          padding: EdgeInsets.all(Spacing.lg.w),
                          child: LinkQrView(
                            url: url,
                            label: shop.shopName,
                          ),
                        ),
                      );
                    },
                    padding: Spacing.horizontalMd,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                    width: double.infinity,
                    elevation: 0,
                  ),
                ],
              ),
            ),

            if (shop.socialLinks.isNotEmpty)
              Column(
                children: [
                  Gap(Spacing.md.h),
                  AppDivider(),
                  Gap(Spacing.md.h),
                  ShopDetailsSection(
                    title: 'Social media',
                    showCard: false,
                    seeAllOnperssed: shop.socialLinks.length > 6 ? () {} : null,
                    widget: DisplayShopSocialLinks(
                      isEditting: false,
                      socialLinks: shop.socialLinks,
                    ),
                  ),
                ],
              ),

            if (shop.awards.isNotEmpty)
              Column(
                children: [
                  Gap(Spacing.md.h),
                  AppDivider(),
                  Gap(Spacing.md.h),
                  ShopDetailsSection(
                    title: 'Awards',
                    showCard: false,
                    seeAllOnperssed: shop.socialLinks.length > 6 ? () {} : null,
                    widget: AwardDisplayCard(awards: shop.awards),
                  ),
                ],
              ),

            if (shop.documentImages.isNotEmpty)
              Column(
                children: [
                  Gap(Spacing.md.h),
                  AppDivider(),
                  Gap(Spacing.md.h),
                  ShopDetailsSection(
                    title: 'Documents',
                    showCard: false,
                    seeAllOnperssed:
                        shop.documentImages.length > 6 ? () {} : null,
                    widget: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 columns like Instagram
                            crossAxisSpacing: 8, // Space between columns
                            mainAxisSpacing: 8, // Space between rows
                            childAspectRatio: 1, // Square aspect ratio (1:1)
                          ),
                      itemCount:
                          shop.documentImages
                              .take(6)
                              .length, // Show up to 6 items (2 rows of 3)
                      itemBuilder: (context, index) {
                        final documentImage = shop.documentImages
                            .take(6)
                            .elementAt(index);
                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              image: DecorationImage(
                                image:
                                    isPreview
                                        ? FileImage(File(documentImage))
                                            as ImageProvider
                                        : NetworkImage(documentImage)
                                            as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            Gap(Spacing.xxl.h),
          ],
        ),
      ),
    );
  }

  void _navigateToAllWorkers(BuildContext context) {
    context.push(
      '/allShopWorkersScreen',
      extra: {'shopId': shop.id, 'shopName': shop.shopName},
    );
  }
}
