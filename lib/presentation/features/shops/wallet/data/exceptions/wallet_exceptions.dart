// lib/features/wallet/data/exceptions/wallet_exceptions.dart

class WalletException implements Exception {
  final String message;
  final String? code;

  WalletException(this.message, {this.code});

  @override
  String toString() => 'WalletException: $message${code != null ? ' (code: $code)' : ''}';
}

class InsufficientBalanceException extends WalletException {
  InsufficientBalanceException(double current, double attempted)
      : super('Insufficient balance. Current: $current, Attempted: $attempted');
}

class WalletNotFoundException extends WalletException {
  WalletNotFoundException(String shopId)
      : super('Wallet not found for shop: $shopId');
}

class WithdrawalLimitExceededException extends WalletException {
  WithdrawalLimitExceededException(double limit, double attempted)
      : super('Withdrawal limit exceeded. Max: $limit, Attempted: $attempted');
}

class InvalidWithdrawalAmountException extends WalletException {
  InvalidWithdrawalAmountException()
      : super('Withdrawal amount must be greater than 0');
}
