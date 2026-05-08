// lib/features/shop/creation/utils/creation_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/widgets/feedback/loading_state.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';

import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';

// In creation_navigation.dart
class CreationNavigation {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    // This should be called once when the app starts
    if (_isInitialized) return;
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
    // print('✅ CreationNavigation initialized');
  }

  static Future<void> navigateToShopCreation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Ensure we're initialized before checking draft
    if (!_isInitialized) {
      // print('⏳ Waiting for initialization...');
      await initialize();
    }

    // Show loading indicator
    final loadingDialog = BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: LoadingStateWidget(type: LoadingStateType.inline),
    );

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (ctx) => const Center(child: CircularProgressIndicator()),
    // );

    try {
      // Small delay to ensure widget tree is stable
      await Future.delayed(const Duration(milliseconds: 100));

      // Get storage with retry
      final storage = await _getStorageWithRetry(ref);
      if (storage == null) {
        // print('❌ Storage not available');
        if (context.mounted) Navigator.pop(context);
        context.push('/shopCreation');
        return;
      }

      final profileId = ref.read(currentProfileIdProvider);
      if (profileId == null) {
        if (context.mounted) Navigator.pop(context);
        context.push('/shopCreation');
        return;
      }

      final hasValidDraft = await _checkForValidDraft(storage, profileId);

      if (context.mounted) Navigator.pop(context);

      if (hasValidDraft && context.mounted) {
        // print('🎯 Navigating to draftsScreen');
        context.push('/draftsScreen');
      } else if (context.mounted) {
        // print('🎯 Navigating to shopCreation');
        context.push('/shopCreation');
      }
    } catch (e) {
      // print('❌ Navigation error: $e');
      if (context.mounted) Navigator.pop(context);
      context.push('/shopCreation');
    }
  }

  static Future<LocalDraftStorage?> _getStorageWithRetry(WidgetRef ref) async {
    for (int i = 0; i < 5; i++) {
      final storage = ref.read(localDraftStorageProvider);
      if (storage != null) {
        return storage;
      }
      // print('⏳ Waiting for storage... attempt ${i + 1}');
      await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
    }
    return null;
  }

  static Future<bool> _checkForValidDraft(
    LocalDraftStorage storage,
    String profileId,
  ) async {
    try {
      if (!storage.hasDraft(profileId)) return false;
      final draft = storage.loadDraft(profileId);
      if (draft == null) return false;

      return draft.shopName != null ||
          draft.shopType != null ||
          draft.services.isNotEmpty ||
          draft.contacts.isNotEmpty ||
          draft.localImagePaths.isNotEmpty ||
          draft.documents.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
