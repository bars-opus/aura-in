import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/widgets/feedback/confirmation_dialog.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/document_preview_dialog.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/document_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/documents_provider.dart';

class DisplayShopDocuments extends ConsumerWidget {
  final List<DocumentDraft> documents;

  const DisplayShopDocuments({super.key, required this.documents});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: documents.length * 120.h,
      child: ReorderableListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: documents.length,
        onReorder: (oldIndex, newIndex) {
          ref
              .read(documentsProvider.notifier)
              .reorderDocuments(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final document = documents[index]; // ✅ This is DocumentDraft
          return DocumentTile(
            key: ValueKey(document.id),
            document: document, // ✅ Now passing correct type
            onView: () => _viewDocument(context, document),
            onDelete: () => _deleteDocument(context, ref, index),
            isDraggable: true,
          );
        },
      ),
    );
  }

  void _viewDocument(BuildContext context, DocumentDraft document) {
    showDialog(
      context: context,
      builder: (ctx) => DocumentPreviewDialog(document: document),
    );
  }

  void _deleteDocument(BuildContext context, WidgetRef ref, int index) {
    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 400.h,
      context: context,
      widget: ConfirmationDialog(
        type: ConfirmationType.warning,
        title: 'Remove Document?',
        icon: Icons.delete,
        message: 'Are you sure you want to remove this document?',
        confirmText: 'Remove',
        onConfirm: () {
          ref.read(documentsProvider.notifier).removeDocument(index);
        },
      ),
    );
  }
}
