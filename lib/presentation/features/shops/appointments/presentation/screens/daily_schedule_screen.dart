import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/presentation/widgets/client_booking_card.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/presentation/widgets/horizontal_date_selector.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/models/time_group.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_notifier.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_state.dart';

class DailyScheduleScreen extends ConsumerStatefulWidget {
  final String shopId;

  const DailyScheduleScreen({super.key, required this.shopId});

  @override
  ConsumerState<DailyScheduleScreen> createState() =>
      _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends ConsumerState<DailyScheduleScreen> {
  TimeGroup? _selectedTimeGroup;

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(
      dailyScheduleNotifierProvider(widget.shopId),
    );
    final scheduleNotifier = ref.read(
      dailyScheduleNotifierProvider(widget.shopId).notifier,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await scheduleNotifier.refreshDate(scheduleState.selectedDate);
          setState(() {});
        },
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            // Header section (non-scrollable content as sliver)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  CardInkWell(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    onTap: () {},
                    child: Column(
                      children: [
                        HorizontalDateSelector(
                          selectedDate: scheduleState.selectedDate,
                          onDateSelected: (date) {
                            scheduleNotifier.selectDate(date);
                            setState(() {
                              _selectedTimeGroup = null;
                            });
                          },
                          getLoadingState:
                              (date) => scheduleNotifier.isLoading(date),
                        ),
                        AppDivider(),
                        Gap(Spacing.sm.h),
                        _buildTimeGroupFilterChips(),
                        Gap(Spacing.md.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Appointments list as a sliver list (scrolls with the rest)
            SliverPadding(
              padding: EdgeInsets.only(top: Spacing.md.h),
              sliver: _buildAppointmentsSliver(
                context,
                scheduleNotifier,
                scheduleState,
                scheduleState.selectedDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeGroupFilterChips() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filterChips = [
      'All',
      TimeGroup.morning.displayName,
      TimeGroup.afternoon.displayName,
      TimeGroup.evening.displayName,
    ];

    final filterIcons = {
      'All': Icons.view_list,
      TimeGroup.morning.displayName: Icons.wb_sunny,
      TimeGroup.afternoon.displayName: Icons.sunny,
      TimeGroup.evening.displayName: Icons.nights_stay,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              filterChips.map((filter) {
                final isSelected =
                    (filter == 'All' && _selectedTimeGroup == null) ||
                    (filter == TimeGroup.morning.displayName &&
                        _selectedTimeGroup == TimeGroup.morning) ||
                    (filter == TimeGroup.afternoon.displayName &&
                        _selectedTimeGroup == TimeGroup.afternoon) ||
                    (filter == TimeGroup.evening.displayName &&
                        _selectedTimeGroup == TimeGroup.evening);

                final icon = filterIcons[filter];

                return Padding(
                  padding: EdgeInsets.only(right: Spacing.xs.w),
                  child: AppFilterChip(
                    // avatarIcon: icon,
                    label: filter,
                    borderWidth: 0.3,
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (filter == 'All') {
                          _selectedTimeGroup = null;
                        } else if (filter == TimeGroup.morning.displayName) {
                          _selectedTimeGroup = TimeGroup.morning;
                        } else if (filter == TimeGroup.afternoon.displayName) {
                          _selectedTimeGroup = TimeGroup.afternoon;
                        } else if (filter == TimeGroup.evening.displayName) {
                          _selectedTimeGroup = TimeGroup.evening;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // New method to build appointments as sliver
  Widget _buildAppointmentsSliver(
    BuildContext context,
    DailyScheduleNotifier notifier,
    DailyScheduleState state,
    DateTime date,
  ) {
    final appointmentsAsync = state.getAppointmentsForDate(widget.shopId, date);

    if (appointmentsAsync == null || appointmentsAsync.isLoading) {
      return SliverFillRemaining(child: _buildLoadingState());
    }

    if (appointmentsAsync.hasError) {
      return SliverFillRemaining(child: _buildErrorState(notifier, date));
    }

    final allAppointments = appointmentsAsync.value!;
    final filteredAppointments = _filterAppointmentsByTimeGroup(
      allAppointments,
    );

    if (filteredAppointments.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(date));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final booking = filteredAppointments[index];
        final isLast = index == filteredAppointments.length - 1;

        return CardInkWell(
          padding: const EdgeInsets.all(Spacing.sm),
          margin: const EdgeInsets.all(0),
          onTap: () {},
          child: ClientBookingCard(
            startTime: booking.startTime,
            endTime: booking.endTime,
            bookingId: booking.id,
            totalAmount: booking.totalAmount,
            shopCurrency: booking.shopCurrency,
            shopType: '@${booking.userName}',
            shopName: booking.clientName,
            shopLogoUrl: booking.clientAvatarUrl,
            shopAddress: '',
            serviceName: booking.serviceName,
            shouldPop: false,
            status: booking.status,
            isShopOwner: true,
            showDivider: !isLast,
          ),
        );
      }, childCount: filteredAppointments.length),
    );
  }

  List<ShopCalendarBooking> _filterAppointmentsByTimeGroup(
    List<ShopCalendarBooking> appointments,
  ) {
    if (_selectedTimeGroup == null) {
      return appointments;
    }

    return appointments.where((booking) {
      final group = TimeGroupExtensions.fromDateTime(booking.startTime);
      return group == _selectedTimeGroup;
    }).toList();
  }

  Widget _buildLoadingState() {
    return CardInkWell(
      padding: const EdgeInsets.all(Spacing.sm),
      margin: const EdgeInsets.all(0),
      onTap: () {},
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
        shrinkWrap: true,
        itemCount: 5,
        separatorBuilder: (_, __) => Gap(Spacing.xs.w),
        itemBuilder: (_, __) => ShopSchimmerSkeleton(height: 100),
      ),
    );
  }

  Widget _buildErrorState(DailyScheduleNotifier notifier, DateTime date) {
    return Center(
      child: ErrorStateWidget(
        title: 'Failed to load appointments',
        subtitle: 'Pull down to refresh or tap retry',
        onPrimaryAction: () => notifier.refreshDate(date),
      ),
    );
  }

  Widget _buildEmptyState(DateTime date) {
    final message =
        _selectedTimeGroup == null
            ? 'No appointments for ${_formatDate(date)}'
            : 'No ${_selectedTimeGroup!.displayName.toLowerCase()} appointments for ${_formatDate(date)}';

    return Center(
      child: EmptyStateWidget(
        title: message,
        icon: Icons.event_busy,
        subtitle: 'When appointment becomes available, it will appear here.',
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
