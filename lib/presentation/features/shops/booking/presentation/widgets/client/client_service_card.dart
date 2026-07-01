import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client/service_with_requirements.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

class ClientServiceCard extends ConsumerWidget {
  final String label;
  final String shopCurrency;
  final bool isShopOwner;
  final BookingModel booking;
  final VoidCallback onRequirementsSaved;

  const ClientServiceCard({
    super.key,
    required this.label,
    required this.shopCurrency,
    required this.isShopOwner,
    required this.booking,
    required this.onRequirementsSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEditSpecialRequirements = _canEditSpecialRequirements();

    return CardInkWell(
      padding: EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(10),
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(Spacing.md.h),

          // Service List with Special Requirements
          ...booking.bookingServices?.map(
                (service) => Padding(
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                  child: ServiceWithRequirements(
                    service: service,
                    onRequirementsSaved: () {
                      ref.invalidate(bookingDetailProvider(booking.id));
                    },
                    isShopOwner: isShopOwner,
                    canEditSpecialRequirements: canEditSpecialRequirements,
                  ),
                ),
              ) ??
              [],

          // Price Breakdown — Phase 17: BookingPriceBreakdown widget signature
          // still takes major-units (flip in a follow-up sweep). Convert at
          // the boundary.
          BookingPriceBreakdown(
            isShopOwner: isShopOwner,
            buttonText: 'Make final payment',
            totalAmount: booking.totalAmountMinor / 100,
            depositAmount: booking.depositAmountMinor / 100,
            platformFee:
                (booking.platformFeeMinor ?? 0) / 100,
            payOnPressed: () {
              final remainingMinor =
                  booking.totalAmountMinor - booking.depositAmountMinor;
              final remaining = formatMoney(remainingMinor, shopCurrency);

              BottomSheetUtils.showDocumentationBottomSheet(
                context: context,
                maxHeight: 350.h,
                widget: ConfirmationDialog(
                  noIcon: true,
                  type: ConfirmationType.info,
                  title: 'Confirm final payment',
                  confirmText: 'Continue',
                  message:
                      'You will be charged $remaining. No platform fee is applied for the final payment.',
                  onConfirm: () {
                    // _confirmBooking();
                  },
                ),
              );
            },
            isProcessing: false,
            reference: booking.id.toString(),
            shopCurrency: shopCurrency,
          ),
        ],
      ),
    );
  }

  /// Check if special requirements can be edited
  bool _canEditSpecialRequirements() {
    final now = DateTime.now();
    final twoHoursBefore = booking.startTime.subtract(const Duration(hours: 2));

    return now.isBefore(twoHoursBefore) &&
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed;
  }
}
