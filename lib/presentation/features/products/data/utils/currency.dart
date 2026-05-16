import 'package:intl/intl.dart';

/// Single source of truth for marketplace currency formatting.
///
/// Today the marketplace is NGN-only. Centralising this means swapping
/// to a per-shop currency (or a user locale) is one file to change
/// rather than ~17 hardcoded `'₦${...}'` callsites.
class Currency {
  Currency._();

  static const String symbol = '₦';
  static const String code = 'NGN';

  static final NumberFormat _formatter =
      NumberFormat.currency(symbol: symbol, decimalDigits: 2, name: code);

  /// Formats an amount as `₦1,234.56`.
  static String format(num amount) => _formatter.format(amount);

  /// Short formatter without thousands separators — used inside compact
  /// chips/badges where a grouping comma would wrap.
  static String formatCompact(num amount) =>
      '$symbol${amount.toStringAsFixed(2)}';
}
