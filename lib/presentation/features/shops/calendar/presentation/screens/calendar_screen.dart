import 'package:nano_embryo/core/utils/haptic_feedback_utils.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
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

  /// Client-side authorization guard (defense in depth on top of RLS).
  ///
  /// - Shop-owner mode: `currentUserId` is the shopId; verify the signed-in
  ///   user owns that shop.
  /// - Client mode: `currentUserId` is a user id; verify it matches the
  ///   signed-in user. Looking at another user's profile calendar tab is
  ///   not authorized client-side — RLS would block writes but we don't
  ///   want to render reads either.
  ///
  /// Returns a widget when access is denied (which the build method
  /// shows in place of the calendar), or null when access is granted.
  /// Checklist v3.1 P0-U 1.4 / 1.5.
  Widget? _authorizationGuard() {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const _CalendarUnauthorized();
    }

    if (widget.isShopOwner) {
      final userShopsAsync = ref.watch(userShopsProvider);
      return userShopsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const _CalendarUnauthorized(),
        data: (shops) {
          final ownsShop = shops.any((s) => s.id == widget.currentUserId);
          return ownsShop ? null : const _CalendarUnauthorized();
        },
      );
    }

    return widget.currentUserId == currentUser.id
        ? null
        : const _CalendarUnauthorized();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final blocked = _authorizationGuard();
    if (blocked != null) {
      return Scaffold(body: blocked);
    }

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
                    //  Gap(20.h),
                    CalendarMonthView(
                      currentUserId: widget.currentUserId,
                      isShopOwner: widget.isShopOwner,
                      focusedMonth: data.focusedMonth,
                      onDaySelected: (selectedDay) async {
                        await HapticFeedbackUtils.triggerSelectionFeedback();
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
                          totalAmountMinor: booking.totalAmountMinor,
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
                          totalAmountMinor: booking.totalAmountMinor,
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

              SliverToBoxAdapter(
                child: Column(children: [Gap(Spacing.xxl * 2)]),
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
      padding: 0,
      widget: DayAppointmentsSheet(
        date: selectedDay,
        bookings: dayBookings,
        isShopView: data.viewType == CalendarViewType.shop,
        isShopOwner: widget.isShopOwner,
      ),
    );
  }
}

/// Shown by [CalendarScreen] when the client-side authorization guard
/// rejects the requested view (signed-out user, mismatched user id, or
/// shop id not owned by the signed-in user).
class _CalendarUnauthorized extends StatelessWidget {
  const _CalendarUnauthorized();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.lg.w),
        child: EmptyStateWidget(
          title: 'Not available',
          subtitle: 'You do not have permission to view these bookings.',
        ),
      ),
    );
  }
}
