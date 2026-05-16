/// Client-side input sanitization helpers for marketplace forms.
///
/// The database enforces length CHECK constraints (see migration
/// `20260516000000_marketplace_hardening.sql`), but rejecting at the
/// form is a better UX than letting the user hit submit and see a
/// generic error from the RPC.
class InputSanitizer {
  InputSanitizer._();

  // Maximums must match the DB CHECK constraints exactly.
  static const int maxName = 100;
  static const int maxDescription = 2000;
  static const int maxDeliveryAddress = 500;
  static const int maxCustomerPhone = 30;
  static const int maxOrderNotes = 1000;
  static const int maxShopNotes = 1000;
  static const int maxReviewComment = 2000;
  static const int maxDisputeReason = 2000;

  /// Ranges of invisible / control / bidi code points that should be
  /// stripped from user input. Defined as integer pairs so this source
  /// file contains zero raw control characters (otherwise the source
  /// itself would be a bidi-spoofing vector — the very thing we are
  /// defending against).
  ///
  /// Preserves TAB (0x09), LF (0x0A), CR (0x0D) since those are
  /// legitimate in description / delivery_address.
  static const List<List<int>> _strippedRanges = [
    [0x00, 0x08],       // NUL .. BS
    [0x0B, 0x0C],       // VT, FF
    [0x0E, 0x1F],       // SO .. US
    [0x7F, 0x7F],       // DEL
    [0x80, 0x9F],       // C1 controls
    [0x200B, 0x200F],   // zero-width + LRM + RLM
    [0x202A, 0x202E],   // bidi override (spoofing vector)
    [0x2060, 0x206F],   // word joiner + invisible operators
    [0xFEFF, 0xFEFF],   // BOM / zero-width no-break space
  ];

  /// Strips invisible / control / bidi-spoofing code points and trims.
  static String clean(String input) {
    final buf = StringBuffer();
    for (final codeUnit in input.runes) {
      var stripped = false;
      for (final range in _strippedRanges) {
        if (codeUnit >= range[0] && codeUnit <= range[1]) {
          stripped = true;
          break;
        }
      }
      if (!stripped) buf.writeCharCode(codeUnit);
    }
    return buf.toString().trim();
  }

  /// Loose Nigerian / international phone validation. Accepts:
  ///   - 11 digits starting with 0 (local Nigerian format)
  ///   - 13 digits starting with 234 (international Nigerian)
  ///   - 10-15 digits with optional leading + (generic international)
  /// Returns an error message or null if valid.
  static String? validatePhone(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Phone number is required';
    final cleaned = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final digitsOnly = cleaned.startsWith('+') ? cleaned.substring(1) : cleaned;
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return 'Phone may only contain digits, spaces, +, -, ()';
    }
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Phone must be 10-15 digits';
    }
    return null;
  }

  /// Generic length validator factory for free-text fields.
  static String? Function(String?) requiredLength(int max, {String? fieldName}) {
    return (String? raw) {
      if (raw == null || raw.trim().isEmpty) {
        return '${fieldName ?? 'This field'} is required';
      }
      if (raw.length > max) {
        return '${fieldName ?? 'This field'} cannot exceed $max characters';
      }
      return null;
    };
  }

  static String? Function(String?) optionalLength(int max,
      {String? fieldName}) {
    return (String? raw) {
      if (raw == null || raw.isEmpty) return null;
      if (raw.length > max) {
        return '${fieldName ?? 'This field'} cannot exceed $max characters';
      }
      return null;
    };
  }
}
