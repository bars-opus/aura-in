// lib/features/shop/creation/presentation/widgets/document_preview_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'dart:io';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';

class DocumentPreviewDialog extends StatelessWidget {
  final DocumentDraft document;

  const DocumentPreviewDialog({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(Spacing.md.h),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Spacing.xs.h),
                    decoration: BoxDecoration(
                      color: _getDocumentColor(document.type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      document.type.icon,
                      color: _getDocumentColor(document.type),
                    ),
                  ),
                  SizedBox(width: Spacing.sm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title ?? document.type.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          document.type.displayName,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Image preview
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Spacing.md.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(document.file, fit: BoxFit.contain),
                ),
              ),
            ),

            // Footer with metadata
            Container(
              padding: EdgeInsets.all(Spacing.md.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, 'File name:', document.fileName),
                  _buildInfoRow(context, 'File size:', document.fileSize),
                  if (document.expiryDate != null)
                    _buildInfoRow(
                      context,
                      'Expires:',
                      _formatDate(document.expiryDate!),
                      color: document.isExpired ? Colors.red : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.xs.h),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: color != null ? FontWeight.w600 : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.license:
        return Colors.blue;
      case DocumentType.certification:
        return Colors.green;
      case DocumentType.insurance:
        return Colors.orange;
      case DocumentType.tax:
        return Colors.purple;
      case DocumentType.id:
        return Colors.teal;
      case DocumentType.permit:
        return Colors.indigo;
      case DocumentType.other:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
