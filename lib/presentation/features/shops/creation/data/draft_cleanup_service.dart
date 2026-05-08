// lib/features/shop/creation/data/draft_cleanup_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';

class DraftCleanupService {
  final Ref _ref;

  DraftCleanupService(this._ref);

  /// Clear draft on logout
  Future<void> clearDraftOnLogout() async {
    await _ref.read(shopCreationProvider.notifier).clearDraft();
  }

  /// Clear expired drafts (older than 7 days)
  Future<void> clearExpiredDrafts() async {
    final box = await Hive.openBox('shop_drafts');
    final now = DateTime.now();
    
    for (var key in box.keys) {
      final draftJson = box.get(key);
      if (draftJson != null && draftJson['lastUpdated'] != null) {
        final lastUpdated = DateTime.parse(draftJson['lastUpdated']);
        final daysOld = now.difference(lastUpdated).inDays;
        
        if (daysOld > 7) {
          await box.delete(key);
        }
      }
    }
  }
}

final draftCleanupServiceProvider = Provider<DraftCleanupService>((ref) {
  return DraftCleanupService(ref);
});
