import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/config/env.dart';

/// The app no longer uses `flutter_dotenv`. Configuration is compile-time via
/// `String.fromEnvironment` (`--dart-define` / `--dart-define-from-file`),
/// surfaced through the [Environment] class. These tests assert the real
/// contract: the defaults that ship when no dart-define is supplied (the state
/// under `flutter test`), the null-coalescing of optional keys, and the
/// platform-switching getter.
void main() {
  group('Environment defaults (no --dart-define supplied)', () {
    test('linkBaseDomain falls back to its default', () {
      expect(Environment.linkBaseDomain, 'aura-in.app');
    });

    test('linkScheme falls back to its default', () {
      expect(Environment.linkScheme, 'aurain');
    });

    test('appId falls back to its default', () {
      expect(Environment.appId, 'aurain');
    });

    test('isDebug defaults to false', () {
      expect(Environment.isDebug, isFalse);
    });
  });

  group('Environment required keys (empty when undefined)', () {
    // Required secrets have NO hardcoded fallback by design — they resolve to
    // the empty string when not provided, so the app can fail fast at startup
    // rather than ship a secret in the binary.
    test('supabaseUrl is empty without a dart-define', () {
      expect(Environment.supabaseUrl, isEmpty);
    });

    test('supabaseAnonKey is empty without a dart-define', () {
      expect(Environment.supabaseAnonKey, isEmpty);
    });

    test('sendbirdAppId is empty without a dart-define', () {
      expect(Environment.sendbirdAppId, isEmpty);
    });
  });

  group('Environment optional keys', () {
    test('oneSignalAppId is null when unset (not empty string)', () {
      // The const ternary maps '' -> null so callers can use ?? cleanly.
      expect(Environment.oneSignalAppId, isNull);
    });
  });

  group('Environment platform-aware getters', () {
    test('googleMapsApiKey returns a String for the current platform', () {
      // Without a dart-define this is the empty string, but the getter must not
      // throw and must always return a non-null value for the active platform.
      expect(Environment.googleMapsApiKey, isA<String>());
    });
  });
}
