// lib/features/shop/creation/presentation/widgets/delete_shop_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/confirmation_dialog.dart';
import 'package:nano_embryo/core/widgets/feedback/error_state.dart';
import 'package:nano_embryo/core/widgets/feedback/loading_state.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/delete_shop_provider.dart';

class DeleteShopButton extends ConsumerWidget {
  final String shopId;
  final VoidCallback onDeleted;

  const DeleteShopButton({
    super.key,
    required this.shopId,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleteState = ref.watch(deleteShopNotifierProvider);
    final deleteNotifier = ref.read(deleteShopNotifierProvider.notifier);

    // Show error bottom sheet when error occurs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (deleteState.error != null && context.mounted) {
        _showErrorBottomSheet(context, deleteState.error!, () {
          deleteNotifier.clearError();
          BottomSheetUtils.showDocumentationBottomSheet(
            maxHeight: 400.h,
            context: context,
            widget: _confirmDelete(context, ref, shopId, onDeleted),
          );
          //
        });
      }
    });

    return AppButton(
      label: deleteState.isDeleting ? 'Deleting...' : 'Delete Shop',
      onPressed:
          deleteState.isDeleting
              ? null
              : () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  maxHeight: 400.h,
                  context: context,
                  widget: _confirmDelete(context, ref, shopId, onDeleted),
                );
              },
      isLoading: deleteState.isDeleting,
    );
  }

  void _showErrorBottomSheet(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 400.h,
      context: context,
      widget: ErrorStateWidget(
        title: 'Error Deleting Shop',
        subtitle: error,
        onPrimaryAction: onRetry,
        primaryActionLabel: 'Try Again',
      ),
    );
  }

  _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String shopId,
    VoidCallback onDeleted,
  ) {
    return ConfirmationDialog(
      type: ConfirmationType.warning,
      title: 'Are you sure you want to delete this shop.',
      message:
          'This shop and all its associated data would be parmanently deleted.',
      confirmText: 'Remove location',
      onConfirm: () async {
        // Show loading snackbar
        context.showLoadingSnackbar(
          'Deleting shop',
          // loc.verifyEmailSentMessage
        );

        final success = await ref
            .read(deleteShopNotifierProvider.notifier)
            .deleteShop(shopId);
        ScaffoldMessenger.of(context).clearSnackBars();

        if (success && context.mounted) {
          context.showSuccessSnackbar(
            'Shop deleted successfully',
            // loc.verifyEmailSentMessage
          );

          onDeleted();
          // Navigate back to previous screen
          Navigator.pop(context);
        }
      },
    );
  }
}
