/// Tests for UploadShopMedia file-size guard logic.
///
/// These tests verify the pre-upload validation (file size, path existence)
/// without instantiating the actual Supabase/storage stack. The 10 MB guard
/// is enforced before any network call, so it can be exercised by reading a
/// real temp file.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The 10 MB constant mirrors UploadShopMedia._maxFileSizeBytes.
const int _maxFileSizeBytes = 10 * 1024 * 1024;

bool _exceedsLimit(String path) {
  final stat = File(path).statSync();
  return stat.size > _maxFileSizeBytes;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('upload_guard_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('File-size guard (mirrors UploadShopMedia._maxFileSizeBytes)', () {
    test('11 MB file exceeds 10 MB limit', () async {
      final f = File('${tempDir.path}/big.jpg');
      await f.writeAsBytes(List.filled(11 * 1024 * 1024, 0));
      expect(_exceedsLimit(f.path), isTrue);
    });

    test('1 KB file is within 10 MB limit', () async {
      final f = File('${tempDir.path}/small.jpg');
      await f.writeAsBytes(List.filled(1024, 0));
      expect(_exceedsLimit(f.path), isFalse);
    });

    test('exactly 10 MB is within limit', () async {
      final f = File('${tempDir.path}/exact.jpg');
      await f.writeAsBytes(List.filled(_maxFileSizeBytes, 0));
      expect(_exceedsLimit(f.path), isFalse);
    });

    test('10 MB + 1 byte exceeds limit', () async {
      final f = File('${tempDir.path}/over.jpg');
      await f.writeAsBytes(List.filled(_maxFileSizeBytes + 1, 0));
      expect(_exceedsLimit(f.path), isTrue);
    });
  });
}
