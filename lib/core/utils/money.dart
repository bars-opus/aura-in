// lib/core/utils/money.dart
//
// Phase 17 — single source of truth for money formatting + conversion.
//
// The booking, payment, promo, wallet, and analytics surfaces all use
// int *Minor (kobo for GHS, cents for USD) for in-memory math. The
// conversion to/from NUMERIC(12,2) major-unit storage happens at exactly
// two boundaries:
//   - parseMoneyMinor(num) — at every PostgREST ↔ DTO unmarshalling site
//   - formatMoney(int, currency) — at every UI display site
//
// Any .toDouble() on a money column, any inline `* 100`, any
// toStringAsFixed(2) outside this file is a regression (see SC-1, SC-2,
// SC-3 in 17-SPEC.md).

/// Format an int minor-unit value as a display string. Thousands-grouped,
/// fixed 2 decimal places. Negative values get a leading minus.
///
///   formatMoney(0, 'GHS')      == 'GHS 0.00'
///   formatMoney(5000, 'GHS')   == 'GHS 50.00'
///   formatMoney(125000, 'GHS') == 'GHS 1,250.00'
///   formatMoney(-5000, 'GHS')  == '-GHS 50.00'
String formatMoney(int minor, String currency) {
  final neg = minor < 0;
  final abs = neg ? -minor : minor;
  final major = abs ~/ 100;
  final minorPart = (abs % 100).toString().padLeft(2, '0');
  final grouped = _groupThousands(major);
  return '${neg ? '-' : ''}$currency $grouped.$minorPart';
}

/// Format a major-unit value (for example wallet/analytics doubles already in
/// major currency units) with grouping and a fixed number of decimals.
String formatMajorMoney(num major, String currency, {int fractionDigits = 2}) {
  final neg = major < 0;
  final abs = major.abs();
  final fixed = abs.toStringAsFixed(fractionDigits);
  final parts = fixed.split('.');
  final whole = int.parse(parts.first);
  final grouped = _groupThousands(whole);
  final fraction = fractionDigits > 0 && parts.length > 1 ? '.${parts[1]}' : '';

  return '${neg ? '-' : ''}$currency $grouped$fraction';
}

/// Compact major-unit formatting for chart axes and dense KPI labels.
String formatCompactMajorMoney(num major, String currency) {
  final neg = major < 0;
  final abs = major.abs();
  final prefix = neg ? '-$currency ' : '$currency ';

  if (abs >= 1000000) {
    return '$prefix${(abs / 1000000).toStringAsFixed(0)}m';
  }
  if (abs >= 1000) {
    return '$prefix${(abs / 1000).toStringAsFixed(0)}k';
  }
  return '$prefix${abs.toStringAsFixed(0)}';
}

String formatCompactNumber(num value) {
  final neg = value < 0;
  final abs = value.abs();
  final prefix = neg ? '-' : '';

  if (abs >= 1000000) {
    return '$prefix${(abs / 1000000).toStringAsFixed(0)}m';
  }
  if (abs >= 1000) {
    return '$prefix${(abs / 1000).toStringAsFixed(0)}k';
  }
  return '$prefix${abs.toStringAsFixed(0)}';
}

String _groupThousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Convert a NUMERIC(12,2) major-unit JSON value to int minor units.
/// Rounds half-away-from-zero, matching Postgres NUMERIC's default
/// rounding behaviour.
///
///   parseMoneyMinor(50.00)  == 5000
///   parseMoneyMinor(50.005) == 5001  (rounds away from zero)
///   parseMoneyMinor(0)      == 0
int parseMoneyMinor(num major) => (major * 100).round();

/// Multiply an int minor value by a basis-point fraction (1 bp = 0.01%).
/// Result rounds toward zero (truncates fractional kobo) — matches the
/// server-side `(value * bps) ~/ 10000` pattern Phase 16 uses for
/// pricing override math.
///
///   applyBps(5000, 3000) == 1500   // 5000 * 30%
///   applyBps(5000, 2500) == 1250   // 5000 * 25%
///   applyBps(5000, 0)    == 0
int applyBps(int minor, int bps) => (minor * bps) ~/ 10000;
