// lib/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions.dart
//
// Phase 15 — typed exception hierarchy for the pricing_overrides surface.
// Mirrors PromotionException's shape: stable `code` + sanitized
// `userMessage`. The screen layer maps `code` to a localized string via
// app_en.arb where available; the fallback keeps the DTO testable.

class PricingOverrideException implements Exception {
  /// Internal/debug message. Logs only. May contain identifiers.
  final String message;

  /// Stable identifier the UI maps to localized copy.
  final String code;

  /// Sanitized, user-facing message safe to show as-is.
  final String userMessage;

  PricingOverrideException(
    this.message, {
    this.code = 'OVERRIDE_GENERIC',
    String? userMessage,
  }) : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'PricingOverrideException($code): $message';
}

class OverrideAccessDeniedException extends PricingOverrideException {
  OverrideAccessDeniedException()
      : super(
          'Caller does not own the parent shop (42501)',
          code: 'OVERRIDE_NOT_FOUND',
          userMessage: "We couldn't find that pricing rule.",
        );
}

class OverrideWindowInvalidException extends PricingOverrideException {
  OverrideWindowInvalidException()
      : super(
          'time_window_end must be after time_window_start',
          code: 'OVERRIDE_WINDOW_INVALID',
          userMessage: 'The end time must be after the start time.',
        );
}

class OverrideDayOfWeekInvalidException extends PricingOverrideException {
  OverrideDayOfWeekInvalidException()
      : super(
          'day_of_week out of range 1..7',
          code: 'OVERRIDE_DAY_INVALID',
          userMessage: 'Please pick a valid day of the week.',
        );
}

class OverrideAdjustmentInvalidException extends PricingOverrideException {
  OverrideAdjustmentInvalidException()
      : super(
          'Adjustment kind or value failed server validation',
          code: 'OVERRIDE_ADJUSTMENT_INVALID',
          userMessage: 'Please re-check the discount amount.',
        );
}

class OverrideValidityInvalidException extends PricingOverrideException {
  OverrideValidityInvalidException()
      : super(
          'valid_until must be after valid_from',
          code: 'OVERRIDE_VALIDITY_INVALID',
          userMessage: 'The end date must be after the start date.',
        );
}

class OverrideCapExceededException extends PricingOverrideException {
  OverrideCapExceededException()
      : super(
          'Per-slot 50-active-overrides cap reached',
          code: 'OVERRIDE_CAP_EXCEEDED',
          userMessage:
              "You've reached the 50-rule limit on this service. Archive an old rule to free a slot.",
        );
}

class OverrideSaveFailedException extends PricingOverrideException {
  OverrideSaveFailedException()
      : super(
          'pricing_overrides RPC failed (unmapped error)',
          code: 'OVERRIDE_SAVE_FAILED',
          userMessage: "We couldn't save the rule. Please try again.",
        );
}
