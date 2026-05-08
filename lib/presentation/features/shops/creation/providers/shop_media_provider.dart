// lib/features/shop/creation/presentation/providers/shop_media_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/image_cropper_platform.dart';
import 'package:nano_embryo/core/providers/media_%20service_providers.dart';
import 'package:nano_embryo/core/services/media/image_file_service.dart';
import 'package:nano_embryo/core/services/media/image_picker_service.dart';
import 'dart:io';
import 'package:nano_embryo/presentation/features/shops/creation/providers/draft_context_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart'
    show freelancerCreationProvider;
import '../providers/shop_creation_provider.dart';

class ShopMediaNotifier extends StateNotifier<List<File>> {
  final Ref _ref;
  final ImagePickerService _imagePickerService;

  static const int maxImages = 5;
  static const int minImages = 3;

  ShopMediaNotifier({
    required Ref ref,
    required ImagePickerService imagePickerService,
    List<File>? initialImages,
  }) : _ref = ref,
       _imagePickerService = imagePickerService,
       super(initialImages ?? []);

  Future<void> addImage({required bool fromCamera}) async {
    if (state.length >= maxImages) return;

    try {
      final file = await _imagePickerService.pickImage(
        fromCamera: fromCamera,
        crop: true,
        cropRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (file != null) {
        // Handle web vs mobile
        File permanentFile;
        if (kIsWeb) {
          // On web, we can't "save" files the same way
          // Just use the picked file directly
          permanentFile = file;
        } else {
          permanentFile = await ImageFileService.saveFileToPermanent(file);
        }

        state = [...state, permanentFile];
        _updateDraftPaths();
      }
    } catch (e) {
      // debugPrint('Error picking image: $e');
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.length) return;

    final updated = List<File>.from(state)..removeAt(index);
    state = updated;
    _updateDraftPaths();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= state.length ||
        newIndex < 0 ||
        newIndex > state.length)
      return;

    final images = List<File>.from(state);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    state = images;
    _updateDraftPaths();
  }

  void clearAll() {
    state = [];
    _updateDraftPaths();
  }

  void _updateDraftPaths() {
    // On web, paths are not real filesystem paths
    // Store as strings, but be careful
    final paths = state.map((file) => file.path).toList();

    if (_ref.read(draftContextProvider) == DraftContext.freelancer) {
      _ref.read(freelancerCreationProvider.notifier).updateImagePaths(paths);
    } else {
      _ref.read(shopCreationProvider.notifier).updateImagePaths(paths);
    }
  }

  bool get hasMinimum => state.length >= minImages;
  bool get isMaxReached => state.length >= maxImages;
  int get remainingSlots => maxImages - state.length;
}

final shopMediaProvider = StateNotifierProvider<ShopMediaNotifier, List<File>>((
  ref,
) {
  final draftContext = ref.watch(draftContextProvider);
  final imagePickerService = ref.watch(imagePickerServiceProvider);

  final List<String> imagePaths;
  if (draftContext == DraftContext.freelancer) {
    imagePaths = ref.read(freelancerCreationProvider).localImagePaths;
  } else {
    final draft = ref.read(shopCreationProvider);
    imagePaths = draft.localImagePaths;
  }

  // Web-safe file loading - don't use existsSync()
  final initialFiles = <File>[];

  if (!kIsWeb) {
    // Only try to check existence on mobile
    for (final path in imagePaths) {
      final file = File(path);
      if (file.existsSync()) {
        initialFiles.add(file);
      }
    }
  } else {
    // On web, just use the paths as-is
    initialFiles.addAll(imagePaths.map((path) => File(path)));
  }

  return ShopMediaNotifier(
    ref: ref,
    imagePickerService: imagePickerService,
    initialImages: initialFiles,
  );
});
