import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_form_field/phone_form_field.dart';

/// Two-box phone input: [🇬🇭 +233 ▾] [050 123 4567]
///
/// [initialCountryIsoCode] — ISO 3166-1 alpha-2 e.g. 'GH', 'NG', 'US'.
/// [onChanged] — called with the E.164 string on every valid change,
///               or null when the field is invalid/incomplete.
class PhoneFieldWidget extends StatefulWidget {
  final String? initialCountryIsoCode;
  final String? initialValue;
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

  Future<void> _openCountryPicker() async {
    final selected = await const CountrySelectorNavigator.bottomSheet().show(
      context,
    );
    if (selected != null && mounted) {
      _controller.changeCountry(selected);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(12);
    final borderColor = colorScheme.outline.withValues(alpha: 0.5);

    OutlineInputBorder border(Color color, {double width = 1.0}) =>
        OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: color, width: width),
        );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isoCode = _controller.value.isoCode;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Country chip ──────────────────────────────────────
            GestureDetector(
              onTap: _openCountryPicker,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: borderRadius,
                  color: colorScheme.surface,
                ),
                child: CountryButton(
                  isoCode: isoCode,
                  onTap: _openCountryPicker,
                  flagSize: 22,
                  showFlag: true,
                  showDialCode: true,
                  showDropdownIcon: true,
                  showIsoCode: false,
                  dropdownIconColor: colorScheme.onSurfaceVariant,
                  textStyle: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ── Number field ──────────────────────────────────────
            Expanded(
              child: PhoneFormField(
                controller: _controller,
                autofocus: false,
                autofillHints: const [AutofillHints.telephoneNumber],
                keyboardType: TextInputType.phone,
                isCountryButtonPersistent: false,
                countryButtonStyle: const CountryButtonStyle(
                  showFlag: false,
                  showDialCode: false,
                  showDropdownIcon: false,
                  padding: EdgeInsets.zero,
                ),
                decoration: InputDecoration(
                  hintText: '50 123 4567',
                  contentPadding:  EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 16.h,
                  ),
                  border: border(borderColor),
                  enabledBorder: border(borderColor),
                  focusedBorder: border(colorScheme.primary, width: 1.5),
                  errorBorder: border(colorScheme.error),
                  focusedErrorBorder: border(colorScheme.error, width: 1.5),
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
              ),
            ),
          ],
        );
      },
    );
  }
}
