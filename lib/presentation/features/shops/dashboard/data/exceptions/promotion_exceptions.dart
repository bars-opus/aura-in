// lib/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart
//
// Promotion exception hierarchy. Mirrors lib/wallet/data/exceptions/
// wallet_exceptions.dart byte-for-byte in shape: each subtype carries
// a stable `code` (so the UI can map to localized copy without parsing
// English) and a `userMessage` that is safe to render directly (no
// internal IDs, no Postgrest payload).
//
// `message` is for logs only — never render it in the UI.

class PromotionException implements Exception {
  /// Internal/debug message. Logs only. May contain identifiers.
  final String message;

  /// Stable identifier the UI maps to localized copy.
  final String code;

  /// Sanitized, user-facing message safe to show as-is.
  final String userMessage;

  PromotionException(
    this.message, {
    this.code = 'PROMO_GENERIC',
    String? userMessage,
  }) : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'PromotionException($code): $message';
}

class DuplicateCodeException extends PromotionException {
  DuplicateCodeException()
      : super(
          'Promotion code already exists for this shop',
          code: 'PROMO_DUPLICATE_CODE',
          userMessage: 'A promotion with that code already exists.',
        );
}

class PromotionNotFoundException extends PromotionException {
  PromotionNotFoundException(String id)
      : super(
          'Promotion not found: $id',
          code: 'PROMO_NOT_FOUND',
          userMessage: "We couldn't find that promotion.",
        );
}

class PromotionLimitReachedException extends PromotionException {
  PromotionLimitReachedException()
      : super(
          'Promotion usage limit reached',
          code: 'PROMO_LIMIT_REACHED',
          userMessage: 'This promotion has reached its usage limit.',
        );
}

class InvalidDiscountAmountException extends PromotionException {
  InvalidDiscountAmountException()
      : super(
          'Discount amount must be positive',
          code: 'PROMO_INVALID_AMOUNT',
          userMessage: 'Please enter a valid discount amount.',
        );
}

// ── Phase 13 — validate_and_apply_promo eligibility rejections ───────
//
// Each subtype corresponds to one HINT code raised by the RPC. Dart
// branches on the HINT, NOT on the message text. See
// SupabaseDashboardRepository._classifyPromoError (or equivalent
// classifier in PromotionsRepository) for the HINT-to-subtype routing.

class PromoExpiredException extends PromotionException {
  PromoExpiredException()
      : super(
          'Promo code outside its valid_from / valid_to window',
          code: 'PROMO_EXPIRED',
          userMessage: "This code has expired or isn't yet active.",
        );
}

class PromoMinAmountNotMetException extends PromotionException {
  PromoMinAmountNotMetException()
      : super(
          'Booking total is below the code min_booking_amount',
          code: 'PROMO_MIN_AMOUNT',
          userMessage:
              'Your booking total is below the minimum for this code.',
        );
}

class PromoServiceNotEligibleException extends PromotionException {
  PromoServiceNotEligibleException()
      : super(
          'Booking services do not overlap with code service_restriction',
          code: 'PROMO_SERVICE_RESTRICTION',
          userMessage:
              "This code doesn't apply to the selected service.",
        );
}

class PromoPerClientMaxException extends PromotionException {
  PromoPerClientMaxException()
      : super(
          'Caller has already redeemed this code per_client_max times',
          code: 'PROMO_PER_CLIENT_MAX',
          userMessage:
              "You've already used this code the maximum number of times.",
        );
}

class PromoWrongClientException extends PromotionException {
  PromoWrongClientException()
      : super(
          'Silent code target_* does not match caller identity',
          code: 'PROMO_WRONG_CLIENT',
          userMessage: "This code isn't valid for your account.",
        );
}

class LoyaltyRuleSaveFailedException extends PromotionException {
  LoyaltyRuleSaveFailedException()
      : super(
          'upsert_loyalty_rule RPC failed (unmapped error)',
          code: 'LOYALTY_SAVE_FAILED',
          userMessage:
              "We couldn't save the loyalty rule. Please try again.",
        );
}
