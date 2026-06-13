import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

/// Wraps [PhoneFormField] with shop-context defaults.
///
/// [initialCountryIsoCode] — ISO 3166-1 alpha-2 e.g. 'GH', 'NG', 'US'.
/// [onChanged] — called with the E.164 string on every valid change,
///               or null when the field is invalid/incomplete.
class PhoneFieldWidget extends StatefulWidget {
  final String? initialCountryIsoCode;
  final String? initialValue; // existing E.164 value when editing
  final void Function(String? e164) onChanged;
  final PhoneController? controller;

  const PhoneFieldWidget({
    super.key,
    this.initialCountryIsoCode,
    this.initialValue,
    required this.onChanged,
    this.controller,
  });

  @override
  State<PhoneFieldWidget> createState() => _PhoneFieldWidgetState();
}

class _PhoneFieldWidgetState extends State<PhoneFieldWidget> {
  late final PhoneController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _ownsController = true;
      final isoCodeStr = widget.initialCountryIsoCode ?? 'GH';
      final country = IsoCode.values.firstWhere(
        (c) => c.name == isoCodeStr,
        orElse: () => IsoCode.GH,
      );
      PhoneNumber? initial;
      if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
        try {
          initial = PhoneNumber.parse(widget.initialValue!);
        } catch (_) {
          initial = PhoneNumber(isoCode: country, nsn: '');
        }
      }
      _controller = PhoneController(
        initialValue: initial ?? PhoneNumber(isoCode: country, nsn: ''),
      );
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFormField(
      controller: _controller,
      autofocus: false,
      autofillHints: const [AutofillHints.telephoneNumber],
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: '050 123 4567',
        border: OutlineInputBorder(),
      ),
      validator: PhoneValidator.compose([
        PhoneValidator.required(context),
        PhoneValidator.validMobile(context),
      ]),
      onChanged: (phone) {
        if (phone.isValid(type: PhoneNumberType.mobile)) {
          widget.onChanged(phone.international);
        } else {
          widget.onChanged(null);
        }
      },
    );
  }
}
