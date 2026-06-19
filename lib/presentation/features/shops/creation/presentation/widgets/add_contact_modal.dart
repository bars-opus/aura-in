// lib/features/shop/creation/presentation/widgets/add_contact_modal.dart

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/phone_field_widget.dart';
import 'package:nano_embryo/presentation/features/auth/providers/phone_verification_provider.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';

class AddContactModal extends ConsumerStatefulWidget {
  final Function(ContactDraft)? onSave;
  final ContactDraft? initialContact;
  final String? shopCountryIsoCode; // e.g. 'GH', auto-set from shop location
  final bool verifyMode;

  const AddContactModal({
    super.key,
    this.onSave,
    this.initialContact,
    this.shopCountryIsoCode,
    this.verifyMode = false,
  });

  @override
  ConsumerState<AddContactModal> createState() => _AddContactModalState();
}

class _AddContactModalState extends ConsumerState<AddContactModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valueController;
  ContactType? _selectedType;
  // Only used for the type-chip selection error — field errors are handled by Form.
  String? _typeError;
  String? _e164Phone; // holds validated E.164 for phone type
  bool _isPrimary = false;

  bool _codeSent = false;
  bool _busy = false;
  String? _verifyError;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isPrimary = widget.initialContact?.isPrimary ?? false;
    if (widget.initialContact != null) {
      _selectedType = widget.initialContact!.type;
      _e164Phone =
          widget.initialContact!.type == ContactType.phone
              ? widget.initialContact!.value
              : null;
      _valueController = TextEditingController(
        text:
            widget.initialContact!.type == ContactType.phone
                ? '' // PhoneFieldWidget owns its own controller
                : widget.initialContact!.value,
      );
    } else {
      _valueController = TextEditingController();
    }
    if (widget.verifyMode) {
      _selectedType = ContactType.phone;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _autoSave() {
    if (widget.initialContact != null && _selectedType != null) {
      final value = _valueController.text.trim();
      if (value.isNotEmpty) {
        final finalValue = _normaliseValue(value);
        final contact = ContactDraft(type: _selectedType!, value: finalValue);
        if (contact.validate() == null) {
          widget.onSave?.call(contact);
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
        return (value) =>
            ValidationUtils.validateUrl(
              _normaliseValue(value ?? ''),
              requireHttps: false,
            ).toErrorString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          if (!widget.verifyMode)
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
            Gap(Spacing.md.h),
            CardInkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.verifyMode) ...[
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
                  ],

                  if (widget.verifyMode) Gap(Spacing.md.h),

                  if (_selectedType == ContactType.phone)
                    PhoneFieldWidget(
                      initialCountryIsoCode: widget.shopCountryIsoCode,
                      initialValue:
                          widget.initialContact?.type == ContactType.phone
                              ? widget.initialContact!.value
                              : null,
                      onChanged: (e164) => setState(() => _e164Phone = e164),
                    )
                  else
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

                  if (!widget.verifyMode && widget.initialContact == null)
                    Row(
                      children: [
                        Checkbox(
                          value: _isPrimary,
                          onChanged:
                              (v) => setState(() => _isPrimary = v ?? false),
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

                  if (widget.verifyMode) ...[
                    Gap(Spacing.md.h),
                    if (_codeSent) ...[
                      AppTextFormField(
                        controller: _codeController,
                        label: 'Verification code',
                        hintText: '123456',
                        keyboardType: TextInputType.number,
                      ),
                      Gap(Spacing.sm.h),
                    ],
                    if (_verifyError != null) ...[
                      Text(
                        _verifyError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      Gap(Spacing.sm.h),
                    ],
                    AppButton(
                      label: _busy
                          ? 'Please wait...'
                          : (_codeSent ? 'Verify' : 'Send code'),
                      onPressed: _busy
                          ? null
                          : (_codeSent ? _verifyCode : _sendCode),
                      width: double.infinity,
                    ),
                  ],
                ],
              ),
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
      children:
          ContactType.values.map((type) {
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
              labelColor: colorScheme.onSurface.withValues(alpha: 0.7),
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

    if (_selectedType == ContactType.phone) {
      if (_e164Phone == null) {
        // PhoneFormField validator shows the inline error; nothing else to do.
        _formKey.currentState!.validate();
        return;
      }
      widget.onSave?.call(
        ContactDraft(
          id: widget.initialContact?.id,
          type: ContactType.phone,
          value: _e164Phone!,
          isPrimary: _isPrimary,
        ),
      );
      Navigator.pop(context);
      return;
    }

    // Form.validate() triggers every field's validator and shows inline errors.
    if (!_formKey.currentState!.validate()) return;

    final finalValue = _normaliseValue(_valueController.text.trim());
    widget.onSave?.call(
      ContactDraft(
        id: widget.initialContact?.id,
        type: _selectedType!,
        value: finalValue,
        isPrimary: _isPrimary,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _sendCode() async {
    if (_e164Phone == null) {
      setState(() => _verifyError = 'Enter a valid phone number');
      return;
    }
    setState(() {
      _busy = true;
      _verifyError = null;
    });
    try {
      await ref
          .read(phoneVerificationControllerProvider)
          .sendCode(_e164Phone!);
      setState(() => _codeSent = true);
    } catch (e) {
      setState(() => _verifyError = 'Could not send code. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _verifyError = 'Enter the code');
      return;
    }
    setState(() {
      _busy = true;
      _verifyError = null;
    });
    try {
      final ok = await ref
          .read(phoneVerificationControllerProvider)
          .verifyCode(_e164Phone!, code);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      } else {
        setState(() => _verifyError = 'Incorrect or expired code');
      }
    } catch (e) {
      setState(() => _verifyError = 'Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
