// lib/features/shop/creation/presentation/providers/publish_provider.dart

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/usecases/publish_shop_usecase.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/edit_shop_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_media_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/documents_provider.dart';

/// Publish state with loading, error, and progress tracking
class PublishState {
  final bool isPublishing;
  final String? error;
  final String? shopId;
  final double progress; // 0.0 to 1.0
  final String currentStep; // Current step description

  const PublishState({
    this.isPublishing = false,
    this.error,
    this.shopId,
    this.progress = 0.0,
    this.currentStep = '',
  });

  PublishState copyWith({
    bool? isPublishing,
    String? error,
    String? shopId,
    double? progress,
    String? currentStep,
  }) {
    return PublishState(
      isPublishing: isPublishing ?? this.isPublishing,
      error: error,
      shopId: shopId ?? this.shopId,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  /// Helper to check if loading
  bool get isLoading => isPublishing;

  /// Helper to check if has error
  bool get hasError => error != null;

  /// Helper to check if success
  bool get isSuccess => shopId != null && !isPublishing && error == null;
}

class PublishNotifier extends StateNotifier<PublishState> {
  final Ref _ref;
  final PublishShopUseCase _publishShopUseCase;

  PublishNotifier({
    required Ref ref,
    required PublishShopUseCase publishShopUseCase,
  }) : _ref = ref,
       _publishShopUseCase = publishShopUseCase,
       super(const PublishState());

  /// Create a new shop with loading progress
  Future<bool> publish() async {
    if (state.isPublishing) return false; // idempotency guard

    final draft = _ref.read(shopCreationProvider);
    final images = _ref.read(shopMediaProvider);
    final documents = _ref.read(documentsProvider);
    final profileId = _ref.read(currentProfileIdProvider);

    // Validation
    if (profileId == null) {
      state = state.copyWith(error: 'Not logged in');
      return false;
    }

    if (!draft.isMinimumViable) {
      state = state.copyWith(error: 'Please complete all required sections');
      return false;
    }

    // Start publishing
    state = state.copyWith(
      isPublishing: true,
      error: null,
      progress: 0.0,
      currentStep: 'Preparing your shop...',
    );

    try {
      // Step 1: Preparing (10%)
      state = state.copyWith(progress: 0.1, currentStep: 'Preparing images...');
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 2: Uploading images (30%)
      state = state.copyWith(progress: 0.3, currentStep: 'Uploading images...');

      // Step 3: Creating shop (70%)
      state = state.copyWith(
        progress: 0.7,
        currentStep: 'Creating your shop...',
      );

      final shopId = await _publishShopUseCase.execute(
        draft: draft,
        profileId: profileId,
        images: images,
        documents: documents,
      );

      // Step 4: Finalizing (90%)
      state = state.copyWith(progress: 0.9, currentStep: 'Finalizing...');

      // Clear the draft after successful publish
      await _ref.read(shopCreationProvider.notifier).clearDraft();

      // Success
      state = state.copyWith(
        isPublishing: false,
        shopId: shopId,
        progress: 1.0,
        currentStep: 'Complete!',
      );

      return true;
    } catch (e) {
      // Error state
      state = state.copyWith(
        isPublishing: false,
        error: _getUserFriendlyError(e),
        progress: 0.0,
        currentStep: '',
      );
      return false;
    }
  }

  /// Returns true if the error is transient and safe to retry.
  bool _isRetryable(String error) {
    final s = error.toLowerCase();
    if (s.contains('status 4') ||
        s.contains('duplicate') ||
        s.contains('unauthorized') ||
        s.contains('permission') ||
        s.contains('not logged in')) {
      return false; // 4xx / auth / constraint errors — permanent, don't retry
    }
    return true;
  }

  /// Publish with retry logic
  Future<bool> publishWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final success = await publish();
      if (success) return true;

      final err = state.error ?? '';
      if (!_isRetryable(err)) return false;

      if (attempt < maxRetries) {
        state = state.copyWith(
          currentStep: 'Retrying... (Attempt $attempt/$maxRetries)',
        );
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return false;
  }

  /// Update an existing shop
  Future<bool> update({required String shopId, List<File>? newImages}) async {
    if (state.isPublishing) return false; // idempotency guard

    final draft = _ref.read(shopCreationProvider);
    final profileId = _ref.read(currentProfileIdProvider);
    final editState = _ref.read(editShopProvider(shopId));

    final pathToUrl = editState.localPathToOriginalUrl;
    final docPathToUrl = editState.localDocPathToOriginalUrl;
    final imageUrlToId = editState.imageUrlToId;
    final docUrlToId = editState.docUrlToId;

    // Determine which images were deleted using the path→URL mapping
    final existingImageUrls = editState.existingImageUrls;
    final currentImagePaths = draft.localImagePaths;
    final keptOriginalUrls =
        currentImagePaths
            .map((p) => pathToUrl[p])
            .whereType<String>()
            .toSet();
    final removedImageUrls =
        existingImageUrls.where((url) => !keptOriginalUrls.contains(url)).toList();
    final imageIdsToDelete =
        removedImageUrls
            .map((url) => imageUrlToId[url])
            .whereType<String>()
            .toList();

    // Determine which documents were deleted
    final existingDocumentUrls = editState.existingDocumentUrls;
    final currentDocuments = draft.documents;
    final keptDocUrls =
        currentDocuments
            .map((d) => docPathToUrl[d.file.path])
            .whereType<String>()
            .toSet();
    final removedDocUrls =
        existingDocumentUrls.where((url) => !keptDocUrls.contains(url)).toList();
    final docIdsToDelete =
        removedDocUrls
            .map((url) => docUrlToId[url])
            .whereType<String>()
            .toList();

    // Determine new documents added
    final newDocuments =
        currentDocuments
            .where((d) => !docPathToUrl.containsKey(d.file.path))
            .toList();

    if (profileId == null) {
      state = state.copyWith(error: 'Not logged in');
      return false;
    }

    state = state.copyWith(
      isPublishing: true,
      error: null,
      progress: 0.1,
      currentStep: 'Updating your shop...',
    );

    try {
      state = state.copyWith(
        progress: 0.5,
        currentStep: 'Uploading changes...',
      );

      await _publishShopUseCase.update(
        shopId: shopId,
        draft: draft,
        profileId: profileId,
        newImages: newImages,
        imageIdsToDelete: imageIdsToDelete,
        imagesToDelete: removedImageUrls,
        newDocuments: newDocuments,
        docIdsToDelete: docIdsToDelete,
        documentUrlsToDelete: removedDocUrls,
      );

      state = state.copyWith(
        isPublishing: false,
        progress: 1.0,
        currentStep: 'Update complete!',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: _getUserFriendlyError(e),
        progress: 0.0,
        currentStep: '',
      );
      return false;
    }
  }

  /// Update with retry
  Future<bool> updateWithRetry({
    required String shopId,
    List<File>? newImages,
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final success = await update(shopId: shopId, newImages: newImages);
      if (success) return true;

      final err = state.error ?? '';
      if (!_isRetryable(err)) return false;

      if (attempt < maxRetries) {
        state = state.copyWith(
          currentStep: 'Retrying update... (Attempt $attempt/$maxRetries)',
        );
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return false;
  }

  /// Reset state
  void reset() {
    state = const PublishState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return 'You don\'t have permission to perform this action.';
    }
    if (errorString.contains('storage') || errorString.contains('upload')) {
      return 'Failed to upload images. Please try again.';
    }
    if (errorString.contains('duplicate')) {
      return 'A shop with this name already exists.';
    }

    return 'Something went wrong. Please try again.';
  }
}

final publishProvider = StateNotifierProvider<PublishNotifier, PublishState>((
  ref,
) {
  final publishShopUseCase = ref.watch(publishShopUseCaseProvider);
  return PublishNotifier(ref: ref, publishShopUseCase: publishShopUseCase);
});
