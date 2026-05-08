// lib/features/shop/creation/presentation/widgets/image_source_dialog.dart

import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ImageSourceDialog extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final int currentCount;

  const ImageSourceDialog({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
    required this.currentCount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          BottomSheetHeader(title: ''), // Gallery option
          InfoRowWidget(
            title: 'Choose from gallery',
            icon: Icons.photo_library,
            onTap: onGallerySelected,
            disableTrailing: true,
            showAvatar: false,
            showTrailingArrow: false,
            subtitle: 'Capture a new shop photo',
          ),
          // Camera option
          InfoRowWidget(
            title: 'Take a photo',
            icon: Icons.camera_alt,
            onTap: onCameraSelected,
            disableTrailing: true,
            showAvatar: false,
            showTrailingArrow: false,
            subtitle: 'Select an existing shop image',
          ),
        ],
      ),
    );
  }
}
