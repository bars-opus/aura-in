import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/location/route_preview_widget.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_model.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/rating_section.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/review_bottom_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/review_display_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class BookingShopInfoCard extends ConsumerStatefulWidget {
  final String shopName;
  final String shopType;
  final String shopId;
  final String bookingId;
  final String status;
  final String shopAddress;
  final String? shopLogoUrl;
  final double latitude;
  final double longitude;
  // final BookingModel booking;

  const BookingShopInfoCard({
    super.key,
    required this.shopType,
    required this.shopId,
    required this.shopName,
    required this.shopLogoUrl,
    required this.shopAddress,
    required this.latitude,
    required this.longitude,
    required this.bookingId,
    required this.status,
  });

  @override
  ConsumerState<BookingShopInfoCard> createState() =>
      _BookingShopInfoCardState();
}

class _BookingShopInfoCardState extends ConsumerState<BookingShopInfoCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CardInkWell(
      padding: EdgeInsets.all(12),
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          Gap(Spacing.lg),
          Row(
            children: [
              Expanded(
                child: ProfileHeader(
                  mode: ProfileHeaderMode.compact,
                  displayName: widget.shopName,
                  userId: widget.shopId,
                  bio: widget.shopType,
                  avatarUrl: widget.shopLogoUrl,
                  // Keep the header tappable (enable=true) but OVERRIDE its
                  // destination: the default navigates to /profileScreen using
                  // userId, which here is a SHOP id (no such profile → "unable
                  // to load profile"). enable=false would make it non-tappable
                  // and the callback would never fire — so route to shop details.
                  enableOnProfileNavigatePressed: true,
                  onProfileNavigatePressed:
                      () => context.pushNamed(
                        'shopDetailsScreen',
                        extra: <String, String?>{
                          'shopId': widget.shopId,
                          'coverImageUrl': widget.shopLogoUrl ?? '',
                        },
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: IconSizes.sm.h,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),

          ShopDetailsSection(
            title: '',
            seeAllOnperssed: null,
            widget: RoutePreviewWidget(
              shopLat: widget.latitude ?? 0,
              shopLng: widget.longitude ?? 0,
              shopName: widget.shopName,
              shopAddress: widget.shopAddress ?? '',
            ),
          ),

          RatingSection(
            shopName: widget.shopName,
            bookingId: widget.bookingId,
            status: widget.status,
          ),
        ],
      ),
    );
  }
}
