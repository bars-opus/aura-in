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
