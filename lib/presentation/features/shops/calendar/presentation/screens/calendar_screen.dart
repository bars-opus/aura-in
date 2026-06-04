import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final bool isShopOwner;
  final String currentUserId;
  final bool isCurrentUser;

  const CalendarScreen({
    super.key,
    required this.isShopOwner,
    required this.currentUserId,
    required this.isCurrentUser,
  });
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final state = ref.watch(
      calendarControllerProvider(
        userIdOrShopId: widget.currentUserId,
        isShopOwner: widget.isShopOwner,
      ),
    );

    final controller = ref.read(
      calendarControllerProvider(
        userIdOrShopId: widget.currentUserId,
        isShopOwner: widget.isShopOwner,
      ).notifier,
    );

    // Add this debug print

    return Scaffold(
      body: state.when(
        data: (data) {
          return CustomScrollView(
            slivers: [
              // Calendar grid as a sliver box
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    !widget.isShopOwner ? Gap(10.h) : Gap(20.h),
                    CalendarMonthView(
                      currentUserId: widget.currentUserId,
                      isShopOwner: widget.isShopOwner,
                      focusedMonth: data.focusedMonth,
                      onDaySelected: (selectedDay) {
                        _showDayAppointmentsSheet(context, selectedDay, data);
                      },
                      onMonthChanged: (month) {
                        controller.loadMonth(month);
                      },
                      isCurrentUser: widget.isCurrentUser,
                    ),
                    AppDivider(),
                  ],
                ),
              ),
              // Month appointments list as a sliver list
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w,
                  vertical: Spacing.lg.h,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // Get the sorted list from a helper
                    final sortedBookings = _getSortedBookings(data.bookings);
                    if (index >= sortedBookings.length) return null;
                    final booking = sortedBookings[index];
                    if (data.viewType == CalendarViewType.shop) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: Spacing.sm.h),
                        child: ClientBookingCard(
                          startTime: booking.startTime,
                          endTime: booking.endTime,
                          totalAmount: booking.totalAmount,
                          shopCurrency: booking.shopCurrency,
                          shopType: '@${booking.userName}',
                          shopName: booking.clientName,
                          shopLogoUrl: booking.clientAvatarUrl,
                          shopAddress: '',
                          serviceName: booking.serviceName,
                          shouldPop: false,
                          bookingId: booking.id,
                          status: booking.status,
                          isShopOwner: true,
                        ),

                        // ShopBookingCard(
                        //   booking: booking,
                        //   shouldPop: true,
                        // ),
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(bottom: Spacing.sm.h),
                        child: ClientBookingCard(
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
                          isShopOwner: false,
                        ),
                      );
                    }
                  }, childCount: _getSortedBookings(data.bookings).length),
                ),
              ),
              // Add bottom padding
            ],
          );
        },
        loading: () => _loading(),
        error: (error, stack) {
          final currentMonth =
              state.hasValue ? state.value!.focusedMonth : DateTime.now();

          return Center(
            child: ErrorStateWidget(
              subtitle: AppLocalizations.of(context)!.calendarErrorLoading,
              onPrimaryAction: () {
                controller.loadMonth(currentMonth);
              },
            ),
          );
        },
      ),
    );
  }

  _loading() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Access localization for language prefence
    final loc = AppLocalizations.of(context)!;
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: !widget.isShopOwner ? 10.h : 20.h,
                ),
                child: TableCalendar(
                  rowHeight: 40.h,
                  daysOfWeekHeight: 25.h,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  pageAnimationCurve: Curves.easeInOut,
                  // KEY: Only allow horizontal gestures
                  availableGestures: AvailableGestures.horizontalSwipe,
                  selectedDayPredicate: (day) => false,
                  calendarStyle: CalendarStyle(
                    // Regular dates
                    defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onBackground,
                    ),
                    cellMargin: EdgeInsets.all(0),
                    todayDecoration: BoxDecoration(
                      color: colorScheme.onBackground.withOpacity(.2),
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 0,
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onBackground,
                    ),
                    headerMargin: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 20,
                    ),
                    titleCentered: false,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: colorScheme.primary,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              if (widget.isShopOwner)
                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: CircularLoadingIndicator(size: 15.h),
                ),
            ],
          ),
          Gap(20.h),
          AppDivider(),
          Gap(20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            child: Text(
              loc.loadingDefaultMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          Gap(10.h),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
              shrinkWrap: true,
              itemCount: 5,
              separatorBuilder: (_, __) => Gap(Spacing.xs.w),
              itemBuilder: (_, __) => ShopSchimmerSkeleton(height: 100),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getSortedBookings(List<dynamic> bookings) {
    final sorted = List<dynamic>.from(bookings);
    sorted.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sorted;
  }

  void _showDayAppointmentsSheet(
    BuildContext context,
    DateTime selectedDay,
    dynamic data,
  ) {
    final dayBookings =
        data.bookings.where((booking) {
          final bookingDate = DateTime(
            booking.startTime.year,
            booking.startTime.month,
            booking.startTime.day,
          );
          final selected = DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          );
          return bookingDate == selected;
        }).toList();

    if (dayBookings.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      context.showInfoSnackbar(
        loc.calendarNoAppointmentsSnackbar(MyDateFormat.toDate(selectedDay)),
      );

      return;
    }

    BottomSheetUtils.showDocumentationBottomSheet(
      // maxHeight: 320.h,
      context: context,
      widget: DayAppointmentsSheet(
        date: selectedDay,
        bookings: dayBookings,
        isShopView: data.viewType == CalendarViewType.shop,
        isShopOwner: widget.isShopOwner,
      ),
    );
  }

  Widget _buildShopSelector(
    BuildContext context,
    dynamic state,
    CalendarController controller,
  ) {
    if (state.availableShops.isEmpty) return const SizedBox();

    return Padding(
      padding: EdgeInsets.only(right: Spacing.md.w),
      child: DropdownButton<String>(
        value: state.activeShopId,
        items:
            state.availableShops.map<DropdownMenuItem<String>>((shop) {
              return DropdownMenuItem<String>(
                value: shop['id'] as String,
                child: Row(
                  children: [
                    if (shop['shop_logo_url'] != null)
                      Container(
                        width: 24.w,
                        height: 24.h,
                        margin: EdgeInsets.only(right: Spacing.xs.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              shop['shop_logo_url'] as String,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Text(shop['shop_name'] as String),
                  ],
                ),
              );
            }).toList(),
        onChanged: (String? newShopId) {
          if (newShopId != null) {
            // controller.switchShop(newShopId);
          }
        },
        underline: const SizedBox(),
      ),
    );
  }
}
