// lib/features/shop/creation/presentation/widgets/add_award_modal.dart

import 'package:flutter/cupertino.dart';
import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:uuid/uuid.dart';

class AddAwardModal extends StatefulWidget {
  final Function(AwardDTO) onSave;
  final AwardDTO? initialAward;

  const AddAwardModal({super.key, required this.onSave, this.initialAward});

  @override
  State<AddAwardModal> createState() => _AddAwardModalState();
}

class _AddAwardModalState extends State<AddAwardModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _issuerController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialAward != null) {
      _nameController = TextEditingController(text: widget.initialAward!.name);
      _issuerController = TextEditingController(
        text: widget.initialAward!.issuer,
      );
      _descriptionController = TextEditingController(
        text: widget.initialAward!.description,
      );
      _linkController = TextEditingController(text: widget.initialAward!.link);
      _selectedDate =
          widget.initialAward!.dateReceived == null
              ? DateTime.now()
              : DateTime.parse(widget.initialAward!.dateReceived!);
    } else {
      _nameController = TextEditingController();
      _issuerController = TextEditingController();
      _descriptionController = TextEditingController();
      _linkController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _autoSave() {
    // Only auto-save if we're editing an existing award
    if (widget.initialAward != null &&
        _formKey.currentState?.validate() == true) {
      final award = AwardDTO(
        name: _nameController.text,
        issuer:
            _issuerController.text.isNotEmpty ? _issuerController.text : null,
        dateReceived: _selectedDate.toString(),
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
        link: _linkController.text.isNotEmpty ? _linkController.text : null,
        id: '',
      );

      widget.onSave(award);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    String hearder =
        widget.initialAward == null ? 'Add award to ' : 'Edit award of ';
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
          AppTextButton(
            text: widget.initialAward == null ? 'Add' : 'Save',
            onPressed: _submit,
          ),
        ],
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Gap(Spacing.md.h),
                // Award Name (required)
                AppTextFormField(
                  debounceDuration: const Duration(milliseconds: 300),
                  onDebouncedChanged: (_) => _autoSave(),
                  controller: _nameController,
                  label: 'Award Name',
                  hintText: 'e.g., "Best Salon 2023"',
                  prefixIcon: Icons.emoji_events,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Award name is required';
                    }
                    return null;
                  },
                ),

                // Issuer (optional)
                AppTextFormField(
                  debounceDuration: const Duration(milliseconds: 300),
                  onDebouncedChanged: (_) => _autoSave(),
                  controller: _issuerController,
                  label: 'Issued By',
                  hintText: 'e.g., "City Guide Magazine"',
                  prefixIcon: Icons.business,
                ),

                // Link (optional)
                AppTextFormField(
                  debounceDuration: const Duration(milliseconds: 300),
                  onDebouncedChanged: (_) => _autoSave(),
                  controller: _linkController,
                  label: 'Verification Link',
                  hintText: 'https://...',
                  prefixIcon: Icons.link,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    if (!value.startsWith('http://') &&
                        !value.startsWith('https://')) {
                      return 'Must start with http:// or https://';
                    }
                    return null;
                  },
                ),

                // Description (optional)
                AppTextFormField(
                  debounceDuration: const Duration(milliseconds: 300),
                  onDebouncedChanged: (_) => _autoSave(),
                  controller: _descriptionController,
                  label: 'Description',
                  hintText: 'Additional details about the award...',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
              ],
            ),
          ),

          Gap(Spacing.lg.h),
          // AppDivider(),
          Gap(Spacing.sm.h),
          // Date Received (optional)
          _buildDatePicker(),

          Gap(Spacing.xl.h),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: InfoRowWidget(
        subtitle: '(optional)',
        title:
            _selectedDate != null
                ? MyDateFormat.toDate(_selectedDate!)
                : 'Select date received ',
        icon: Icons.calendar_month,
        iconSize: 20.h,
        // avatarRadius: 25.h,
        onTap: _selectDate,
        disableTrailing: false,
        showAvatar: false,
        showDivider: false,
        showTrailingArrow: false,
        trailing: AppIconButton(icon: Icons.add, onPressed: _selectDate),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? tempDate = _selectedDate ?? DateTime.now();
    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 320.h,
      context: context,
      widget: Column(
        children: [
          AppTextButton(text: 'Done'),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate ?? DateTime.now(),
              onDateTimeChanged: (DateTime newDate) {
                tempDate = newDate;
              },
            ),
          ),
        ],
      ),
    );

    setState(() {
      _selectedDate = tempDate;
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final award = AwardDTO(
        id: const Uuid().v4(),
        name: _nameController.text,
        issuer:
            _issuerController.text.isNotEmpty ? _issuerController.text : null,
        dateReceived: _selectedDate?.toIso8601String(),
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
        link: _linkController.text.isNotEmpty ? _linkController.text : null,
      );

      widget.onSave(award);
      Navigator.pop(context);
    }
  }
}
