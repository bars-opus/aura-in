// lib/features/shop/creation/presentation/widgets/shop_media_grid.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/image_source_dialog.dart';
import 'dart:io';

import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_media_provider.dart';
import 'package:reorderables/reorderables.dart';

class ShopMediaGrid extends ConsumerWidget {
  const ShopMediaGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(shopMediaProvider);
    // Don't try to access static members through instance
    // Use the class directly for static values
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        CardInkWell(
          margin: EdgeInsets.only(bottom: Spacing.md.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${images.length}/${ShopMediaNotifier.maxImages} photos',

                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600, // Bold for prominence
                ),
              ),

              Gap(Spacing.sm.h),
              AppDivider(),
              Gap(Spacing.sm.h),

              // Reorderable grid using ReorderableWrap
              if (images.isNotEmpty)
                Center(
                  child: ReorderableWrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(shopMediaProvider.notifier)
                          .reorderImages(oldIndex, newIndex);
                    },
                    children: List.generate(images.length, (index) {
                      final file = images[index];
                      return GestureDetector(
                        key: ValueKey(file.path),
                        onTap: () => _showImagePreview(context, file, index),
                        child: SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 3,
                          height: (MediaQuery.of(context).size.width - 48) / 3,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(file, fit: BoxFit.cover),
                              ),

                              // Delete button
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(shopMediaProvider.notifier)
                                        .removeImage(index);
                                  },
                                  // _confirmDelete(context, ref, index),
                                  child: Container(
                                    padding: EdgeInsets.all(4.r),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14.sp,
                                    ),
                                  ),
                                ),
                              ),

                              // Cover indicator
                              if (index == 0)
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'Cover',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ),
                                ),

                              // Drag handle indicator
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: EdgeInsets.all(2.r),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: Colors.white,
                                    size: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

              if (images.isNotEmpty) Gap(Spacing.md.h),
              if (images.isNotEmpty) AppDivider(),

              Gap(Spacing.sm.h),

              // Add button (if under max)
              if (images.length < ShopMediaNotifier.maxImages) // ✅ Use class
                InfoRowWidget(
                  title: 'Add Photo',
                  subtitle: 'Tap to add shop photo',
                  icon: Icons.camera_alt_rounded,
                  onTap: () => _showImageSourceDialog(context, ref),
                  showAvatar: false,
                  showDivider: false,
                ),
              Gap(Spacing.md.h),
            ],
          ),
        ),
        // Validation message
        if (images.length < ShopMediaNotifier.minImages) // ✅ Use class
          SemanticContainerWidget(
            content: '',
            icon: Icons.warning_amber_outlined,
            title:
                'Add ${ShopMediaNotifier.minImages - images.length} more photo${ShopMediaNotifier.minImages - images.length > 1 ? 's' : ''} (minimum 3)',
            backgroundColor: Colors.orange.withOpacity(0.1),
            borderColor: Colors.orange,
            iconColor: Colors.orange,
            textTheme: theme.textTheme,
          )
        else
          SemanticContainerWidget(
            content: '',
            icon: Icons.check_circle,
            title: 'Minimum photos requirement met',
            backgroundColor: Colors.green.withOpacity(0.1),
            borderColor: Colors.green,
            iconColor: Colors.green,
            textTheme: theme.textTheme,
          ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context, WidgetRef ref) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 300.h,
      widget: ImageSourceDialog(
        onCameraSelected: () {
          Navigator.pop(context);
          ref.read(shopMediaProvider.notifier).addImage(fromCamera: true);
        },
        onGallerySelected: () {
          Navigator.pop(context);
          ref.read(shopMediaProvider.notifier).addImage(fromCamera: false);
        },
        currentCount: ref.read(shopMediaProvider).length,
      ),
    );
  }

  void _showImagePreview(BuildContext context, File file, int index) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(file),
                Padding(
                  padding: EdgeInsets.all(Spacing.sm.h),
                  child: Text('Photo ${index + 1}'),
                ),
                Padding(
                  padding: EdgeInsets.all(Spacing.sm.h),
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int index) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 400.h,
      widget: ConfirmationDialog(
        type: ConfirmationType.warning,
        title: 'Remove Photo?',
        message: 'Are you sure you want to remove this photo?',
        confirmText: 'Remove',
        onConfirm: () {
          ref.read(shopMediaProvider.notifier).removeImage(index);
        },
      ),
    );
  }
}
