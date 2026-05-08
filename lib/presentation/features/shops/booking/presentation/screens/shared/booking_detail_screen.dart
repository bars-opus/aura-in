import 'package:nano_embryo/presentation/features/shops/booking/data/models/status_config.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/appointment_actions.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/status_widget.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final String bookingId;
  final String shopCurrency;
  final String shopName;
  final String shopType;
  final String? shopLogoUrl;
  final String shopAddress;
  final double totalAmount;
  final BookingModel? preLoadedBookingDetail;
  final bool isShopOwner;

  final VoidCallback? onMarkComplete;

  final VoidCallback? onMarkNoShow;

  const BookingDetailScreen({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.shopCurrency,
    required this.shopAddress,
    required this.bookingId,
    required this.shopType,
    required this.shopLogoUrl,
    required this.shopName,
    required this.totalAmount,
    required this.isShopOwner,
    required this.preLoadedBookingDetail,
    this.onMarkComplete,

    this.onMarkNoShow,
  });

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch booking data

    // Declare the async value variable
    final AsyncValue<BookingModel> bookingAsync;

    // Assign based on condition
    if (widget.preLoadedBookingDetail == null) {
      bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));
    } else {
      // Convert pre-loaded data to AsyncValue
      bookingAsync = AsyncValue.data(widget.preLoadedBookingDetail!);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: bookingAsync.when(
        data: (BookingDetail) => _buildContent(context, BookingDetail, false),
        loading: () => _buildContent(context, null, true),
        error:
            (error, stack) => ErrorStateWidget(
              title: '',
              subtitle: 'Failed to fetch booking',
              compact: true,
              onPrimaryAction: () {
                ref.invalidate(bookingDetailProvider(widget.bookingId));
              },
              type: ErrorStateType.genericError,
            ),

        // _buildError(context, error.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingModel? bookingDetail,
    bool isLoading,
  ) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: FractionalOffset.bottomCenter,
      children: [
        CustomScrollView(
          slivers: [
            // Main Content
            SliverPadding(
              padding: EdgeInsets.all(0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: AppIconButton(
                          icon: Icons.close,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${widget.shopCurrency} ${widget.totalAmount.toString()}',
                            // _formatDate(booking.startTime),
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (widget.isShopOwner)
                    Column(
                      children: [
                        ProfileAvatar(
                          avatarUrl: widget.shopLogoUrl ?? '',
                          currentUserId: '',
                          size: 50,
                        ),
                        Gap(Spacing.sm.h),
                        Text(
                          widget.shopName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onBackground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                  Gap(Spacing.md.h),
                  Text(
                    '4 days more',
                    // _formatDate(booking.startTime),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Gap(Spacing.md.h),

                  TimeslotDurationWidget(
                    startTime: widget.startTime,
                    endTime: widget.endTime,
                  ),

                  // // Status Header
                  // BookingStatusHeader(booking: booking),
                  isLoading
                      ? Container(
                        color: colorScheme.background,
                        padding: EdgeInsets.all(Spacing.md.h),
                        margin: EdgeInsets.only(top: Spacing.lg.h),
                        height: 700.h,
                      )
                      : bookingDetail == null
                      ? SizedBox.shrink()
                      : Column(
                        children: [
                          Gap(Spacing.lg.h),
                          ClientServiceCard(
                            onRequirementsSaved: () {
                              // This invalidates the booking provider
                              ref.invalidate(
                                bookingDetailProvider(widget.bookingId),
                              );
                            },
                            status:
                                bookingDetail == null
                                    ? ''
                                    : bookingDetail!.status.name,
                            isShopOwner: widget.isShopOwner,
                            label: 'Service',
                            shopCurrency: widget.shopCurrency,
                            booking: bookingDetail,
                          ),
                          if (!widget.isShopOwner)
                            BookingShopInfoCard(
                              shopType: widget.shopType,
                              shopId: '',
                              shopName: widget.shopName,
                              shopLogoUrl: widget.shopLogoUrl,
                              shopAddress:
                                  widget.shopAddress.isEmpty
                                      ? bookingDetail.shopAddress ??
                                          widget.shopAddress
                                      : widget.shopAddress,
                              latitude: bookingDetail.latitude ?? 0,
                              longitude: bookingDetail.longitude ?? 0,
                              bookingId: bookingDetail.id,
                              status: bookingDetail.status.name,
                              // booking: bookingDetail
                            ),
                        ],
                      ),
                  Gap(Spacing.xxl.h),
                  Gap(Spacing.xxl.h),
                ]),
              ),
            ),
          ],
        ),

        Positioned(
          bottom: 10,
          child: ShakeTransition(
            curve: Curves.easeOutBack,
            axis: Axis.vertical,
            child:
                isLoading
                    ? Padding(
                      padding: EdgeInsets.all(Spacing.md),
                      child: CircularLoadingIndicator(),
                    )
                    : AppointmentActions(
                      isShopOwner: widget.isShopOwner,
                      shopId: bookingDetail!.shopId,
                      startTime: bookingDetail!.startTime,
                      bookingId: bookingDetail!.id,
                      status: bookingDetail.status.name,
                      shopName: bookingDetail.clientName ?? '',
                    ),
          ),
        ),
      ],
    );
  }
}
