// lib/features/dashboard/data/models/payment_settings_model.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

enum PaymentProvider {
  stripe,
  paystack,
  none;

  String get displayName {
    switch (this) {
      case PaymentProvider.stripe:
        return 'Stripe';
      case PaymentProvider.paystack:
        return 'Paystack';
      case PaymentProvider.none:
        return 'Not Connected';
    }
  }
}

enum PayoutSchedule {
  daily,
  weekly,
  biweekly,
  monthly;

  String get displayName {
    switch (this) {
      case PayoutSchedule.daily:
        return 'Daily';
      case PayoutSchedule.weekly:
        return 'Weekly';
      case PayoutSchedule.biweekly:
        return 'Every 2 Weeks';
      case PayoutSchedule.monthly:
        return 'Monthly';
    }
  }
}

class PaymentSettings extends Equatable {
  final String shopId;
  final PaymentProvider paymentProvider;

  // Stripe fields (all nullable)
  final String? stripeAccountId;
  final bool? stripeVerified;
  final String? stripeCurrency;

  // Paystack fields (all nullable)
  final String? paystackSubaccountCode;
  final String? paystackRecipientId;
  final bool? paystackVerified;
  final String? paystackCurrency;

  // Common fields
  final PayoutSchedule payoutSchedule;
  final double payoutMinimum;
  final String payoutCurrency;

  final DateTime? connectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool autoPayoutEnabled;

  const PaymentSettings({
    required this.shopId,
    required this.paymentProvider,
    this.stripeAccountId,
    this.stripeVerified,
    this.stripeCurrency,
    this.paystackSubaccountCode,
    this.paystackRecipientId,
    this.paystackVerified,
    this.paystackCurrency,
    required this.payoutSchedule,
    required this.payoutMinimum,
    required this.payoutCurrency,
    this.connectedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.autoPayoutEnabled,
  });

  bool get isStripeConnected =>
      paymentProvider == PaymentProvider.stripe && stripeVerified == true;

  bool get isPaystackConnected =>
      paymentProvider == PaymentProvider.paystack && paystackVerified == true;

  bool get isConnected => isStripeConnected || isPaystackConnected;

  double get platformFeePercentage {
    if (paymentProvider == PaymentProvider.stripe) {
      return 2.9; // 2.9% for Stripe
    } else if (paymentProvider == PaymentProvider.paystack) {
      return 1.5; // 1.5% for Paystack
    }
    return 0;
  }

  double get platformFeeFixed {
    if (paymentProvider == PaymentProvider.stripe) {
      return 0.30; // $0.30 for Stripe
    } else if (paymentProvider == PaymentProvider.paystack) {
      return 0.20; // ₦20 or equivalent
    }
    return 0;
  }

  double get shopKeepsPercentage => 100 - platformFeePercentage;

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      shopId: json['shop_id'] as String,
      paymentProvider: _parsePaymentProvider(
        json['payment_provider'] as String?,
      ),

      // Stripe fields (handle null safely)
      stripeAccountId: json['stripe_account_id'] as String?,
      stripeVerified: json['stripe_verified'] as bool?,
      stripeCurrency: json['stripe_currency'] as String?,
      autoPayoutEnabled: json['auto_payout_enabled'] as bool? ?? true,

      // Paystack fields (handle null safely)
      paystackSubaccountCode: json['paystack_subaccount_code'] as String?,
      paystackRecipientId: json['paystack_recipient_id'] as String?,
      paystackVerified: json['paystack_verified'] as bool?,
      paystackCurrency: json['paystack_currency'] as String?,

      // Payout fields with defaults
      payoutSchedule: _parsePayoutSchedule(
        json['payout_schedule'] as String? ?? 'weekly',
      ),
      payoutMinimum: (json['payout_minimum'] as num?)?.toDouble() ?? 50.0,
      payoutCurrency: json['payout_currency'] as String? ?? 'USD',

      // Date fields (handle null safely)
      connectedAt:
          json['connected_at'] != null
              ? DateTime.parse(json['connected_at'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'payment_provider':
          paymentProvider == PaymentProvider.none
              ? 'none'
              : paymentProvider.name,
      'stripe_account_id': stripeAccountId,
      'stripe_verified': stripeVerified,
      'stripe_currency': stripeCurrency,
      'paystack_subaccount_code': paystackSubaccountCode,
      'paystack_recipient_id': paystackRecipientId,
      'paystack_verified': paystackVerified,
      'paystack_currency': paystackCurrency,
      'payout_schedule': payoutSchedule.name,
      'payout_minimum': payoutMinimum,
      'payout_currency': payoutCurrency,
      'auto_payout_enabled': autoPayoutEnabled,
      'connected_at': connectedAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static PaymentProvider _parsePaymentProvider(String? value) {
    switch (value) {
      case 'stripe':
        return PaymentProvider.stripe;
      case 'paystack':
        return PaymentProvider.paystack;
      default:
        return PaymentProvider.none;
    }
  }

  static PayoutSchedule _parsePayoutSchedule(String value) {
    switch (value) {
      case 'daily':
        return PayoutSchedule.daily;
      case 'weekly':
        return PayoutSchedule.weekly;
      case 'biweekly':
        return PayoutSchedule.biweekly;
      case 'monthly':
        return PayoutSchedule.monthly;
      default:
        return PayoutSchedule.weekly;
    }
  }

  PaymentSettings copyWith({
    PaymentProvider? paymentProvider,
    String? stripeAccountId,
    bool? stripeVerified,
    String? stripeCurrency,
    String? paystackSubaccountCode,
    String? paystackRecipientId,
    bool? paystackVerified,
    String? paystackCurrency,
    bool? autoPayoutEnabled,
    PayoutSchedule? payoutSchedule,
    double? payoutMinimum,
    String? payoutCurrency,
    DateTime? connectedAt,
  }) {
    return PaymentSettings(
      shopId: shopId,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      autoPayoutEnabled: autoPayoutEnabled ?? this.autoPayoutEnabled,

      stripeVerified: stripeVerified ?? this.stripeVerified,
      stripeCurrency: stripeCurrency ?? this.stripeCurrency,
      paystackSubaccountCode:
          paystackSubaccountCode ?? this.paystackSubaccountCode,
      paystackRecipientId: paystackRecipientId ?? this.paystackRecipientId,
      paystackVerified: paystackVerified ?? this.paystackVerified,
      paystackCurrency: paystackCurrency ?? this.paystackCurrency,
      payoutSchedule: payoutSchedule ?? this.payoutSchedule,
      payoutMinimum: payoutMinimum ?? this.payoutMinimum,
      payoutCurrency: payoutCurrency ?? this.payoutCurrency,
      connectedAt: connectedAt ?? this.connectedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    shopId,
    paymentProvider,
    stripeAccountId,
    stripeVerified,
    stripeCurrency,
    paystackSubaccountCode,
    paystackRecipientId,
    paystackVerified,
    paystackCurrency,
    payoutSchedule,
    payoutMinimum,
    payoutCurrency,
    connectedAt,
    createdAt,
    updatedAt,
  ];
}
