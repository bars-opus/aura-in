import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/feedback/exceptions/feedback_exceptions.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_type_validator.dart';

void main() {
  group('FeedbackTypeValidator', () {
    const allowed = ['bug', 'suggestion', 'shop_issue'];

    test('accepts a key that is in the allow-list', () {
      FeedbackTypeValidator.validate('bug', allowed);
      FeedbackTypeValidator.validate('shop_issue', allowed);
    });

    test('rejects empty string', () {
      expect(
        () => FeedbackTypeValidator.validate('', allowed),
        throwsA(isA<FeedbackValidationException>()),
      );
    });

    test('rejects > 64 chars', () {
      expect(
        () => FeedbackTypeValidator.validate('a' * 65, allowed),
        throwsA(isA<FeedbackValidationException>()),
      );
    });

    test('rejects uppercase, dashes, spaces', () {
      for (final bad in const ['Bug', 'shop-issue', 'shop issue', 'café']) {
        expect(
          () => FeedbackTypeValidator.validate(bad, allowed),
          throwsA(isA<FeedbackValidationException>()),
          reason: 'should reject "$bad"',
        );
      }
    });

    test('rejects keys that pass charset but are not in the config list', () {
      expect(
        () => FeedbackTypeValidator.validate('rogue_key', allowed),
        throwsA(isA<FeedbackValidationException>()),
      );
    });
  });
}
