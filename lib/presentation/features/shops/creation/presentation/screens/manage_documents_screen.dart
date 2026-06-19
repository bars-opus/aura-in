// lib/features/shop/creation/presentation/screens/manage_documents_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';
import 'package:nano_embryo/core/widgets/feedback/confirmation_dialog.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/display_shop_documents.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/document_picker_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/document_preview_dialog.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/document_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/documents_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';

class ManageDocumentsScreen extends ConsumerStatefulWidget {
  const ManageDocumentsScreen({super.key});

  @override
  ConsumerState<ManageDocumentsScreen> createState() =>
      _ManageDocumentsScreenState();
}

class _ManageDocumentsScreenState extends ConsumerState<ManageDocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ Use documentsProvider, not draft.documentPaths
    final documents = ref.watch(documentsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    //  final draft = ref.watch(shopCreationProvider);

    return Scaffold(
      backgroundColor: colorScheme.neutral,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          AppIconButton(icon: Icons.add, onPressed: _showDocumentPicker),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
        children: [
          SemanticContainerWidget(
            content:
                'Upload business regustration documents, licenses, certifications, and other relevants documents for verification',
            icon: Icons.description,
            title: 'Documents',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),
          Gap(Spacing.md.h),
          // Documents list
          Expanded(
            child:
                documents.isEmpty
                    ? _buildEmptyState()
                    : DisplayShopDocuments(documents: documents),
          ),
        ],
      ),
      bottomNavigationBar:
          documents.isEmpty
              ? null
              : SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to shop photos',
                    onPressed: _saveAndContinue,
                    center: false,
                    iconData: Icons.image,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              ),
    );
  }

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/manageMedia'); // Use your navigation method
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyStateWidget(
        actionLabel: 'Add',
        onAction: _showDocumentPicker,
        icon: Icons.description_outlined,
        title: 'No documents yet',
        subtitle:
            'Upload business licenses, certifications, or other documents',
      ),
    );
  }

  void _showDocumentPicker() {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: DocumentPickerSheet(
        onDocumentPicked: (document) {
          ref.read(documentsProvider.notifier).addDocument(document);
        },
      ),
    );
  }

 
}
