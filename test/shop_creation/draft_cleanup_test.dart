import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';

void main() {
  late Directory tempDir;
  late Box box;
  late LocalDraftStorage storage;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox<dynamic>(
      'test_drafts_${DateTime.now().microsecondsSinceEpoch}',
    );
    storage = LocalDraftStorage.fromBox(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('LocalDraftStorage', () {
    test('saveDraft then loadDraft returns the same draft', () async {
      final draft = ShopDraft(profileId: 'p1', shopName: 'Glam');
      await storage.saveDraft('p1', draft);
      final loaded = storage.loadDraft('p1');
      expect(loaded, isNotNull);
      expect(loaded!.shopName, 'Glam');
    });

    test('loadDraft returns null when no draft saved', () {
      expect(storage.loadDraft('unknown'), isNull);
    });

    test('hasDraft returns true after save, false after clear', () async {
      await storage.saveDraft('p1', ShopDraft(profileId: 'p1'));
      expect(storage.hasDraft('p1'), isTrue);
      await storage.clearDraft('p1');
      expect(storage.hasDraft('p1'), isFalse);
    });

    test('malformed Hive entry does not throw — returns null', () async {
      await box.put('p2', 'not-a-map');
      expect(() => storage.loadDraft('p2'), returnsNormally);
      expect(storage.loadDraft('p2'), isNull);
    });
  });
}
