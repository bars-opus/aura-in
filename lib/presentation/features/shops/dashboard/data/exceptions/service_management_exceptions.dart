// lib/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart
//
// ServiceManagementException hierarchy. Same shape as
// BusinessHoursException / WalletException / PromotionException.

class ServiceManagementException implements Exception {
  /// Internal/debug message. Logs only. May contain ids.
  final String message;

  /// Stable identifier the UI maps to localized copy.
  final String code;

  /// Sanitized, user-facing message safe to show as-is.
  final String userMessage;

  ServiceManagementException(
    this.message, {
    this.code = 'SERVICE_GENERIC',
    String? userMessage,
  }) : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'ServiceManagementException($code): $message';
}

class ServiceNotFoundException extends ServiceManagementException {
  ServiceNotFoundException(String slotId)
      : super(
          'Service not found: $slotId',
          code: 'SERVICE_NOT_FOUND',
          userMessage: "We couldn't find that service.",
        );
}

class ServiceArchiveFailedException extends ServiceManagementException {
  ServiceArchiveFailedException()
      : super(
          'archive_appointment_slot RPC failed (unmapped error)',
          code: 'SERVICE_ARCHIVE_FAILED',
          userMessage:
              "We couldn't archive that service. Please try again.",
        );
}

class ServiceSaveFailedException extends ServiceManagementException {
  ServiceSaveFailedException()
      : super(
          'Service save failed (unmapped error)',
          code: 'SERVICE_SAVE_FAILED',
          userMessage: "We couldn't save the service. Please try again.",
        );
}

class InvalidServicePayloadException extends ServiceManagementException {
  InvalidServicePayloadException()
      : super(
          'Service payload failed server-side validation',
          code: 'SERVICE_INVALID_PAYLOAD',
          userMessage: 'Please re-check the service details.',
        );
}
