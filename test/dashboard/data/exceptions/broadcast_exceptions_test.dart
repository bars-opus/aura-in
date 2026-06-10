// test/dashboard/data/exceptions/broadcast_exceptions_test.dart
//
// Phase 14 — locks the shape contract of the BroadcastException
// hierarchy. The UI switches on `code` and renders `userMessage`
// directly; any change here is intentional and should be reviewed
// against UI copy + the matching app_en.arb entry at the same time.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions.dart';

void main() {
  group('BroadcastException (base)', () {
    test('default code is BROADCAST_GENERIC', () {
      final e = BroadcastException('boom');
      expect(e.code, 'BROADCAST_GENERIC');
    });

    test('default userMessage is safe to render', () {
      final e = BroadcastException('boom');
      expect(e.userMessage, 'Something went wrong. Please try again.');
      expect(e.userMessage, isNot(contains('boom')));
    });

    test('toString embeds code + internal message', () {
      final e = BroadcastException('boom');
      expect(e.toString(), 'BroadcastException(BROADCAST_GENERIC): boom');
    });
  });

  group('Subtype contracts', () {
    test('BroadcastRateLimitException', () {
      final e = BroadcastRateLimitException();
      expect(e.code, 'BROADCAST_RATE_LIMIT');
      expect(e.userMessage,
          "You've already sent a broadcast today. Try again tomorrow.");
    });

    test('BroadcastInFlightException', () {
      final e = BroadcastInFlightException();
      expect(e.code, 'BROADCAST_IN_FLIGHT');
      expect(e.userMessage,
          'Another broadcast is being processed. Please wait a moment.');
    });

    test('BroadcastInvalidAudienceException', () {
      final e = BroadcastInvalidAudienceException();
      expect(e.code, 'BROADCAST_INVALID_AUDIENCE');
      expect(e.userMessage,
          "Please pick a valid audience and (if 'By service') a service.");
    });

    test('BroadcastPromoInvalidException', () {
      final e = BroadcastPromoInvalidException();
      expect(e.code, 'BROADCAST_PROMO_INVALID');
      expect(e.userMessage,
          'This code is no longer valid. Pick another or remove the code.');
    });

    test('BroadcastCapExceededException', () {
      final e = BroadcastCapExceededException();
      expect(e.code, 'BROADCAST_CAP_EXCEEDED');
      expect(
          e.userMessage,
          'This audience is larger than the 1000-recipient cap. '
          'Try a narrower audience.');
    });

    test('BroadcastSaveFailedException', () {
      final e = BroadcastSaveFailedException();
      expect(e.code, 'BROADCAST_SAVE_FAILED');
      expect(e.userMessage, 'Could not send broadcast. Please try again.');
    });
  });
}
