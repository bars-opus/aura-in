import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_pii_scrubber.dart';

void main() {
  group('scrubDeviceInfoForPersistence', () {
    test('returns null for null input', () {
      expect(scrubDeviceInfoForPersistence(null), isNull);
    });

    test('strips iOS device_name (often contains user first name)', () {
      final scrubbed = scrubDeviceInfoForPersistence({
        'platform': 'iOS',
        'model': 'iPhone15,3',
        'system_version': '17.4',
        'device_name': "John's iPhone",
      });
      expect(scrubbed, {
        'platform': 'iOS',
        'model': 'iPhone15,3',
        'system_version': '17.4',
      });
    });

    test('strips the generic `name` key too', () {
      final scrubbed = scrubDeviceInfoForPersistence({
        'platform': 'Android',
        'manufacturer': 'samsung',
        'name': 'My Phone',
      });
      expect(scrubbed!.containsKey('name'), isFalse);
      expect(scrubbed['manufacturer'], 'samsung');
    });

    test('leaves non-PII fields untouched', () {
      final input = {
        'platform': 'Android',
        'model': 'SM-G998B',
        'sdk_int': 34,
      };
      expect(scrubDeviceInfoForPersistence(input), input);
    });
  });
}
