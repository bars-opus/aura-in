import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// A reusable success dialog for booking confirmations

class BookingSuccessDialog extends StatelessWidget {
  final VoidCallback? onViewBooking;
  final VoidCallback? onDone;
  final String? title;
  final String? actionText;

  final List<String>? infoMessages;

  const BookingSuccessDialog({
    super.key,
    this.onViewBooking,
    this.onDone,
    this.title,
    this.actionText,
    this.infoMessages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Default text styles
    final bodyStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onBackground,
    );

    return Column(
      children: [
        AppTextButton(alignment: Alignment.topRight),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShakeTransition(
                child: Text(
                  '🎉',
                  style: textTheme.headlineLarge?.copyWith(
                    color: colorScheme.primary,
                    fontSize: 48.sp,
                  ),
                ),
              ),
              Gap(Spacing.sm.h),
              Text(
                title ?? 'Booking Successful!',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(Spacing.lg.h),

              infoMessages != null && infoMessages!.isNotEmpty
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        infoMessages!.map((message) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: Spacing.xs.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('•', style: bodyStyle),
                                SizedBox(width: Spacing.xs.w),
                                Expanded(
                                  child: Text(message, style: bodyStyle),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  )
                  : const SizedBox.shrink(),
              Gap(Spacing.xl.h),
              Gap(Spacing.xl.h),
              AppTextButton(
                alignment: Alignment.center,
                fontSize: 14.sp,
                text: actionText ?? 'View Booking',
                onPressed: () {
                  Navigator.pop(context);
                  onViewBooking?.call();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Static method to show the dialog
  static Future<void> show({
    required BuildContext context,
    VoidCallback? onViewBooking,
    VoidCallback? onDone,
    String? title,
    List<String>? infoMessages,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => BookingSuccessDialog(
            onViewBooking: onViewBooking,
            onDone: onDone,
            title: title,
            infoMessages: infoMessages,
          ),
    );
  }
}
