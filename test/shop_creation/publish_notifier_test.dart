import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/publish_provider.dart';

void main() {
  group('PublishState', () {
    test('isSuccess requires shopId, no error, and not publishing', () {
      const s = PublishState(shopId: 'shop-1', isPublishing: false, error: null);
      expect(s.isSuccess, isTrue);
    });

    test('isSuccess is false while publishing', () {
      const s = PublishState(shopId: 'shop-1', isPublishing: true, error: null);
      expect(s.isSuccess, isFalse);
    });

    test('isSuccess is false when error is set', () {
      const s = PublishState(shopId: 'shop-1', isPublishing: false, error: 'oops');
      expect(s.isSuccess, isFalse);
    });

    test('hasError is true when error is non-null', () {
      const s = PublishState(error: 'network timeout');
      expect(s.hasError, isTrue);
    });

    test('hasError is false when error is null', () {
      const s = PublishState();
      expect(s.hasError, isFalse);
    });

    test('copyWith clears error when no new error provided', () {
      const s = PublishState(error: 'prev error', isPublishing: true);
      final updated = s.copyWith(isPublishing: false);
      // copyWith always resets error to null (pass-through erasure)
      expect(updated.error, isNull);
    });

    test('default state has sensible values', () {
      const s = PublishState();
      expect(s.isPublishing, isFalse);
      expect(s.hasError, isFalse);
      expect(s.isSuccess, isFalse);
      expect(s.progress, 0.0);
      expect(s.currentStep, isEmpty);
    });
  });
}
