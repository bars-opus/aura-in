/// Repository-level tests for the shop creation data layer.
///
/// Tests that don't touch Supabase directly cover the data-shaping logic
/// (contact deduplication, currency mapping, slot payload construction).
/// Integration tests (actual DB round-trips) belong in the integration_test/
/// directory and require a live Supabase project.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

AppointmentSlotDTO _slot({int price = 5000}) => AppointmentSlotDTO(
  id: 'svc-1',
  serviceName: 'Haircut',
  serviceType: null,
  duration: '30 minutes',
  price: price,
  slotType: 'regular',
  maxClients: 1,
  daysOfWeek: const [1, 2, 3, 4, 5],
  selectPreferredWorker: false,
  workerIds: const [],
  bufferMinutes: 0,
);

/// Mirrors the contact-deduplication logic from SupabaseShopCreationRepository.
/// When the plan migrated to a unified contacts list, duplicate inserts for
/// phone/email/website were removed. This test verifies the ShopDraft correctly
/// represents the merged state.
List<ContactDraft> _contactsToSave(ShopDraft draft) {
  final result = <ContactDraft>[];
  if (draft.contacts.isNotEmpty) {
    result.addAll(draft.contacts);
  } else {
    if (draft.phone != null && draft.phone!.isNotEmpty) {
      result.add(ContactDraft(type: ContactType.phone, value: draft.phone!));
    }
    if (draft.email != null && draft.email!.isNotEmpty) {
      result.add(ContactDraft(type: ContactType.email, value: draft.email!));
    }
    if (draft.website != null && draft.website!.isNotEmpty) {
      result.add(ContactDraft(type: ContactType.website, value: draft.website!));
    }
  }
  return result;
}

void main() {
  group('Contact deduplication (mirrors repository logic)', () {
    test('prefers contacts list when populated', () {
      final draft = ShopDraft(
        profileId: 'p',
        phone: '+233501234567',
        email: 'hello@glam.com',
        contacts: [
          ContactDraft(type: ContactType.phone, value: '+233501234567'),
          ContactDraft(type: ContactType.email, value: 'hello@glam.com'),
        ],
      );
      final result = _contactsToSave(draft);
      expect(result.length, 2);
    });

    test('falls back to legacy fields when contacts is empty', () {
      final draft = ShopDraft(
        profileId: 'p',
        phone: '+233501234567',
        email: 'hello@glam.com',
        website: 'https://glam.com',
      );
      final result = _contactsToSave(draft);
      expect(result.length, 3);
      expect(result.map((c) => c.type), containsAll([
        ContactType.phone,
        ContactType.email,
        ContactType.website,
      ]));
    });

    test('produces zero contacts when both fields and list are empty', () {
      final draft = ShopDraft(profileId: 'p');
      expect(_contactsToSave(draft), isEmpty);
    });
  });

  group('AppointmentSlotDTO price in minor units', () {
    test('price field is stored as integer (kobo/cents)', () {
      final slot = _slot(price: 7500); // 75.00 major units
      expect(slot.price, 7500);
      expect(slot.price, isA<int>());
    });

    test('toJson serialises price as integer', () {
      final json = _slot(price: 3000).toJson();
      expect(json['price'], 3000);
    });
  });

  group('ShopDraft currency fallback', () {
    test('currency getter returns null when currencyCode is null', () {
      const d = ShopDraft(profileId: 'p');
      expect(d.currency, isNull);
    });

    test('currency getter returns Currency with code for known code', () {
      const d = ShopDraft(profileId: 'p', currencyCode: 'USD');
      expect(d.currency?.code, 'USD');
    });
  });
}
