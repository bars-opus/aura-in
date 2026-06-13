// lib/features/shop/creation/presentation/providers/ready_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';


final isDraftSystemReadyProvider = FutureProvider<bool>((ref) async {
  // Wait for profile
  final profileId = ref.watch(currentProfileIdProvider);
  if (profileId == null) return false;
  
  // Storage is already initialized - just check if it's available
  final storage = ref.watch(localDraftStorageProvider);
  
  // Storage is ready if it's not null
  return storage != null;
});

final validDraftExistsProvider = FutureProvider<bool>((ref) async {
  // Wait for system to be ready
  final isReady = await ref.watch(isDraftSystemReadyProvider.future);
  if (!isReady) return false;
  
  final profileId = ref.watch(currentProfileIdProvider);
  if (profileId == null) return false;
  
  final storage = ref.watch(localDraftStorageProvider);
  if (storage == null) return false;
  
  if (!storage.hasDraft(profileId)) return false;
  
  final draft = storage.loadDraft(profileId);
  if (draft == null) return false;
  
  return draft.shopName != null ||
      draft.shopType != null ||
      draft.services.isNotEmpty ||
      draft.contacts.isNotEmpty ||
      draft.localImagePaths.isNotEmpty ||
      draft.documents.isNotEmpty;
});
