import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/status_widget.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client/countdown_widget.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

class ClientBookingCard extends ConsumerWidget {
  final DateTime startTime;
  final DateTime endTime;
  final String bookingId;
  final String shopCurrency;
  final String shopName;
  final String shopType;
  final String? shopLogoUrl;
  final String shopAddress;
  final String serviceName;

  /// Money in int minor units (kobo / cents). Display via [formatMoney].
  /// Checklist v3.1 P0-U 2.19 — never store money as double here.
  final int totalAmountMinor;
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
    required this.totalAmountMinor,
    required this.serviceName,
    required this.shouldPop,
    required this.status,
    required this.isShopOwner,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveShopCurrency =
        shopCurrency.isNotEmpty
            ? shopCurrency
            : (ref.watch(currentShopProvider)?.currency ?? '');

    return InfoRowWidget(
      title: '$serviceName\n${formatMoney(totalAmountMinor, effectiveShopCurrency)}',
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
          ),
          Gap(10.h),
          StatusWidget(status: status, showLabel: false),
        ],
      ),
      onTap: () {
        if (shouldPop) {
          Navigator.pop(context);
        }
        _navigateToDetail(context, effectiveShopCurrency);
      },
      showTrailingArrow: false,
    );
  }

  void _navigateToDetail(BuildContext context, String effectiveShopCurrency) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: BookingDetailScreen(
        startTime: startTime,
        endTime: endTime,
        bookingId: bookingId,
        totalAmountMinor: totalAmountMinor,
        preLoadedBookingDetail: null,
        shopCurrency: effectiveShopCurrency,
        shopType: shopType,
        shopName: shopName,
        shopLogoUrl: shopLogoUrl,
        shopAddress: '',
        isShopOwner: isShopOwner,
      ),
    );
  }
}
