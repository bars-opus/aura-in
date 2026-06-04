// test/dashboard/data/exceptions/promotion_exceptions_test.dart
//
// Unit tests for the PromotionException hierarchy. Locks the shape
// contract so the UI's switch-on-code branches stay stable.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';

void main() {
  group('PromotionException (base)', () {
    test('default code is PROMO_GENERIC', () {
      final e = PromotionException('boom');
      expect(e.code, 'PROMO_GENERIC');
    });

    test('default userMessage is safe to render', () {
      final e = PromotionException('boom');
      expect(e.userMessage, 'Something went wrong. Please try again.');
      expect(e.userMessage, isNot(contains('boom')));
    });

    test('toString embeds the code + internal message', () {
      final e = PromotionException('boom');
      expect(e.toString(), 'PromotionException(PROMO_GENERIC): boom');
    });

    test('custom code + userMessage are honoured', () {
      final e = PromotionException('internal',
          code: 'PROMO_CUSTOM', userMessage: 'Please try again.');
      expect(e.code, 'PROMO_CUSTOM');
      expect(e.userMessage, 'Please try again.');
    });
  });

  group('Subtype contracts', () {
    test('DuplicateCodeException has stable code + no PII leak', () {
      final e = DuplicateCodeException();
      expect(e.code, 'PROMO_DUPLICATE_CODE');
      expect(e.userMessage, 'A promotion with that code already exists.');
      expect(e.userMessage, isNot(contains('PROMO_')));
    });

    test('PromotionNotFoundException keeps id out of userMessage', () {
      final e = PromotionNotFoundException(
          '00000000-0000-0000-0000-000000000001');
      expect(e.code, 'PROMO_NOT_FOUND');
      expect(e.userMessage, "We couldn't find that promotion.");
      expect(e.userMessage, isNot(contains('00000000')));
    });

    test('PromotionLimitReachedException', () {
      final e = PromotionLimitReachedException();
      expect(e.code, 'PROMO_LIMIT_REACHED');
      expect(e.userMessage, 'This promotion has reached its usage limit.');
    });

    test('InvalidDiscountAmountException', () {
      final e = InvalidDiscountAmountException();
      expect(e.code, 'PROMO_INVALID_AMOUNT');
      expect(e.userMessage, 'Please enter a valid discount amount.');
    });
  });
}
