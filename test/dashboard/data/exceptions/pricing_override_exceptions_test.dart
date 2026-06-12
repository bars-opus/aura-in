// test/dashboard/data/exceptions/pricing_override_exceptions_test.dart
//
// Phase 15 Wave 6.1 — locks the PricingOverrideException shape contract:
// stable `code` and sanitized `userMessage` per subtype. These are the
// strings the screen layer switches on for localization.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions.dart';

void main() {
  group('PricingOverrideException (base)', () {
    test('default code is OVERRIDE_GENERIC', () {
      final e = PricingOverrideException('boom');
      expect(e.code, 'OVERRIDE_GENERIC');
    });

    test('default userMessage is safe to render', () {
      final e = PricingOverrideException('boom');
      expect(e.userMessage, 'Something went wrong. Please try again.');
      expect(e.userMessage, isNot(contains('boom')));
    });

    test('toString embeds the code + internal message', () {
      final e = PricingOverrideException('boom');
      expect(
        e.toString(),
        'PricingOverrideException(OVERRIDE_GENERIC): boom',
      );
    });
  });

  group('Subtype contracts', () {
    test('OverrideAccessDeniedException → OVERRIDE_NOT_FOUND', () {
      final e = OverrideAccessDeniedException();
      expect(e.code, 'OVERRIDE_NOT_FOUND');
      expect(e.userMessage, "We couldn't find that pricing rule.");
    });

    test('OverrideWindowInvalidException → OVERRIDE_WINDOW_INVALID', () {
      final e = OverrideWindowInvalidException();
      expect(e.code, 'OVERRIDE_WINDOW_INVALID');
      expect(e.userMessage, 'The end time must be after the start time.');
    });

    test('OverrideDayOfWeekInvalidException → OVERRIDE_DAY_INVALID', () {
      final e = OverrideDayOfWeekInvalidException();
      expect(e.code, 'OVERRIDE_DAY_INVALID');
      expect(e.userMessage, 'Please pick a valid day of the week.');
    });

    test('OverrideAdjustmentInvalidException → OVERRIDE_ADJUSTMENT_INVALID',
        () {
      final e = OverrideAdjustmentInvalidException();
      expect(e.code, 'OVERRIDE_ADJUSTMENT_INVALID');
      expect(e.userMessage, 'Please re-check the discount amount.');
    });

    test('OverrideValidityInvalidException → OVERRIDE_VALIDITY_INVALID', () {
      final e = OverrideValidityInvalidException();
      expect(e.code, 'OVERRIDE_VALIDITY_INVALID');
      expect(e.userMessage, 'The end date must be after the start date.');
    });

    test('OverrideCapExceededException → OVERRIDE_CAP_EXCEEDED', () {
      final e = OverrideCapExceededException();
      expect(e.code, 'OVERRIDE_CAP_EXCEEDED');
      expect(
        e.userMessage,
        "You've reached the 50-rule limit on this service. "
        'Archive an old rule to free a slot.',
      );
    });

    test('OverrideSaveFailedException → OVERRIDE_SAVE_FAILED', () {
      final e = OverrideSaveFailedException();
      expect(e.code, 'OVERRIDE_SAVE_FAILED');
      expect(e.userMessage, "We couldn't save the rule. Please try again.");
    });
  });
}
