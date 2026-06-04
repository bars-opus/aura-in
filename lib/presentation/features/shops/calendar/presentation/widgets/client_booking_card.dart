import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/status_widget.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client/countdown_widget.dart';

class ClientBookingCard extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final String bookingId;
  final String shopCurrency;
  final String shopName;
  final String shopType;
  final String? shopLogoUrl;
  final String shopAddress;
  final String serviceName;
  final double totalAmount;
  final String status;
  final bool isShopOwner;
  final bool shouldPop;
  final bool showDivider;

  const ClientBookingCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.shopCurrency,
    required this.shopAddress,
    required this.bookingId,
    required this.shopType,
    required this.shopLogoUrl,
    required this.shopName,
    required this.totalAmount,
    required this.serviceName,
    required this.shouldPop,
    required this.status,
    required this.isShopOwner,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
   
    return InfoRowWidget(
      title: '$serviceName\n$shopCurrency ${totalAmount.toString()}',
      subtitle: '$shopName\n$shopType',
      imageUrl: shopLogoUrl,
      icon: shopLogoUrl == null ? Icons.person : null,
      showDivider: showDivider,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CountdownStreamWidget(
            targetDate: endTime,
            // textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
         
          Gap(10.h),
          StatusWidget(status: status, showLabel: false),
        ],
      ),
      // avatarRadius: 20.h,
      onTap: () {
        if (shouldPop) {
          Navigator.pop(context);
        }
        _navigateToDetail(context);
      },

      showTrailingArrow: false,
    );
  }

  void _navigateToDetail(BuildContext context) {
    BottomSheetUtils.showDocumentationBottomSheet(
      // maxHeight: 320.h,
      context: context,
      widget: BookingDetailScreen(
        startTime: startTime,
        endTime: endTime,
        bookingId: bookingId,
        totalAmount: totalAmount,
        preLoadedBookingDetail: null,
        shopCurrency: shopCurrency,
        shopType: shopType,
        shopName: shopName,
        shopLogoUrl: shopLogoUrl,
        shopAddress: '',
        isShopOwner: isShopOwner,
      ),
    );
  }
}
