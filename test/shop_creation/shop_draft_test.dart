import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';

ShopDraft _draft({
  String? shopName,
  String? address,
  double? latitude,
  double? longitude,
}) {
  return ShopDraft(
    profileId: 'profile-1',
    shopName: shopName,
    address: address,
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  group('ShopDraft.isLocationComplete', () {
    test('false when address only', () {
      final d = _draft(address: '5 Main St');
      expect(d.isLocationComplete, isFalse);
    });

    test('false when coords only', () {
      final d = _draft(latitude: 5.6, longitude: -0.18);
      expect(d.isLocationComplete, isFalse);
    });

    test('true when address + coords both set', () {
      final d = _draft(address: '5 Main St', latitude: 5.6, longitude: -0.18);
      expect(d.isLocationComplete, isTrue);
    });
  });

  group('ShopDraft.copyWith lastUpdated sentinel', () {
    test('copyWith without lastUpdated sets it to now', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final d = ShopDraft(profileId: 'p').copyWith(shopName: 'Glam');
      expect(d.lastUpdated, isNotNull);
      expect(d.lastUpdated!.isAfter(before), isTrue);
    });

    test('copyWith with explicit lastUpdated: null clears the field', () {
      final d = ShopDraft(profileId: 'p').copyWith(lastUpdated: null);
      expect(d.lastUpdated, isNull);
    });

    test('copyWith with specific DateTime preserves it', () {
      final ts = DateTime(2025, 1, 1);
      final d = ShopDraft(profileId: 'p').copyWith(lastUpdated: ts);
      expect(d.lastUpdated, ts);
    });
  });

  group('ShopDraft Equatable — lastUpdated not in props', () {
    test('two drafts with same data but different lastUpdated are equal', () {
      final a = ShopDraft(profileId: 'p', shopName: 'Glam');
      final b = ShopDraft(
        profileId: 'p',
        shopName: 'Glam',
        lastUpdated: DateTime(2020),
      );
      expect(a, b);
    });
  });

  group('ShopDraft JSON round-trip', () {
    test('round-trips all primitive fields', () {
      final d = ShopDraft(
        profileId: 'p',
        shopName: 'Glam',
        address: '5 Main St',
        latitude: 5.6,
        longitude: -0.18,
        currencyCode: 'GHS',
        currencySymbol: 'GH₵',
      );
      final restored = ShopDraft.fromJson(d.toJson());
      expect(restored.shopName, d.shopName);
      expect(restored.latitude, d.latitude);
      expect(restored.currencyCode, d.currencyCode);
    });
  });
}
