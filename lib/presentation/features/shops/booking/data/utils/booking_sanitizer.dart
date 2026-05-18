/// Client-side input sanitization for booking text fields.
///
/// The database enforces length CHECK constraints (see migration
/// `20260517020000_booking_hardening.sql`). These constants and helpers
/// mirror those caps so rejection happens at the form layer rather than
/// surfacing a server error mid-submit. Defense in depth — both must
/// stay in sync.
class BookingSanitizer {
  BookingSanitizer._();

  // Maximums MUST match the DB CHECK constraints exactly.
  static const int maxCancellationReason  = 500;
  static const int maxAddress             = 500;
  static const int maxSpecialRequirements = 1000;
  static const int maxServiceName         = 200;
  static const int maxWorkerName          = 200;

  /// Ranges of invisible / control / bidi code points to strip from user
  /// input. Defined as integer pairs so this source file contains zero
  /// raw control characters (the source itself would otherwise be a
  /// bidi-spoofing vector). Preserves TAB / LF / CR.
  static const List<List<int>> _strippedRanges = [
    [0x00, 0x08],
    [0x0B, 0x0C],
    [0x0E, 0x1F],
    [0x7F, 0x7F],
    [0x80, 0x9F],
    [0x200B, 0x200F],
    [0x202A, 0x202E],
    [0x2060, 0x206F],
    [0xFEFF, 0xFEFF],
  ];

  /// Strips invisible / control / bidi-spoofing code points and trims.
  /// Returns `null` if the cleaned string is empty so callers can pass
  /// `clean(maybeNull) ?? null` straight into a nullable column.
  static String? clean(String? input) {
    if (input == null) return null;
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
    final out = buf.toString().trim();
    return out.isEmpty ? null : out;
  }

  /// Clean and cap to [max] characters. Used right before handing a
  /// field to a Supabase RPC — the server will reject anything longer
  /// with a 22023, so we'd rather truncate gracefully than fail.
  static String? cleanAndCap(String? input, int max) {
    final cleaned = clean(input);
    if (cleaned == null) return null;
    if (cleaned.length <= max) return cleaned;
    return cleaned.substring(0, max);
  }

  /// True iff the coordinate pair is plausible: both non-null, in range,
  /// and not the "(0,0) null-island" footgun.
  static bool isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    if (lat == 0 && lng == 0) return false;
    return true;
  }
}
