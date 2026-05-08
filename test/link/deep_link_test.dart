// test/link/deep_link_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Deep Link Parsing', () {
    test('parse custom scheme URL correctly', () {
      const testUrl = 'aurain://shop/luxe-salon';
      final uri = Uri.parse(testUrl);

      // The "shop" is actually the host, not part of the path
      expect(uri.scheme, 'aurain');
      expect(uri.host, 'shop'); // "shop" is the host
      expect(uri.path, '/luxe-salon');
      expect(uri.pathSegments[0], 'luxe-salon');
    });

    test('parse web URL correctly', () {
      const testUrl = 'https://aura-in.vercel.app/l/luxe-salon';
      final uri = Uri.parse(testUrl);

      expect(uri.pathSegments[0], 'l');
      expect(uri.pathSegments[1], 'luxe-salon');
    });

    test('extract slug from custom scheme', () {
      const testUrl = 'aurain://shop/luxe-salon';
      final uri = Uri.parse(testUrl);

      // The slug is the first (and only) path segment
      final slug = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;

      expect(slug, 'luxe-salon');
    });

    test('extract link type from custom scheme', () {
      const testUrl = 'aurain://shop/luxe-salon';
      final uri = Uri.parse(testUrl);

      // The link type is the host
      final linkType = uri.host;

      expect(linkType, 'shop');
    });

    test('extract slug from web URL', () {
      const testUrl = 'https://aura-in.vercel.app/l/luxe-salon';
      final uri = Uri.parse(testUrl);

      final segments = uri.pathSegments;
      final slug =
          segments.isNotEmpty && segments[0] == 'l' && segments.length >= 2
              ? segments[1]
              : null;

      expect(slug, 'luxe-salon');
    });

    test('extract slug from web URL with trailing slash', () {
      const testUrl = 'https://aura-in.vercel.app/l/luxe-salon/';
      final uri = Uri.parse(testUrl);
      final segments = uri.pathSegments;
      final slug =
          segments.isNotEmpty && segments[0] == 'l' && segments.length >= 2
              ? segments[1]
              : null;

      expect(slug, 'luxe-salon');
    });

    test('handle invalid custom scheme URL (no slug)', () {
      const testUrl = 'aurain://shop';
      final uri = Uri.parse(testUrl);
      final slug = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;

      expect(slug, isNull);
    });
  });
}
