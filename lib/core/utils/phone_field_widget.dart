import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
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

  bool _pickerOpen = false;

  Future<void> _openCountryPicker() async {
    // Guard against re-entrancy: the GestureDetector and the inner CountryButton
    // can both fire, and a second show() while the first sheet is mid-pop trips
    // Navigator's '!_debugLocked' assertion.
    if (_pickerOpen) return;
    _pickerOpen = true;
    try {
      // Use modalBottomSheet (NOT bottomSheet): the plain `.bottomSheet()`
      // uses Scaffold's showBottomSheet, which pushes no route — its
      // `Navigator.pop(context, country)` then pops the ENCLOSING modal route
      // (our showDocumentationBottomSheet<bool>), forcing an IsoCode through a
      // bool? result → "'IsoCode' is not a subtype of bool?". modalBottomSheet
      // pushes its own showModalBottomSheet<IsoCode> route, so its pop targets
      // itself.
      final selected =
          await const CountrySelectorNavigator.modalBottomSheet().show(
        context,
      );
      if (selected != null && mounted) {
        // Defer the controller mutation out of the sheet's pop frame so it never
        // runs while the Navigator is locked.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller.changeCountry(selected);
            setState(() {});
          }
        });
      }
    } finally {
      _pickerOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              // Tap is owned by the inner CountryButton; the re-entrancy guard
              // in _openCountryPicker is the real protection. Keep this as a
              // plain wrapper (no onTap) so the picker can't fire twice.
              child: Container(
                height: 45.h,
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: '50 123 4567',
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 12.sp,
                  ),
                  border: border(borderColor),
                  enabledBorder: border(borderColor),
                  focusedBorder: border(colorScheme.primary, width: 1.5),
                  errorBorder: border(colorScheme.error),
                  focusedErrorBorder: border(colorScheme.error, width: 1.5),
                ),
                validator: PhoneValidator.compose([
                  PhoneValidator.required(context),
                  // valid (not validMobile): NANP numbers are fixedOrMobile and
                  // fail a strict mobile check. See onChanged note below.
                  PhoneValidator.valid(context),
                ]),
                onChanged: (phone) {
                  // General validity, NOT type: mobile. NANP (US/CA) numbers are
                  // classified fixedOrMobile by libphonenumber, so a strict
                  // mobile check rejects valid US numbers. Twilio handles
                  // deliverability; we only need a well-formed E.164.
                  if (phone.isValid()) {
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
