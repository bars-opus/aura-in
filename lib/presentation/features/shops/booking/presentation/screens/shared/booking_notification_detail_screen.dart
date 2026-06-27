import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

class BookingNotificationDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingNotificationDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return bookingAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularLoadingIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Failed to load booking details',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(bookingDetailProvider(bookingId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (booking) {
        final shopAsync = ref.watch(shopByIdProvider(booking.shopId));
        final userShopsAsync = ref.watch(userShopsProvider);
        if (userShopsAsync.isLoading && userShopsAsync.valueOrNull == null) {
          return const Scaffold(
            body: Center(child: CircularLoadingIndicator()),
          );
        }

        final userShops = userShopsAsync.valueOrNull ?? const [];
        final isShopOwner = userShops.any((shop) => shop.id == booking.shopId);
        final shop = shopAsync.valueOrNull;

        if (shopAsync.isLoading && shop == null) {
          return const Scaffold(
            body: Center(child: CircularLoadingIndicator()),
          );
        }

        return BookingDetailScreen(
          startTime: booking.startTime,
          endTime: booking.endTime,
          bookingId: booking.id,
          status: booking.status.name,
          shopCurrency: shop?.currency ?? '',
          shopName: shop?.shopName ?? 'Booking',
          shopType: shop?.shopType ?? '',
          shopLogoUrl: shop?.shopLogoUrl,
          shopAddress: shop?.address ?? booking.shopAddress ?? '',
          totalAmountMinor: booking.totalAmountMinor,
          preLoadedBookingDetail: booking,
          isShopOwner: isShopOwner,
        );
      },
    );
  }
}
