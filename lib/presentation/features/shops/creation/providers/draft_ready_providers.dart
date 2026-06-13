// lib/features/shop/creation/presentation/providers/ready_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';


final isDraftSystemReadyProvider = Provider<bool>((ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  if (profileId == null) return false;
  // If localDraftStorageProvider throws, Riverpod propagates the error upstream.
  ref.watch(localDraftStorageProvider);
  return true;
});

final validDraftExistsProvider = Provider<bool>((ref) {
  final isReady = ref.watch(isDraftSystemReadyProvider);
  if (!isReady) return false;

  final profileId = ref.watch(currentProfileIdProvider);
  if (profileId == null) return false;

  final storage = ref.watch(localDraftStorageProvider);
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
