// lib/features/shop/creation/data/local_draft_storage.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../domain/models/shop_draft.dart';

/// Key for storing draft in Hive.
const String _draftBoxName = 'shop_drafts';

/// Service responsible for persisting and retrieving shop drafts locally.
class LocalDraftStorage {
  final Box _box;

  LocalDraftStorage._(this._box);

  static Future<LocalDraftStorage> create() async {
    final box = await Hive.openBox(_draftBoxName);
    return LocalDraftStorage._(box);
  }

  // Visible for testing only.
  static LocalDraftStorage fromBox(Box box) => LocalDraftStorage._(box);

  Future<void> saveDraft(String profileId, ShopDraft draft) async {
    await _box.put(profileId, draft.toJson());
  }

  ShopDraft? loadDraft(String profileId) {
    try {
      final json = _box.get(profileId);
      if (json == null) return null;

      final Map<String, dynamic> safeJson;
      if (json is Map<String, dynamic>) {
        safeJson = json;
      } else if (json is Map) {
        safeJson = Map<String, dynamic>.from(json);
      } else {
        return null;
      }

      return ShopDraft.fromJson(safeJson);
    } catch (e) {
      debugPrint('Error loading draft: $e');
      return null;
    }
  }

  Future<void> clearDraft(String profileId) async {
    await _box.delete(profileId);
  }

  bool hasDraft(String profileId) {
    return _box.containsKey(profileId);
  }
}

// Global reference for fallback
LocalDraftStorage? _cachedStorage;

final localDraftStorageProvider = Provider<LocalDraftStorage>((ref) {
  // First check if we have a cached instance from main.dart
  if (_cachedStorage != null) {
    return _cachedStorage!;
  }

  // Fallback: try to create storage synchronously (should not happen if main.dart is correct)
  throw StateError('LocalDraftStorage must be initialized in main.dart');
});

// Call this from main.dart after creating storage
void setLocalDraftStorage(LocalDraftStorage storage) {
  _cachedStorage = storage;
}
