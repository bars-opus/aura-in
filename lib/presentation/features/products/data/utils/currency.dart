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

  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 2,
    name: code,
  );

  /// Formats an amount as `₦1,234.56`.
  static String format(num amount) => _formatter.format(amount);

  /// Formats with an explicit per-shop currency [currencySymbol]. Falls back to
  /// the default [symbol] when null/empty. Groups thousands like [format].
  static String formatWithSymbol(num amount, String? currencySymbol) {
    final sym =
        (currencySymbol != null && currencySymbol.isNotEmpty)
            ? currencySymbol
            : symbol;
    return NumberFormat.currency(symbol: sym, decimalDigits: 2).format(amount);
  }

  /// Formats using shop/order/product currency context.
  ///
  /// Preference order:
  /// 1. explicit [currencySymbol]
  /// 2. [currencyCode] as the formatter name/symbol
  /// 3. marketplace defaults
  static String formatWithCurrency(
    num amount, {
    String? currencySymbol,
    String? currencyCode,
  }) {
    final hasSymbol = currencySymbol != null && currencySymbol.isNotEmpty;
    final hasCode = currencyCode != null && currencyCode.isNotEmpty;

    if (hasSymbol) {
      return NumberFormat.currency(
        symbol: currencySymbol,
        name: hasCode ? currencyCode : null,
        decimalDigits: 2,
      ).format(amount);
    }

    if (hasCode) {
      return NumberFormat.currency(
        symbol: currencyCode,
        name: currencyCode,
        decimalDigits: 2,
      ).format(amount);
    }

    return format(amount);
  }

  /// Short formatter without thousands separators — used inside compact
  /// chips/badges where a grouping comma would wrap.
  static String formatCompact(num amount) =>
      '$symbol${amount.toStringAsFixed(2)}';
}
