import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/presentation/widgets/client_booking_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/utility/date_range_utils.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';

class WorkerBookingsScreen extends ConsumerStatefulWidget {
  final String workerId;
  final String workerName;
  final AnalyticsPeriod period; // ✅ Use period instead of dates

  const WorkerBookingsScreen({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.period, // ✅ Required
  });

  @override
  ConsumerState<WorkerBookingsScreen> createState() =>
      _WorkerBookingsScreenState();
}

class _WorkerBookingsScreenState extends ConsumerState<WorkerBookingsScreen> {
  List<ShopCalendarBooking> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(dashboardRepositoryProvider);
      final (startDate, endDate) = _getDateRange();
      final bookings = await repository.getWorkerBookings(
        workerId: widget.workerId,
        fromDate: startDate,
        toDate: endDate,
        limit: 100, // Get all bookings for the period
      );

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  (DateTime startDate, DateTime endDate) _getDateRange() {
    return DateRangeUtils.getDateRangeForPeriod(widget.period);
  }

  String get _periodDisplay {
    return widget.period == AnalyticsPeriod.weekly ? 'This Week' : 'This Month';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.workerName}\'s\nBookings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
                AppTextButton(),
              ],
            ),

            AppDivider(),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return ListView.separated(
        padding: EdgeInsets.only(top: Spacing.sm.h),
        itemCount: 10,
        separatorBuilder: (_, __) => Gap(Spacing.sm.h),
        itemBuilder: (_, __) => ShopSchimmerSkeleton(height: 100.h),
      );
    }

    if (_error != null) {
      return Center(
        child: ErrorStateWidget(
          subtitle: _error!,
          onPrimaryAction: _loadBookings,
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.calendar_month_outlined,
          title: 'No Bookings',
          subtitle: 'No bookings for $_periodDisplay',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: EdgeInsets.all(Spacing.md.h),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return ClientBookingCard(
            startTime: booking.startTime,
            endTime: booking.endTime,
            totalAmountMinor: booking.totalAmountMinor,
            shopCurrency: booking.shopCurrency,
            shopType: booking.userName,
            shopName: booking.clientName,
            shopLogoUrl: booking.clientAvatarUrl,
            shopAddress: '',
            serviceName: booking.serviceName,
            shouldPop: false,
            bookingId: booking.id,
            status: booking.status,
            isShopOwner: true,
          );
        },
      ),
    );
  }
}
