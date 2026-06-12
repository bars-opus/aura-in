// test/dashboard/data/exceptions/daily_report_exceptions_test.dart
//
// Phase 16 Wave 6.1 — locks the DailyReportException shape contract:
// stable `code` and sanitized `userMessage` per subtype. These are the
// strings the screen layer switches on for localization.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions.dart';

void main() {
  group('DailyReportException (base)', () {
    test('default code is REPORT_GENERIC', () {
      final e = DailyReportException('boom');
      expect(e.code, 'REPORT_GENERIC');
    });

    test('default userMessage is safe to render', () {
      final e = DailyReportException('boom');
      expect(e.userMessage, 'Something went wrong. Please try again.');
      expect(e.userMessage, isNot(contains('boom')));
    });

    test('toString embeds the code + internal message', () {
      final e = DailyReportException('boom');
      expect(e.toString(), 'DailyReportException(REPORT_GENERIC): boom');
    });
  });

  group('Subtype contracts', () {
    test('ReportAccessDeniedException → REPORT_NOT_FOUND', () {
      final e = ReportAccessDeniedException();
      expect(e.code, 'REPORT_NOT_FOUND');
      expect(e.userMessage, "We couldn't find that report.");
    });

    test('ReportDateInvalidException → REPORT_DATE_INVALID', () {
      final e = ReportDateInvalidException();
      expect(e.code, 'REPORT_DATE_INVALID');
      expect(e.userMessage, 'That date is out of range.');
    });

    test('ReportNotFoundException → REPORT_NOT_FOUND', () {
      final e = ReportNotFoundException();
      expect(e.code, 'REPORT_NOT_FOUND');
      expect(e.userMessage, 'No report yet for that date.');
    });

    test('ReportGenerationFailedException → REPORT_RPC_FAILED', () {
      final e = ReportGenerationFailedException();
      expect(e.code, 'REPORT_RPC_FAILED');
      expect(e.userMessage, "We couldn't build the report. Please try again.");
    });
  });
}
