import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/link/entity_share_links.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/core/moderation/presentation/providers/moderation_provider.dart';
import 'package:nano_embryo/core/moderation/presentation/widgets/moderation_unavailable_widget.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/tab_bar_delegate.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/client/booking_flow_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_loading_schimmer.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_pageview.dart';

class FreelancerDetailsContent extends ConsumerWidget {
  final FreelancerDetailsDTO freelancerDetails;
  final TabController tabController;
  final List<AppTabItem> tabs;
  final String coverImageUrl;

  final String mode;

  const FreelancerDetailsContent({
    super.key,
    required this.freelancerDetails,
    required this.tabController,
    required this.coverImageUrl,
    required this.tabs,
    this.mode = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = ref.watch(currentUserProvider)?.id ?? '';
    final blockStatusAsync =
        currentUserId.isEmpty || currentUserId == freelancerDetails.userId
            ? const AsyncData(
              ModerationCheckResult(
                isBlocked: false,
                isBlockedByCurrentUser: false,
                isBlockingCurrentUser: false,
              ),
            )
            : ref.watch(
              moderationBlockStatusProvider(freelancerDetails.userId),
            );
    final portfolioAsync = ref.watch(
      freelancerPortfolioProvider(freelancerDetails.id),
    );
    final moderationTexts = ref.watch(moderationConfigProvider).texts(context);

    return blockStatusAsync.when(
      loading: () => ShopDetailsLoadingSchimmer(coverImageUrl: coverImageUrl),
      error:
          (_, __) => Scaffold(
            appBar: AppBar(),
            body: ModerationUnavailableWidget(texts: moderationTexts),
          ),
      data: (blockStatus) {
        if (blockStatus.isBlocked) {
          return Scaffold(
            appBar: AppBar(),
            body: ModerationUnavailableWidget(texts: moderationTexts),
          );
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 400.h,
                  leading: Center(
                    child: AppIconButton(
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: colorScheme.surface.withValues(
                        alpha: .6,
                      ),
                      icon:
                          Platform.isIOS
                              ? Icons.arrow_back_ios
                              : Icons.arrow_back,
                    ),
                  ),
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: portfolioAsync.when(
                      data: (images) {
                        if (images.isEmpty) return const SizedBox.shrink();
                        return ShopImagePageview(
                          isPreview: mode.isNotEmpty,
                          shopImageUrls: images,
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  actions: [
                    AppIconButton(
                      onPressed: () async {
                        // A freelancer is backed by a shops row whose id equals
                        // the worker id (freelancerDetails.id), so its booking
                        // slug drives the same /book/<slug> web page as a shop.
                        final shop = await ref.read(
                          shopByIdProvider(freelancerDetails.id).future,
                        );
                        if (!context.mounted) return;
                        BottomSheetUtils.showDocumentationBottomSheet(
                          padding: Spacing.md,
                          maxHeight: 570.h,
                          context: context,
                          widget: MoreScreen(
                            moderationTarget: ModerationTarget(
                              targetType: ModerationTargetType.freelancer,
                              targetId: freelancerDetails.id,
                              targetOwnerId: freelancerDetails.userId,
                              displayName: freelancerDetails.name,
                            ),
                            shareUrl: EntityShareLinks.shopBooking(
                              shop?.bookingSlug,
                            ),
                          ),
                        );
                      },
                      backgroundColor: colorScheme.surface.withValues(
                        alpha: .6,
                      ),
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
              children:
                  tabs.map((tab) => tab.content ?? const SizedBox()).toList(),
            ),
          ),
          bottomNavigationBar:
              mode.isNotEmpty ? null : _buildBookingBar(context),
        );
      },
    );
  }

  Widget _buildBookingBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final currentUserId = ref.watch(currentUserProvider)?.id ?? '';
            final blockStatusAsync =
                currentUserId.isEmpty ||
                        currentUserId == freelancerDetails.userId
                    ? const AsyncData(
                      ModerationCheckResult(
                        isBlocked: false,
                        isBlockedByCurrentUser: false,
                        isBlockingCurrentUser: false,
                      ),
                    )
                    : ref.watch(
                      moderationBlockStatusProvider(freelancerDetails.userId),
                    );
            final blocked = blockStatusAsync.valueOrNull?.isBlocked ?? false;
            return AppButton(
              elevation: 0,
              label: 'Book now',
              onPressed: () {
                if (blocked) {
                  context.showErrorSnackbar(
                    ref
                        .read(moderationConfigProvider)
                        .texts(context)
                        .blockedUnavailableBody,
                  );
                  return;
                }
                ref
                    .read(selectedShopIdProvider.notifier)
                    .setShopId(freelancerDetails.id);

                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  widget: BookingFlowScreen(
                    shopId: freelancerDetails.id,
                    shopAddress:
                        freelancerDetails.canTravel
                            ? 'Mobile(Home) service (up to ${freelancerDetails.travelRadiusKm}km)'
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
              isDisabled: blocked,
            );
          },
        ),
      ),
    );
  }
}
