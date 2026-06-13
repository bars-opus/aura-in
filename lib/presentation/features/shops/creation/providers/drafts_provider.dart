// lib/features/shop/creation/presentation/providers/drafts_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/draft_preview.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';

class DraftsNotifier extends StateNotifier<DraftPreview?> {
  final Ref _ref;

  DraftsNotifier({required Ref ref}) : _ref = ref, super(null) {
    _loadDraftWithRetry();
  }

  Future<void> _loadDraftWithRetry({int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      final success = await _loadDraft();
      if (success) return;
      if (i < retries - 1) {
        await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
      }
    }
    state = null;
  }

  Future<bool> _loadDraft() async {
    try {
      final profileId = _ref.read(currentProfileIdProvider);
      if (profileId == null) {
        return false;
      }

      // ✅ Use directly - no .value or .future needed
      final storage = _ref.read(localDraftStorageProvider);
      if (storage == null) {
        return false;
      }

      if (!storage.hasDraft(profileId)) {
        return false;
      }

      final draft = storage.loadDraft(profileId);
      if (draft == null) {
        return false;
      }

      if (!_hasContent(draft)) {
        return false;
      }

      state = DraftPreview.fromDraft(draft, profileId);
      return true;
    } catch (e) {
      debugPrint('Error loading draft: $e');
      return false;
    }
  }

  bool _hasContent(ShopDraft draft) {
    return draft.shopName != null ||
        draft.shopType != null ||
        draft.services.isNotEmpty ||
        draft.openingHours.isNotEmpty ||
        draft.contacts.isNotEmpty ||
        draft.localImagePaths.isNotEmpty ||
        draft.documents.isNotEmpty ||
        draft.amenityIds.isNotEmpty ||
        (draft.address != null && draft.address!.isNotEmpty);
  }

  Future<void> refresh() async {
    await _loadDraft();
  }

  Future<bool> clearDraft() async {
    try {
      final profileId = _ref.read(currentProfileIdProvider);
      if (profileId == null) return false;

      final storage = _ref.read(localDraftStorageProvider);
      await storage.clearDraft(profileId);
      state = null;
      return true;
    } catch (e) {
      return false;
    }
  }
}

final draftsProvider = StateNotifierProvider<DraftsNotifier, DraftPreview?>((
  ref,
) {
  return DraftsNotifier(ref: ref);
});

final hasDraftProvider = FutureProvider<bool>((ref) async {
  final profileId = ref.watch(currentProfileIdProvider);
  if (profileId == null) return false;

  final storage = ref.watch(localDraftStorageProvider);
  if (!storage.hasDraft(profileId)) return false;

  final draft = storage.loadDraft(profileId);
  if (draft == null) return false;

  final hasContent =
      draft.shopName != null ||
      draft.shopType != null ||
      draft.services.isNotEmpty ||
      draft.contacts.isNotEmpty ||
      draft.localImagePaths.isNotEmpty ||
      draft.documents.isNotEmpty;

  debugPrint('🔍 hasDraftProvider: $hasContent');
  return hasContent;
});
