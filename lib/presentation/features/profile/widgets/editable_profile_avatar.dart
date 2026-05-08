// lib/presentation/widgets/profile/editable_profile_avatar.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/profile_image_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class EditableProfileAvatar extends ConsumerWidget {
  final String? currentAvatarUrl;
  final String currentUserId;
  final double size;
  final VoidCallback? onErrorDismiss;

  /// When provided, the widget only picks the image (no upload).
  /// The picked [File] is passed to this callback so the caller handles saving.
  final void Function(File)? onImagePicked;

  const EditableProfileAvatar({
    super.key,
    required this.currentAvatarUrl,
    this.currentUserId = '',
    this.size = 100,
    this.onErrorDismiss,
    this.onImagePicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(profileImageProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Determine image provider
    ImageProvider? imageProvider;

    if (imageState.selectedImage != null) {
      imageProvider = FileImage(imageState.selectedImage!);
    } else if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(currentAvatarUrl!);
    }

    return Center(
      child: Stack(
        alignment: FractionalOffset.center,
        children: [
          _maybeHero(
            child: GestureDetector(
              onTap: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  maxHeight: 200.h,
                  widget: _showImageSourceDialog(context, ref),
                );
              },
              child: CircleAvatar(
                radius: size / 2,
                backgroundImage: imageProvider,
                backgroundColor: colorScheme.surface,
                child:
                    imageProvider == null
                        ? ProfileAvatarPlaceholder(isEdtting: true, size: size)
                        : null,
              ),
            ),
          ),

          // Loading overlay
          if (imageState.isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

        

          // Error display
          if (imageState.error != null)
            Positioned(
              bottom: -10,
              right: -10,
              child: AppIconButton(
                icon: Icons.error,
                iconColor: Colors.red,
                onPressed: () {
                  ref.read(profileImageProvider.notifier).clearError();
                  onErrorDismiss?.call();
                  context.showErrorSnackbar(imageState.error ?? '');
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _maybeHero({required Widget child}) {
    if (currentUserId.isEmpty) return child;
    return Hero(tag: currentUserId, child: child);
  }

  void _handlePick(BuildContext context, WidgetRef ref, bool fromCamera) {
    Navigator.pop(context);
    if (onImagePicked != null) {
      ref
          .read(profileImageProvider.notifier)
          .pickImageOnly(fromCamera: fromCamera)
          .then((file) {
            if (file != null) onImagePicked!(file);
          });
    } else {
      ref
          .read(profileImageProvider.notifier)
          .pickAndUploadImage(fromCamera: fromCamera);
    }
  }

  Widget _showImageSourceDialog(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Wrap(
        children: [
          InfoRowWidget(
            subtitle: '',
            title: 'Take a photo',
            icon: Icons.camera_alt,
            avatarRadius: 30.h,
            onTap: () => _handlePick(context, ref, true),
            disableTrailing: true,
            showAvatar: false,
            showTrailingArrow: false,
          ),
          InfoRowWidget(
            subtitle: '',
            title: 'Choose from gallery',
            icon: Icons.photo_library,
            avatarRadius: 30.h,
            onTap: () => _handlePick(context, ref, false),
            disableTrailing: true,
            showAvatar: false,
            showTrailingArrow: false,
          ),
        ],
      ),
    );
  }
}
