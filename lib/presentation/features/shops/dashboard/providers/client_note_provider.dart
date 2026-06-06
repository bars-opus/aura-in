// lib/presentation/features/shops/dashboard/providers/client_note_provider.dart
//
// Phase 12 — provider family for the per-(shop, client) sticky note.
//
// Key shape: (shopId, userId | guestProfileId). The note belongs to the
// CLIENT, not the booking — the same client may have many bookings at
// the same shop and the note persists across all of them. Keying on
// booking_id would make the note re-load fresh per booking, which is
// the wrong UX.
//
// Invalidate after a save via:
//   ref.invalidate(clientNoteProvider(key));

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/client_note_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class ClientNoteKey {
  final String shopId;
  final String? userId;
  final String? guestProfileId;

  const ClientNoteKey({
    required this.shopId,
    this.userId,
    this.guestProfileId,
  }) : assert(
          (userId == null) != (guestProfileId == null),
          'Exactly one of userId / guestProfileId must be non-null',
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientNoteKey &&
          other.shopId == shopId &&
          other.userId == userId &&
          other.guestProfileId == guestProfileId;

  @override
  int get hashCode => Object.hash(shopId, userId, guestProfileId);
}

final clientNoteProvider =
    FutureProvider.family<ClientNoteDTO?, ClientNoteKey>((ref, key) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getClientNote(
    shopId: key.shopId,
    userId: key.userId,
    guestProfileId: key.guestProfileId,
  );
});
