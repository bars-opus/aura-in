import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

class TimeslotDurationWidget extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final bool isMini;

  const TimeslotDurationWidget({
    super.key,
    required this.startTime,
    required this.endTime,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    _timeWidget(BuildContext context, String time, bool showIcon) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final textTheme = theme.textTheme;
      return AnimatedScaleFade(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        child: CardInkWell(
          // color: colorScheme.primaryContainer,
          elevation: showIcon ? 10 : 5,
          margin:
              showIcon
                  ? EdgeInsets.all(10)
                  : EdgeInsets.only(right: 120, left: 10),
          borderRadius: BorderRadius.circular(isMini ? 7 : 10),
          // elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: showIcon ? 10 : 8,
            vertical: showIcon ? 10 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showIcon)
                Icon(
                  Icons.time_to_leave,
                  size: 20,
                  color: colorScheme.onBackground,
                ),
              Gap(10.w),

              Expanded(
                child: Text(
                  time,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onBackground,

                    fontSize: isMini ? 12.sp : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: showIcon ? 2 : 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildTimeConnector({
      required BuildContext context,
      required String startDate,
      required String startTime,
      // required String endInfo,
      required String duration,
    }) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side with circle and connecting line
          SizedBox(
            width: 30.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top circle
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                    border: Border.all(color: colorScheme.background, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Connecting line
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom circle
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withOpacity(0.7),
                    border: Border.all(color: colorScheme.background, width: 2),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(width: Spacing.sm.w),
          // Right side with time information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Start time widget
                _timeWidget(context, startDate, true),
                SizedBox(height: Spacing.sm.h),
                // End time widget
                _timeWidget(context, '$startTime,     $duration', false),
              ],
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 120.h,
      width: double.infinity,
      child: _buildTimeConnector(
        context: context,
        startDate:
            "${MyDateFormat.toDate(startTime)}\n${MyDateFormat.toTime(startTime)}",
        startTime: MyDateFormat.toTime(startTime),
        duration: DurationUtils.formatForDisplay(endTime.difference(startTime)),

        // _calculateDuration(startTime, endTime),
      ),
    );
  }
}
