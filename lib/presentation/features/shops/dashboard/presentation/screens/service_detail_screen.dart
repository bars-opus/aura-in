// lib/features/dashboard/presentation/screens/service_detail_screen.dart
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/presentation/widgets/client_booking_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_performance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/service_list_item.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/utility/date_range_utils.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String slotId;
  final String serviceName;
  final String shopCurrencyCode;

  final AnalyticsPeriod period;

  const ServiceDetailScreen({
    super.key,
    required this.shopId,
    required this.slotId,
    required this.serviceName,
    required this.period,
    required this.shopCurrencyCode,
  });

  @override
  ConsumerState<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ShopCalendarBooking> _bookings = [];
  List<WorkerPerformance> _workers = [];
  bool _isLoadingBookings = true;
  bool _isLoadingWorkers = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadBookings(), _loadWorkers()]);
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoadingBookings = true);

    try {
      final repository = ref.read(dashboardRepositoryProvider);
      final (startDate, endDate) = _getDateRange();

      final bookings = await repository.getServiceBookings(
        slotId: widget.slotId,
        startDate: startDate,
        endDate: endDate,
        limit: 50,
      );

      setState(() {
        _bookings = bookings;
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoadingWorkers = true);

    try {
      final repository = ref.read(dashboardRepositoryProvider);
      final (startDate, endDate) = _getDateRange();

      final workers = await repository.getWorkersForService(
        slotId: widget.slotId,
        startDate: startDate,
        endDate: endDate,
        limit: 20,
      );

      setState(() {
        _workers = workers;
        _isLoadingWorkers = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingWorkers = false;
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

    final tabs = [
      AppTabItem(
        label: 'Bookings',
        // icon: Icons.article,
        content: _buildBookingsTab(),
      ),
      AppTabItem(
        label: 'Workers',
        // icon: Icons.help_outline,
        content: _buildWorkersTab(),
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
                Text(
                  _periodDisplay,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),

            AppTextButton(),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: TabsWithContent(
        useNestedScrollMode: false,
        tabs: tabs.toList(),
        initialIndex: 0,
        scrollable: false,
        showContent: true,
      ),
    );
  }

  _loading() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: 10,
      padding: EdgeInsets.only(top: Spacing.md.h),
      separatorBuilder: (_, __) => Gap(Spacing.sm.h),
      itemBuilder: (_, __) => ShopSchimmerSkeleton(height: 100.h),
    );
  }

  Widget _buildBookingsTab() {
    if (_isLoadingBookings) {
      return _loading();
    }

    if (_error != null && _bookings.isEmpty) {
      return Center(
        child: ErrorStateWidget(
          subtitle: 'Failed to load bookings',
          onPrimaryAction: _loadBookings,
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.calendar_month_outlined,
          subtitle: 'No bookings for $_periodDisplay',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Padding(
            padding: EdgeInsets.only(bottom: Spacing.sm.h),
            child: ClientBookingCard(
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkersTab() {
    if (_isLoadingWorkers) {
      return _loading();
    }

    if (_error != null && _workers.isEmpty) {
      return Center(
        child: ErrorStateWidget(
          subtitle: 'Failed to load workers',
          onPrimaryAction: _loadWorkers,
        ),
      );
    }

    if (_workers.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.person,
          subtitle: 'No workers for $_periodDisplay, services',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkers,
      child: ListView.builder(
        padding: EdgeInsets.all(Spacing.md.h),
        itemCount: _workers.length,
        itemBuilder: (context, index) {
          final worker = _workers[index];

          return ServiceListItem(
            rank: index + 1,
            isWorker: true,
            showDivider: true,
            name: worker.name,
            bookingCount: worker.bookingCount,
            averageRating: worker.averageRating ?? 0,
            percentage: 0.0,
            onTap: () {},
            revenue: worker.revenue,
            profileImageUrl: worker.profileImageUrl,
            shopCurrencyCode: widget.shopCurrencyCode,
          );
        },
      ),
    );
  }
}
