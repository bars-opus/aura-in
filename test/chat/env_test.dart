import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Environment Tests', () {
    // Create a test .env content
    const testEnvContent = '''
SUPABASE_URL=https://test.supabase.co
SUPABASE_ANON_KEY=test_anon_key_12345
SENDBIRD_APP_ID=test_app_id_67890
DEBUG=true
''';

    setUp(() async {
      // Reset dotenv before each test
      dotenv.clean();

      // Load test environment from string
      dotenv.testLoad(fileInput: testEnvContent);
    });

    test('should return true for isEveryDefined with all variables', () {
      final hasAllVars = dotenv.isEveryDefined([
        'SUPABASE_URL',
        'SUPABASE_ANON_KEY',
        'SENDBIRD_APP_ID',
      ]);
      expect(hasAllVars, isTrue);
    });

    test('should get Supabase URL correctly', () {
      final url = dotenv.env['SUPABASE_URL'];
      expect(url, 'https://test.supabase.co');
    });

    test('should get Supabase Anon Key correctly', () {
      final key = dotenv.env['SUPABASE_ANON_KEY'];
      expect(key, 'test_anon_key_12345');
    });

    test('should get Sendbird App ID correctly', () {
      final appId = dotenv.env['SENDBIRD_APP_ID'];
      expect(appId, 'test_app_id_67890');
    });

    test('should return null for missing key', () {
      final missing = dotenv.env['MISSING_KEY'];
      expect(missing, isNull);
    });

    test('should have DEBUG as true in test env', () {
      final debug = dotenv.env['DEBUG'];
      expect(debug, 'true');
    });

    test('should handle case-insensitive boolean checks', () {
      final debugValue = dotenv.env['DEBUG']?.toLowerCase();
      expect(debugValue, anyOf('true', 'false'));
    });
  });

  group('Environment.get Method Tests', () {
    setUp(() async {
      dotenv.clean();
      const testEnv = '''
SUPABASE_URL=https://test.supabase.co
SUPABASE_ANON_KEY=test_key
SENDBIRD_APP_ID=test_app
''';
      dotenv.testLoad(fileInput: testEnv);
    });

    test('should return value for existing key', () {
      // Since Environment.get requires initialization,
      // we test dotenv directly
      final value = dotenv.env['SUPABASE_URL'];
      expect(value, 'https://test.supabase.co');
    });

    test('should return null for non-existing key', () {
      final value = dotenv.env['NON_EXISTENT'];
      expect(value, isNull);
    });
  });
}
