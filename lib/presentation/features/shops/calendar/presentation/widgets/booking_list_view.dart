import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/providers/calendar_provider.dart';
import 'client_booking_card.dart';

class BookingListView extends ConsumerWidget {
  final bool isShopOwner;
  final String currentUserId;
  final DateTime selectedDate;

  const BookingListView({
    super.key,
    required this.isShopOwner,
    required this.currentUserId,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      calendarControllerProvider(
        userIdOrShopId: currentUserId,
        isShopOwner: isShopOwner,
      ),
    );

    // Handle loading state
    if (state.isLoading) {
      return const Center(child: CircularLoadingIndicator(
         
        ),);
    }

    // Handle error state
    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.w,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: Spacing.md.h),
            Text(
              'Error loading bookings',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Handle no data
    if (!state.hasValue || state.value == null) {
      return const Center(child: CircularLoadingIndicator(
         
        ),);
    }

    // Extract calendar state
    final calendarState = state.value!;

    // Filter bookings for selected date
    final dayBookings =
        calendarState.bookings.where((booking) {
          final bookingDate = DateTime(
            booking.startTime.year,
            booking.startTime.month,
            booking.startTime.day,
          );
          final selected = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );
          return bookingDate == selected;
        }).toList();

    if (dayBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48.w,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: Spacing.md.h),
            Text(
              'No bookings for this day',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Sort by time (earliest first)
    dayBookings.sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.separated(
      padding: EdgeInsets.all(Spacing.md.w),
      itemCount: dayBookings.length,
      separatorBuilder: (_, __) => SizedBox(height: Spacing.sm.h),
      itemBuilder: (context, index) {
        final booking = dayBookings[index];

        if (calendarState.viewType == CalendarViewType.client) {
          return ClientBookingCard(
            startTime: booking.startTime,
            endTime: booking.endTime,
            bookingId: booking.id,
            totalAmount: booking.totalAmount,
            shopCurrency: booking.shopCurrency,
            shopType: booking.shopType,
            shopName: booking.shopName,
            shopLogoUrl: booking.shopLogoUrl,
            shopAddress: '',
            serviceName: booking.serviceName,
            shouldPop: false,

            status: booking.status,
            isShopOwner: isShopOwner,

            // booking: booking as ClientCalendarBooking
          );
        } else {
          return ClientBookingCard(
            startTime: booking.startTime,
            endTime: booking.endTime,
            bookingId: booking.id,
            totalAmount: booking.totalAmount,
            shopCurrency: booking.shopCurrency,
            shopType: booking.shopType,
            shopName: booking.clientName,
            shopLogoUrl: booking.clientAvatarUrl,
            shopAddress: '',
            serviceName: booking.serviceName,
            shouldPop: false,
            status: booking.status,
            isShopOwner: isShopOwner,
          );
        }
      },
    );
  }

  void _navigateToDetail(BuildContext context, String bookingId) {
    Navigator.pushNamed(context, '/booking-detail', arguments: bookingId);
  }
}
