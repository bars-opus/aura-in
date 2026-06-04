// test/dashboard/data/exceptions/service_management_exceptions_test.dart
//
// Locks the shape contract of the ServiceManagementException hierarchy.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart';

void main() {
  group('ServiceManagementException (base)', () {
    test('default code is SERVICE_GENERIC', () {
      final e = ServiceManagementException('boom');
      expect(e.code, 'SERVICE_GENERIC');
    });

    test('default userMessage is safe to render', () {
      final e = ServiceManagementException('boom');
      expect(e.userMessage, 'Something went wrong. Please try again.');
      expect(e.userMessage, isNot(contains('boom')));
    });

    test('toString embeds code + internal message', () {
      final e = ServiceManagementException('boom');
      expect(
          e.toString(), 'ServiceManagementException(SERVICE_GENERIC): boom');
    });
  });

  group('Subtype contracts', () {
    test('ServiceNotFoundException keeps slotId out of userMessage', () {
      final e = ServiceNotFoundException(
          '00000000-0000-0000-0000-000000000002');
      expect(e.code, 'SERVICE_NOT_FOUND');
      expect(e.userMessage, "We couldn't find that service.");
      expect(e.userMessage, isNot(contains('00000000')));
    });

    test('ServiceArchiveFailedException', () {
      final e = ServiceArchiveFailedException();
      expect(e.code, 'SERVICE_ARCHIVE_FAILED');
      expect(e.userMessage,
          "We couldn't archive that service. Please try again.");
    });

    test('ServiceSaveFailedException', () {
      final e = ServiceSaveFailedException();
      expect(e.code, 'SERVICE_SAVE_FAILED');
      expect(e.userMessage,
          "We couldn't save the service. Please try again.");
    });

    test('InvalidServicePayloadException', () {
      final e = InvalidServicePayloadException();
      expect(e.code, 'SERVICE_INVALID_PAYLOAD');
      expect(e.userMessage, 'Please re-check the service details.');
    });
  });
}
