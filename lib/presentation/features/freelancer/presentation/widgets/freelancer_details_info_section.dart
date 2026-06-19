import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/location/route_preview_widget.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/freelancer_creation_dashboard.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/widgets/tool_display_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/display_shop_documents.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/display_shop_social_links.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/document_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/social_link_tile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_profile.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/contact_bottom_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/opening_hours_widget.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_header_widget.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/horizontal_reviews_preview.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/shop_rating_widget.dart';
import 'package:path/path.dart';

class FreelancerDetailsInfoSection extends ConsumerWidget {
  final FreelancerDetailsDTO freelancer;
  final bool isPreview;

  const FreelancerDetailsInfoSection({
    super.key,
    required this.freelancer,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // Fetch data using Riverpod providers
    final socialLinksAsync = ref.watch(
      freelancerSocialLinksProvider(freelancer.id),
    );
    final documentUrlsAsync = ref.watch(
      freelancerDocumentUrlsProvider(freelancer.id),
    );
    final openingHoursAsync = ref.watch(freelancerHoursProvider(freelancer.id));
    final toolsAsync = ref.watch(freelancerToolsProvider(freelancer.id));

    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: Spacing.md),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Gap(Spacing.lg.h),
            // Header with rating, verified, luxury level
            GestureDetector(
              onTap:
                  () => {
                    context.push(
                      '/freelancerCreationDashboard',
                      extra: {
                        'shopId': freelancer.id,
                        'mode': FreelancerMode.edit,
                      },
                    ),
                  },
              child: ShopHeaderWidget(
                name: freelancer.name,
                luxuryLevel: '',
                logoUrl: freelancer.profileImageUrl ?? '',
                verified: freelancer.isIdentityVerified,
                shopType: freelancer.freelancerType?.displayName ?? '',
                latitude: freelancer.baseLatitude,
                longitude: freelancer.baseLongitude,
                averageRating: freelancer.rating,
                numberClientsWorked: freelancer.totalBookings,
                overview: freelancer.bio,
                id: freelancer.id,
                isShop: false,
              ),
            ),

            Gap(Spacing.md.h),
            AppDivider(),
            Gap(Spacing.sm.h),

            // Tools Section
            toolsAsync.when(
              data: (tools) {
                if (tools.isEmpty) return const SizedBox.shrink();
                return ToolDisplayWidget(selectedToolIds: tools);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            ShopDetailsSection(
              title: 'Getting There',
              seeAllOnperssed: null,
              widget: RoutePreviewWidget(
                shopLat: freelancer.baseLatitude ?? 0,
                shopLng: freelancer.baseLongitude ?? 0,
                shopName: freelancer.name,
                shopAddress:
                    'Mobile(Home) service within ${freelancer.travelRadiusKm}km',
              ),
            ),

            Gap(Spacing.md.h),
            AppDivider(),
            Gap(Spacing.sm.h),

            DetailedShopRatingWidget(
              onTap: () {
                context.push(
                  '/shopReviewsScreen',
                  extra: {'shopId': freelancer.id, 'shopName': freelancer.name},
                );
              },
              shopId: freelancer.id,
            ),

            HorizontalReviewsPreview(
              shopId: freelancer.id,
              onViewAllPressed: () {},
            ),
            Gap(Spacing.md.h),
            AppDivider(),
            Gap(Spacing.md.h),

            // Opening Hours Section
            openingHoursAsync.when(
              data: (hours) => OpeningHoursWidget(openingHours: hours),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            if (freelancer.bio != null && freelancer.bio!.isNotEmpty) ...[
              Gap(Spacing.md.h),
              AppDivider(),
              Gap(Spacing.md.h),
              Text(
                'About',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(Spacing.sm.h),
              Text(freelancer.bio!, style: textTheme.bodyMedium),
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
                    onPressed: () {},
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
                    label: "Call",
                    onPressed: () {
                      BottomSheetUtils.showDocumentationBottomSheet(
                        context: context,
                        widget: ContactBottomSheet(
                          shopId: freelancer.id,
                          shopName: freelancer.name,
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

            CardInkWell(
              onTap: () {},
              child: Column(
                children: [
                  AppButton(
                    height: 35.h,
                    center: false,
                    iconData: Icons.share,
                    label: "Share link",
                    onPressed: () {},
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
                    label: "QR code",
                    onPressed: () {},
                    padding: Spacing.horizontalMd,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                    width: double.infinity,
                    elevation: 0,
                  ),
                ],
              ),
            ),

            // Social Links Section
            socialLinksAsync.when(
              data: (links) {
                if (links.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    Gap(Spacing.md.h),
                    AppDivider(),
                    Gap(Spacing.md.h),
                    ShopDetailsSection(
                      title: 'Social media',
                      showCard: false,
                      seeAllOnperssed: links.length > 6 ? () {} : null,
                      widget: DisplayShopSocialLinks(
                        isEditting: false,
                        socialLinks: links,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Documents Section
            documentUrlsAsync.when(
              data: (urls) {
                if (urls.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    Gap(Spacing.md.h),
                    AppDivider(),
                    Gap(Spacing.md.h),
                    ShopDetailsSection(
                      title: 'Documents',
                      showCard: false,
                      seeAllOnperssed: urls.length > 6 ? () {} : null,
                      widget: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                        itemCount: urls.take(6).length,
                        itemBuilder: (context, index) {
                          final documentUrl = urls.take(6).elementAt(index);
                          final ImageProvider imageProvider =
                              isPreview
                                  ? FileImage(File(documentUrl))
                                  : NetworkImage(documentUrl);
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Gap(Spacing.xxl.h),
          ],
        ),
      ),
    );
  }
}
