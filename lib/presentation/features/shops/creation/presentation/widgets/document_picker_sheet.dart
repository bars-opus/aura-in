// lib/features/shop/creation/presentation/widgets/document_picker_sheet.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';
import 'package:nano_embryo/core/widgets/app_text_form_field.dart';
import 'package:nano_embryo/core/widgets/buttons/app_icon_button.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:nano_embryo/presentation/home/widgets/semantic_container_widget.dart';

class DocumentPickerSheet extends ConsumerStatefulWidget {
  final Function(DocumentDraft) onDocumentPicked;

  const DocumentPickerSheet({super.key, required this.onDocumentPicked});

  @override
  ConsumerState<DocumentPickerSheet> createState() =>
      _DocumentPickerSheetState();
}

class _DocumentPickerSheetState extends ConsumerState<DocumentPickerSheet> {
  DocumentType? _selectedType;
  DateTime? _expiryDate;
  bool _isLoading = false;
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: AppIconButton(
          icon: Icons.close,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // AppTextButton(
          //   text: widget.initialAward == null ? 'Add' : 'Save',
          //   onPressed: _submit,
          // ),
        ],
      ),
      body: ListView(
        children: [
          Gap(Spacing.lg.h),

          SemanticContainerWidget(
            content:
                'Upload business documents for verification. Add expiry dates for licenses and permits.',
            title: '',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),

          Gap(Spacing.lg.h),

          // Document Type Selection
          Text(
            'Document Type *',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),
          Gap(Spacing.sm.h),
          _buildDocumentTypeChips(),

          Gap(Spacing.md.h),

          // Title (optional, defaults to type name)
          AppTextFormField(
            controller: _titleController,
            label: 'Document Title (optional)',
            hintText: 'e.g., "Business License 2024"',
            prefixIcon: Icons.title,
            onChanged: (_) {},
          ),

          Gap(Spacing.md.h),

          // Expiry Date (optional)
          _buildExpiryDatePicker(),

          Gap(Spacing.lg.h),

          // Upload option
          CardInkWell(
            margin: EdgeInsets.only(bottom: Spacing.md.h),
            child: Column(
              children: [
                InfoRowWidget(
                  title: 'Choose file',
                  subtitle: 'PDF, JPG, or PNG · max 10 MB',
                  icon: Icons.upload_file,
                  onTap: _selectedType == null ? null : _pickDocument,
                  showAvatar: false,
                  showTrailingArrow: false,
                ),
                if (_isLoading) ...[
                  Gap(Spacing.md.h),
                  const Center(child: CircularLoadingIndicator()),
                ],
              ],
            ),
          ),

          // Gap(Spacing.lg.h),

          // // Cancel button
          // Center(
          //   child: AppTextButton(
          //     text: 'Cancel',
          //     onPressed: () => Navigator.pop(context),
          //   ),
          // ),
          // Gap(Spacing.lg.h),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeChips() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.md.h),
      child: Wrap(
        spacing: 5.w,
        runSpacing: .5.h,
        children:
            DocumentType.values.map((type) {
              final isSelected = _selectedType == type;
              return AppFilterChip(
                avatarIcon: type.icon,
                label: type.displayName,
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                    // Auto-fill title with type name if not customized
                    if (selected && _titleController.text.isEmpty) {
                      _titleController.text = type.displayName;
                    }
                  });
                },
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.background,
                labelColor: colorScheme.onSurface.withOpacity(0.3),
                borderWidth: 0.3,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildExpiryDatePicker() {
    return GestureDetector(
      onTap: _selectedType == null ? null : _selectExpiryDate,
      // _selectExpiryDate,
      child: InfoRowWidget(
        subtitle: '(optional)',
        title:
            _expiryDate != null
                ? MyDateFormat.toDate(_expiryDate!)
                : 'Expiry Date',
        icon: Icons.calendar_month,
        iconSize: 20.h,
        // avatarRadius: 25.h,
        onTap: _selectedType == null ? null : _selectExpiryDate,
        disableTrailing: false,
        showAvatar: false,
        showDivider: false,
        showTrailingArrow: false,
        trailing: AppIconButton(
          icon: Icons.add,
          onPressed: _selectedType == null ? null : _selectExpiryDate,
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final initialDate =
        _expiryDate ?? DateTime.now().add(const Duration(days: 365));

    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 320.h,
      context: context,
      widget: Builder(
        builder:
            (sheetContext) => Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 50),
                      Text(
                        'Select Expiry Date',
                        style: Theme.of(sheetContext).textTheme.titleSmall,
                      ),
                      AppTextButton(
                        text: 'Done',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    minimumDate: DateTime.now(),
                    maximumDate: DateTime.now().add(const Duration(days: 3650)),
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _expiryDate = newDate;
                      });
                    },
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Future<void> _pickDocument() async {
    if (_selectedType == null) return;
    setState(() => _isLoading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty || result.files.first.path == null) {
        return;
      }

      final file = File(result.files.first.path!);
      if (!mounted) return;

      final document = DocumentDraft(
        type: _selectedType!,
        title: _titleController.text.isNotEmpty
            ? _titleController.text
            : _selectedType!.displayName,
        file: file,
        expiryDate: _expiryDate,
        isVerified: false,
      );

      widget.onDocumentPicked(document);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) context.showErrorSnackbar('Error picking document: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
