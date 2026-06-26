import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/appointment_actions.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/exceptions/booking_error_messages.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final String bookingId;
  final String shopCurrency;
  final String shopName;
  final String shopType;
  final String? shopLogoUrl;
  final String shopAddress;

  /// Money in int minor units (kobo / cents). Display via [formatMoney].
  /// Checklist v3.1 P0-U 2.19.
  final int totalAmountMinor;
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
    required this.totalAmountMinor,
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
        data: (bookingDetailData) =>
            _buildContent(context, bookingDetailData, false),
        loading: () => _buildContent(context, null, true),
        error:
            (error, stack) => ErrorStateWidget(
              title: '',
              subtitle: BookingErrorMessages.forUser(error),
              compact: true,
              onPrimaryAction: () {
                ref.invalidate(bookingDetailProvider(widget.bookingId));
              },
              type: ErrorStateType.genericError,
            ),
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
    final effectiveShopCurrency =
        widget.shopCurrency.isNotEmpty
            ? widget.shopCurrency
            : (ref.watch(currentShopProvider)?.currency ?? '');

    if (isLoading) {
      return Stack(
        alignment: FractionalOffset.bottomCenter,
        children: [
          CustomScrollView(
            slivers: [
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
                      ],
                    ),
                    Gap(Spacing.md.h),
                    Container(
                      color: colorScheme.surface,
                      padding: EdgeInsets.all(Spacing.md.h),
                      margin: EdgeInsets.only(top: Spacing.lg.h),
                      height: 700.h,
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
              child: Padding(
                padding: EdgeInsets.all(Spacing.md),
                child: CircularLoadingIndicator(),
              ),
            ),
          ),
        ],
      );
    }

    final booking = bookingDetail!;

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
                            formatMoney(
                              widget.totalAmountMinor,
                              effectiveShopCurrency,
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
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
                            color: colorScheme.onSurface,
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
                  Column(
                        children: [
                          Gap(Spacing.lg.h),
                          ClientServiceCard(
                            onRequirementsSaved: () {
                              // This invalidates the booking provider
                              ref.invalidate(
                                bookingDetailProvider(widget.bookingId),
                              );
                            },
                            status: booking.status.name,
                            isShopOwner: widget.isShopOwner,
                            label: 'Service',
                            shopCurrency: effectiveShopCurrency,
                            booking: booking,
                          ),
                          if (widget.isShopOwner) ...[
                            Gap(Spacing.sm.h),
                            ClientStickyNoteCard(booking: booking),
                          ],
                          if (!widget.isShopOwner)
                            BookingShopInfoCard(
                              shopType: widget.shopType,
                              shopId: '',
                              shopName: widget.shopName,
                              shopLogoUrl: widget.shopLogoUrl,
                              shopAddress:
                                  widget.shopAddress.isEmpty
                                      ? booking.shopAddress ??
                                          widget.shopAddress
                                      : widget.shopAddress,
                              latitude: booking.latitude ?? 0,
                              longitude: booking.longitude ?? 0,
                              bookingId: booking.id,
                              status: booking.status.name,
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
            child: AppointmentActions(
              isShopOwner: widget.isShopOwner,
              shopId: booking.shopId,
              startTime: booking.startTime,
              bookingId: booking.id,
              status: booking.status.name,
              shopName: booking.clientName ?? '',
            ),
          ),
        ),
      ],
    );
  }
}
