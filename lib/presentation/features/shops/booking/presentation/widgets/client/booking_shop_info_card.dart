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
          ProfileHeader(
            mode: ProfileHeaderMode.compact,
            displayName: widget.shopName,
            userId: widget.shopId,
            bio: widget.shopType,
            avatarUrl: widget.shopLogoUrl,
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
