import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';

class DayAppointmentsSheet extends StatelessWidget {
  final DateTime date;
  final List<dynamic> bookings;
  final bool isShopView;
  final bool isShopOwner;

  const DayAppointmentsSheet({
    super.key,
    required this.date,
    required this.bookings,
    required this.isShopOwner,

    required this.isShopView,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date, loc),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                Text(
                  loc.calendarAppointmentCount(bookings.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            AppTextButton(),
          ],
        ),
        Gap(Spacing.md),
        AppDivider(),

        // Bookings list
        Expanded(
          child:
              bookings.isEmpty
                  ? Center(
                    child: EmptyStateWidget(
                      subtitle: loc.calendarNoAppointmentsDay,
                    ),
                  )
                  : ListView.separated(
                    padding: EdgeInsets.all(Spacing.md.w),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => SizedBox(height: Spacing.sm.h),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];

                      if (isShopView) {
                        return ClientBookingCard(
                          startTime: booking.startTime,
                          endTime: booking.endTime,
                          bookingId: booking.id,
                          totalAmount: booking.totalAmount,
                          shopCurrency: booking.shopCurrency,
                          shopType:'@${booking.userName}',
                          shopName: booking.clientName,
                          shopLogoUrl: booking.clientAvatarUrl,
                          shopAddress: '',
                          serviceName: booking.serviceName,
                          shouldPop: false,
                          status: booking.status,
                          isShopOwner: isShopOwner,
                        );
                      } else {
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
                        );
                      }
                    },
                  ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, AppLocalizations loc) {
    final months = [
      loc.monthJanuary,
      loc.monthFebruary,
      loc.monthMarch,
      loc.monthApril,
      loc.monthMay,
      loc.monthJune,
      loc.monthJuly,
      loc.monthAugust,
      loc.monthSeptember,
      loc.monthOctober,
      loc.monthNovember,
      loc.monthDecember,
    ];
    final days = [
      loc.dayMonday,
      loc.dayTuesday,
      loc.dayWednesday,
      loc.dayThursday,
      loc.dayFriday,
      loc.daySaturday,
      loc.daySunday,
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
