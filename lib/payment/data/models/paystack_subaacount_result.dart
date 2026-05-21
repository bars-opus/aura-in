// lib/features/payment/data/models/paystack_connection_result.dart

class PaystackSubaccountResult {
  final String businessName;
  final String bankCode;
  final String accountNumber;
  final String accountType; // 'bank' or 'mobile_money'
  final String? provider; // 'mtn', 'vodafone', etc. for mobile money

  const PaystackSubaccountResult({
    required this.businessName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountType,
    this.provider,
  });
}
