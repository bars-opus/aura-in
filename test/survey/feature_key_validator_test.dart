import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/config/survey/exceptions/survey_exceptions.dart';
import 'package:nano_embryo/core/config/survey/utils/feature_key_validator.dart';

void main() {
  group('FeatureKeyValidator', () {
    test('accepts canonical lowercase snake_case keys', () {
      FeatureKeyValidator.validate('booking');
      FeatureKeyValidator.validate('shop_admin');
      FeatureKeyValidator.validate('a');
      FeatureKeyValidator.validate('a' * 64);
    });

    test('rejects empty string', () {
      expect(
        () => FeatureKeyValidator.validate(''),
        throwsA(isA<SurveyValidationException>()),
      );
    });

    test('rejects keys longer than 64 chars', () {
      expect(
        () => FeatureKeyValidator.validate('a' * 65),
        throwsA(isA<SurveyValidationException>()),
      );
    });

    test('rejects uppercase, dashes, spaces, unicode', () {
      for (final bad in const [
        'Booking',
        'shop-admin',
        'shop admin',
        'café',
        'feature!',
        'feature.key',
      ]) {
        expect(
          () => FeatureKeyValidator.validate(bad),
          throwsA(isA<SurveyValidationException>()),
          reason: 'should reject "$bad"',
        );
      }
    });
  });
}
