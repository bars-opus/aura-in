import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/link/entity_share_links.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/presentation/providers/moderation_provider.dart';
import 'package:nano_embryo/core/moderation/presentation/widgets/moderation_unavailable_widget.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/tab_bar_delegate.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/client/booking_flow_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_loading_schimmer.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_pageview.dart';

class ShopDetailsContent extends ConsumerWidget {
  final ShopDetailsDTO shop;
  final TabController tabController;
  final List<AppTabItem> tabs;
  final String mode;
  final String coverImageUrl;

  const ShopDetailsContent({
    super.key,
    required this.shop,
    required this.tabController,
    required this.tabs,
    required this.coverImageUrl,
    this.mode = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = ref.watch(currentUserProvider)?.id ?? '';
    final blockStatusAsync =
        currentUserId.isEmpty || currentUserId == shop.userId
            ? const AsyncData(
              ModerationCheckResult(
                isBlocked: false,
                isBlockedByCurrentUser: false,
                isBlockingCurrentUser: false,
              ),
            )
            : ref.watch(moderationBlockStatusProvider(shop.userId));
    final moderationTexts = ref.watch(moderationConfigProvider).texts(context);

    return blockStatusAsync.when(
      loading: () => ShopDetailsLoadingSchimmer(coverImageUrl: coverImageUrl),
      error:
          (_, __) => Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(),
            body: ModerationUnavailableWidget(texts: moderationTexts),
          ),
      data: (blockStatus) {
        if (blockStatus.isBlocked) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(),
            body: ModerationUnavailableWidget(texts: moderationTexts),
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
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
                    background: ShopImagePageview(
                      isPreview: mode.isNotEmpty,
                      shopImageUrls: shop.professionalImages,
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
                            moderationTarget: ModerationTarget(
                              targetType: ModerationTargetType.shop,
                              targetId: shop.id,
                              targetOwnerId: shop.userId,
                              displayName: shop.shopName,
                            ),
                            // Real destination: the shop's public booking page.
                            shareUrl: EntityShareLinks.shopBooking(
                              shop.bookingSlug,
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
              mode.isNotEmpty ? null : _buildBookingBar(context, shop),
        );
      },
    );
  }

  Widget _buildBookingBar(BuildContext context, ShopDetailsDTO shop) {
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
                currentUserId.isEmpty || currentUserId == shop.userId
                    ? const AsyncData(
                      ModerationCheckResult(
                        isBlocked: false,
                        isBlockedByCurrentUser: false,
                        isBlockingCurrentUser: false,
                      ),
                    )
                    : ref.watch(moderationBlockStatusProvider(shop.userId));

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
              isDisabled: blocked,
            );
          },
        ),
      ),
    );
  }
}
