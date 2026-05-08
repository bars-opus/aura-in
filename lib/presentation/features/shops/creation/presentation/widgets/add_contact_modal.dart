// lib/features/shop/creation/presentation/widgets/add_contact_modal.dart

import 'package:flutter/services.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';

class AddContactModal extends StatefulWidget {
  final Function(ContactDraft) onSave;
  final ContactDraft? initialContact;

  const AddContactModal({super.key, required this.onSave, this.initialContact});

  @override
  State<AddContactModal> createState() => _AddContactModalState();
}

class _AddContactModalState extends State<AddContactModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valueController;
  ContactType? _selectedType;
  // Only used for the type-chip selection error — field errors are handled by Form.
  String? _typeError;

  @override
  void initState() {
    super.initState();
    if (widget.initialContact != null) {
      _selectedType = widget.initialContact!.type;
      _valueController = TextEditingController(
        text: widget.initialContact!.value,
      );
    } else {
      _valueController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _autoSave() {
    if (widget.initialContact != null && _selectedType != null) {
      final value = _valueController.text.trim();
      if (value.isNotEmpty) {
        final finalValue = _normaliseValue(value);
        final contact = ContactDraft(type: _selectedType!, value: finalValue);
        if (contact.validate() == null) {
          widget.onSave(contact);
        }
      }
    }
  }

  /// Prepend https:// to bare website values before saving/validating.
  String _normaliseValue(String value) {
    if (_selectedType == ContactType.website &&
        !value.startsWith('http://') &&
        !value.startsWith('https://')) {
      return 'https://$value';
    }
    return value;
  }

  /// Returns the correct validator for the currently selected contact type.
  /// Each validator calls the corresponding ValidationUtils method and converts
  /// the result to a String? via .toErrorString() — the shape Flutter's Form expects.
  String? Function(String?)? _getValidator() {
    if (_selectedType == null) return null;
    switch (_selectedType!) {
      case ContactType.phone:
        return (value) =>
            ValidationUtils.validatePhoneNumber(value).toErrorString();
      case ContactType.email:
        return (value) => ValidationUtils.validateEmail(value).toErrorString();
      case ContactType.website:
        return (value) => ValidationUtils.validateUrl(
          _normaliseValue(value ?? ''),
          requireHttps: false,
        ).toErrorString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final header =
        widget.initialContact == null ? 'Add contact to ' : 'Edit contact of ';

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
            text: widget.initialContact == null ? 'Add' : 'Save',
            onPressed: _submit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Gap(Spacing.lg.h),
            SemanticContainerWidget(
              content:
                  '${header}your social profiles to help customers find you',
              title: '',
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              borderColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              textTheme: theme.textTheme,
            ),
            Gap(Spacing.lg.h),
            Gap(Spacing.md.h),

            Text(
              'Contact Type',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Gap(Spacing.sm.h),
            _buildTypeSelector(),

            if (_typeError != null) ...[
              Gap(Spacing.xs.h),
              Text(
                _typeError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],

            Gap(Spacing.md.h),

            AppTextFormField(
              debounceDuration: const Duration(milliseconds: 300),
              onDebouncedChanged: (_) => _autoSave(),
              controller: _valueController,
              label: _getLabel(),
              hintText: _getHint(),
              prefixIcon: _selectedType?.icon,
              keyboardType: _getKeyboardType(),
              inputFormatters: _getInputFormatters(),
              // Validator is wired to ValidationUtils — Form.validate() triggers it.
              validator: _getValidator(),
            ),

            Gap(Spacing.md.h),

            if (widget.initialContact == null)
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (_) {},
                  ),
                  Expanded(
                    child: Text(
                      'Set as primary contact',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

            Gap(Spacing.lg.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: ContactType.values.map((type) {
        final isSelected = _selectedType == type;
        return AppFilterChip(
          avatarIcon: type.icon,
          label: type.displayName,
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedType = selected ? type : null;
              _valueController.clear();
              _typeError = null;
            });
          },
          selectedColor: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          labelColor: colorScheme.onSurface.withValues(alpha: 0.3),
          borderWidth: 0.3,
        );
      }).toList(),
    );
  }

  String _getLabel() {
    if (_selectedType == null) return 'Select type first';
    switch (_selectedType!) {
      case ContactType.phone:
        return 'Phone Number';
      case ContactType.email:
        return 'Email Address';
      case ContactType.website:
        return 'Website URL';
    }
  }

  String _getHint() {
    if (_selectedType == null) return '';
    switch (_selectedType!) {
      case ContactType.phone:
        return '+1 234 567 8900';
      case ContactType.email:
        return 'hello@example.com';
      case ContactType.website:
        return 'www.example.com';
    }
  }

  TextInputType _getKeyboardType() {
    if (_selectedType == null) return TextInputType.text;
    switch (_selectedType!) {
      case ContactType.phone:
        return TextInputType.phone;
      case ContactType.email:
        return TextInputType.emailAddress;
      case ContactType.website:
        return TextInputType.url;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (_selectedType) {
      case ContactType.phone:
        return [
          ValidationUtils.phoneFormatter,
          ValidationUtils.lengthLimitingFormatter(20),
        ];
      case ContactType.email:
        return [
          ValidationUtils.emailFormatter,
          ValidationUtils.lengthLimitingFormatter(254),
        ];
      case ContactType.website:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ValidationUtils.lengthLimitingFormatter(2083),
        ];
      case null:
        return [];
    }
  }

  void _submit() {
    // Type selection is not a Form field, so check it manually first.
    if (_selectedType == null) {
      setState(() => _typeError = 'Please select a contact type');
      return;
    }

    // Form.validate() triggers every field's validator and shows inline errors.
    if (!_formKey.currentState!.validate()) return;

    final finalValue = _normaliseValue(_valueController.text.trim());
    widget.onSave(ContactDraft(type: _selectedType!, value: finalValue));
    Navigator.pop(context);
  }
}
