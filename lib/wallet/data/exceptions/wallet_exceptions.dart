// lib/features/wallet/data/exceptions/wallet_exceptions.dart
//
// Wallet exception hierarchy. Each subtype carries a stable `code` so the
// UI can map to a user-facing message without parsing English strings,
// and a sanitized `userMessage` that is safe to display directly (no
// internal IDs, balances, or stack traces). The `message` field is for
// logs only — never render it in the UI.

class WalletException implements Exception {
  /// Internal/debug message. Logs only. May contain identifiers.
  final String message;

  /// Stable identifier the UI can map to a localized message.
  final String code;

  /// Sanitized, user-facing message safe to show as-is.
  final String userMessage;

  WalletException(
    this.message, {
    this.code = 'WALLET_GENERIC',
    String? userMessage,
  }) : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'WalletException($code): $message';
}

class InsufficientBalanceException extends WalletException {
  InsufficientBalanceException()
      : super(
          'Insufficient available balance',
          code: 'WALLET_INSUFFICIENT',
          userMessage:
              "You don't have enough available balance for this withdrawal.",
        );
}

class WalletNotFoundException extends WalletException {
  WalletNotFoundException(String shopId)
      : super(
          'Wallet not found for shop: $shopId',
          code: 'WALLET_NOT_FOUND',
          userMessage:
              "We couldn't find your wallet. Please contact support.",
        );
}

class WithdrawalLimitExceededException extends WalletException {
  WithdrawalLimitExceededException()
      : super(
          'Daily withdrawal limit reached',
          code: 'WALLET_DAILY_LIMIT',
          userMessage:
              "You've reached today's withdrawal limit. Try again tomorrow.",
        );
}

class InvalidWithdrawalAmountException extends WalletException {
  InvalidWithdrawalAmountException()
      : super(
          'Withdrawal amount must be greater than 0',
          code: 'WALLET_INVALID_AMOUNT',
          userMessage: 'Please enter a valid withdrawal amount.',
        );
}

class PaymentSetupMissingException extends WalletException {
  PaymentSetupMissingException()
      : super(
          'Payment method not configured',
          code: 'WALLET_NO_PAYMENT_METHOD',
          userMessage:
              'Connect a payment method before requesting a withdrawal.',
        );
}

class DuplicateWithdrawalException extends WalletException {
  DuplicateWithdrawalException()
      : super(
          'Duplicate withdrawal request',
          code: 'WALLET_DUPLICATE',
          userMessage:
              'A similar withdrawal was just submitted. Please wait a moment.',
        );
}
