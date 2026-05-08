import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// Predefined error types for consistent error handling
enum ErrorStateType {
  networkError, // Network/connection issues
  serverError, // Server 5xx errors
  clientError, // Client 4xx errors
  parsingError, // Data parsing failures
  permissionError, // Missing permissions
  genericError, // Unknown/generic errors
  custom, // Custom configuration
}

class ErrorStateWidget extends StatelessWidget {
  final ErrorStateType type;
  final String? title;
  final String? subtitle;
  final String? errorDetails;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final bool showDetails;
  final bool compact;

  const ErrorStateWidget({
    super.key,
    this.type = ErrorStateType.genericError,
    this.title,
    this.subtitle,
    this.errorDetails = '',
    this.primaryActionLabel,
    this.secondaryActionLabel,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.showDetails = false,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final config = _getConfiguration(context);

    return Container(
      padding:
          compact
              ? EdgeInsets.all(Spacing.lg.h)
              : EdgeInsets.symmetric(
                vertical: Spacing.xxl.h,
                horizontal: Spacing.xl.w,
              ),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon with background
          Icon(
            config.$1,
            size: compact ? 48.h : 60.h,
            color: colorScheme.error,
          ),

          Gap(Spacing.md.h),
          // Title
          if (title != null)
            Padding(
              padding: EdgeInsets.only(bottom: Spacing.sm.h),
              child: Text(
                title ?? config.$2!,
                style:
                    compact
                        ? textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        )
                        : textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                textAlign: TextAlign.center,
              ),
            ),

          // Subtitle
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(bottom: compact ? 0 : Spacing.xxl.h),
              child: Text(
                subtitle ?? config.$3!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Error details (expandable)
          if (errorDetails!.isNotEmpty)
            if (errorDetails != null && showDetails)
              _ErrorDetails(
                details: errorDetails!,
                colorScheme: colorScheme,
                compact: compact,
              ),

          Gap(compact ? Spacing.sm.h : Spacing.xxl.h),
          if (onPrimaryAction != null)
            Center(
              child: AppTextButton(
                alignment: Alignment.center,
                text: primaryActionLabel ?? config.$4,
                onPressed: onPrimaryAction,
              ),
            ),
        ],
      ),
    );
  }

  // Returns: (icon, title, subtitle, primaryActionLabel, secondaryActionLabel)
  (IconData, String, String, String?, String?) _getConfiguration(
    BuildContext context,
  ) {
    final loc = AppLocalizations.of(context);

    switch (type) {
      case ErrorStateType.networkError:
        return (
          Icons.wifi_off_outlined,
          loc?.errorNetworkTitle ?? 'Connection Error',
          loc?.errorNetworkSubtitle ??
              'Unable to connect to the server. Check your internet connection.',
          loc?.errorRetry ?? 'Try again',
          loc?.errorCheckSettings ?? 'Check settings',
        );
      case ErrorStateType.serverError:
        return (
          Icons.cloud_off_outlined,
          loc?.errorServerTitle ?? 'Server Error',
          loc?.errorServerSubtitle ??
              'Something went wrong on our end. Please try again later.',
          loc?.errorRetry ?? 'Try again',
          loc?.errorReport ?? 'Report issue',
        );
      case ErrorStateType.clientError:
        return (
          Icons.error_outline_outlined,
          loc?.errorClientTitle ?? 'Request Error',
          loc?.errorClientSubtitle ??
              'There was a problem with your request. Please check and try again.',
          loc?.errorRetry ?? 'Try again',
          loc?.errorGoBack ?? 'Go back',
        );
      case ErrorStateType.parsingError:
        return (
          Icons.data_object_outlined,
          loc?.errorParsingTitle ?? 'Data Error',
          loc?.errorParsingSubtitle('data') ??
              'Unable to process the data. This might be a temporary issue.',
          loc?.errorRetry ?? 'Try again',
          loc?.errorRefresh ?? 'Refresh',
        );
      case ErrorStateType.permissionError:
        return (
          Icons.lock_outline,
          loc?.errorPermissionTitle ?? 'Access Denied',
          loc?.errorPermissionSubtitle('data') ??
              'You don\'t have permission to access this content.',
          loc?.errorRequestAccess ?? 'Request access',
          loc?.errorGoBack ?? 'Go back',
        );
      case ErrorStateType.genericError:
        return (
          Icons.error_outline_outlined,
          loc?.errorGenericTitle ?? 'Something went wrong',
          loc?.errorGenericSubtitle('data') ??
              'An unexpected error occurred. Please try again.',
          loc?.errorRetry ?? 'Try again',
          loc?.errorContactSupport ?? 'Contact support',
        );
      case ErrorStateType.custom:
        return (
          Icons.error_outline_outlined,
          'Error',
          'An error occurred.',
          'Retry',
          null,
        );
    }
  }
}

/// Expandable error details section
class _ErrorDetails extends StatefulWidget {
  final String details;
  final ColorScheme colorScheme;
  final bool compact;

  const _ErrorDetails({
    required this.details,
    required this.colorScheme,
    required this.compact,
  });

  @override
  State<_ErrorDetails> createState() => _ErrorDetailsState();
}

class _ErrorDetailsState extends State<_ErrorDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc?.errorGenericTitle ?? 'Something went wrong',

                style: TextStyle(
                  color: widget.colorScheme.primary,
                  fontSize: widget.compact ? 12.sp : 14.sp,
                ),
              ),
              Gap(Spacing.xs.w),
              Icon(
                _expanded ? Icons.expand_more : Icons.expand_more,
                size: widget.compact ? 16.h : 20.h,
                color: widget.colorScheme.primary,
              ),
            ],
          ),
        ),

        if (_expanded) ...[
          Gap(Spacing.md.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Spacing.md.w),
            decoration: BoxDecoration(
              color: widget.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: SelectableText(
              widget.details,
              style: TextStyle(
                color: widget.colorScheme.onSurfaceVariant,
                fontSize: widget.compact ? 11.sp : 12.sp,
                fontFamily: 'Monospace',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
