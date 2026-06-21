# Shop Creation UX Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the shop creation flow to Fresha/Booksy parity across six areas: phone input (country picker), service form (buffer time + currency symbol + days shortcut), service sub-types (hybrid predefined+freetext per shop type), service templates (Supabase-backed per shop type), document picker (file_picker replacing image picker), and date/time pickers (all → CupertinoDatePicker/CupertinoTimerPicker).

**Architecture:** Each improvement is isolated to its own widget/provider so regressions are contained. The service-templates feature requires one new Supabase table (`service_templates`) seeded via SQL migration. Phone input adds `phone_form_field` package and stores E.164 in the existing `ContactDraft.value` field — no schema change. Document picker swaps `image_picker` for `file_picker` in `DocumentPickerSheet` only. All Material `showDatePicker`/`showTimePicker` calls are replaced with a shared `CupertinoDateTimePickerSheet` bottom-sheet helper.

**Tech Stack:** Flutter 3.x / Dart 3.7, Riverpod 2.x, Supabase, `phone_form_field: ^10.0.17` (new), `file_picker: ^6.1.1` (already in pubspec), `flutter/cupertino.dart` (already imported in several files)

---

## File Map

| Status | File | What changes |
|--------|------|-------------|
| **New** | `lib/core/utils/cupertino_date_picker_sheet.dart` | Shared helper that wraps CupertinoDatePicker + CupertinoTimerPicker in a bottom-sheet. All date/time pickers call this. |
| **New** | `lib/presentation/features/shops/creation/data/service_templates_repository.dart` | Fetches `service_templates` rows from Supabase filtered by shop type. |
| **New** | `lib/presentation/features/shops/creation/providers/service_templates_provider.dart` | `FutureProvider<List<ServiceTemplateDTO>>` keyed by shop type. |
| **New** | `lib/presentation/features/shops/creation/domain/models/service_template_dto.dart` | Immutable DTO for a template row. |
| **New** | `lib/presentation/features/shops/creation/presentation/widgets/service_templates_sheet.dart` | Bottom-sheet that shows templates for the shop type; tapping one pre-fills `ServiceFormModal`. |
| **New** | `lib/core/utils/phone_field_widget.dart` | Thin wrapper around `PhoneFormField` that auto-sets country from shop's `currencyCode`/location and exposes E.164 via callback. |
| **Modify** | `lib/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart` | Replace plain text field for `ContactType.phone` with `PhoneFieldWidget`. Wire primary-contact checkbox. |
| **Modify** | `lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart` | Add buffer-time stepper, currency-symbol prefix on price, "Select all open days" chip, service sub-type hybrid picker. |
| **Modify** | `lib/presentation/features/shops/creation/presentation/screens/manage_services_screen.dart` | Add FAB "Use a template" button that opens `ServiceTemplatesSheet`. |
| **Modify** | `lib/presentation/features/shops/creation/presentation/widgets/document_picker_sheet.dart` | Replace `imagePickerServiceProvider` with `FilePicker.platform.pickFiles`. |
| **Modify** | `lib/presentation/features/shops/dashboard/presentation/screens/pricing_override_form_screen.dart` | Replace 2× `showDatePicker` + 2× `showTimePicker` with `CupertinoDatePickerSheet`. |
| **Modify** | `lib/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart` | Replace `showDatePicker` with `CupertinoDatePickerSheet`. |
| **Modify** | `lib/presentation/features/shops/creation/presentation/widgets/add_unavailability_modal.dart` | Replace `showDatePicker` + `showTimePicker` with `CupertinoDatePickerSheet`. |
| **Modify** | `lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart` | Replace `showTimePicker` with `CupertinoDatePickerSheet` (time-only mode). |
| **SQL** | `supabase/migrations/20260613_service_templates.sql` | Creates `service_templates` table + seeds 40+ rows across 4 shop types. |

---

## Task 1: Shared CupertinoDatePickerSheet helper

**Files:**
- Create: `lib/core/utils/cupertino_date_picker_sheet.dart`

- [ ] **Step 1: Create the helper**

```dart
// lib/core/utils/cupertino_date_picker_sheet.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';

/// Shows a Cupertino date picker inside a bottom-sheet.
/// Returns the chosen [DateTime] or null if dismissed.
Future<DateTime?> showCupertinoDatePickerSheet({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
  double sheetHeight = 320,
}) async {
  final completer = Completer<DateTime?>();
  DateTime selected = initialDate;

  await BottomSheetUtils.showDocumentationBottomSheet(
    context: context,
    maxHeight: sheetHeight.h,
    showButtons: false,
    widget: Builder(builder: (ctx) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppTextButton(
                  text: 'Cancel',
                  onPressed: () {
                    Navigator.pop(ctx);
                    completer.complete(null);
                  },
                ),
                AppTextButton(
                  text: 'Done',
                  onPressed: () {
                    Navigator.pop(ctx);
                    completer.complete(selected);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: CupertinoDatePicker(
              mode: mode,
              initialDateTime: initialDate,
              minimumDate: minimumDate,
              maximumDate: maximumDate,
              onDateTimeChanged: (dt) => selected = dt,
            ),
          ),
        ],
      );
    }),
  );

  return completer.future;
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/core/utils/cupertino_date_picker_sheet.dart --no-fatal-infos 2>&1 | grep error
```
Expected: no output (no errors).

- [ ] **Step 3: Commit**

```bash
git add lib/core/utils/cupertino_date_picker_sheet.dart
git commit -m "feat(ux): add shared CupertinoDatePickerSheet helper"
```

---

## Task 2: Replace all Material date pickers → Cupertino (4 files)

**Files:**
- Modify: `lib/presentation/features/shops/dashboard/presentation/screens/pricing_override_form_screen.dart:157-183`
- Modify: `lib/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart:179-198`
- Modify: `lib/presentation/features/shops/creation/presentation/widgets/add_unavailability_modal.dart:174-212`
- Modify: `lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart:148-162`

- [ ] **Step 1: Fix `pricing_override_form_screen.dart` — add import, replace `_pickValidFrom` and `_pickValidUntil`**

Add import at top of file:
```dart
import 'package:nano_embryo/core/utils/cupertino_date_picker_sheet.dart';
```

Replace the two methods (lines ~157-183):
```dart
Future<void> _pickValidFrom() async {
  final now = DateTime.now();
  final picked = await showCupertinoDatePickerSheet(
    context: context,
    initialDate: _validFrom ?? now,
    minimumDate: now.subtract(const Duration(days: 365)),
    maximumDate: now.add(const Duration(days: 365 * 5)),
  );
  if (picked != null) setState(() { _validFrom = picked; _dirty = true; });
}

Future<void> _pickValidUntil() async {
  final now = DateTime.now();
  final picked = await showCupertinoDatePickerSheet(
    context: context,
    initialDate: _validUntil ?? now.add(const Duration(days: 30)),
    minimumDate: _validFrom ?? now.subtract(const Duration(days: 365)),
    maximumDate: now.add(const Duration(days: 365 * 5)),
  );
  if (picked != null) setState(() { _validUntil = picked; _dirty = true; });
}
```

Also replace `_pickStart` and `_pickEnd` (lines ~141-155) which use `showTimePicker`:
```dart
Future<void> _pickStart() async {
  final now = DateTime.now();
  final initial = DateTime(now.year, now.month, now.day, _start.hour, _start.minute);
  final picked = await showCupertinoDatePickerSheet(
    context: context,
    initialDate: initial,
    mode: CupertinoDatePickerMode.time,
    sheetHeight: 260,
  );
  if (picked != null) setState(() { _start = TimeOfDay.fromDateTime(picked); _dirty = true; });
}

Future<void> _pickEnd() async {
  final now = DateTime.now();
  final initial = DateTime(now.year, now.month, now.day, _end.hour, _end.minute);
  final picked = await showCupertinoDatePickerSheet(
    context: context,
    initialDate: initial,
    mode: CupertinoDatePickerMode.time,
    sheetHeight: 260,
  );
  if (picked != null) setState(() { _end = TimeOfDay.fromDateTime(picked); _dirty = true; });
}
```

Remove `import 'package:flutter/material.dart'` if it was only needed for `showDatePicker`/`showTimePicker` — but keep it if the file uses Material widgets (it does, so keep it).

- [ ] **Step 2: Fix `create_promotion_screen.dart` — replace `_selectDate`**

Add import:
```dart
import 'package:nano_embryo/core/utils/cupertino_date_picker_sheet.dart';
```

Replace `_selectDate` (lines ~179-198):
```dart
Future<void> _selectDate(BuildContext context, bool isStartDate) async {
  final picked = await showCupertinoDatePickerSheet(
    context: context,
    initialDate: isStartDate ? _validFrom : _validTo,
    minimumDate: DateTime.now(),
    maximumDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (picked != null) {
    setState(() {
      if (isStartDate) {
        _validFrom = picked;
        if (_validTo.isBefore(_validFrom)) {
          _validTo = _validFrom.add(const Duration(days: 30));
        }
      } else {
        _validTo = picked;
      }
    });
  }
}
```

- [ ] **Step 3: Fix `add_unavailability_modal.dart` — replace `_buildDateTimePicker`**

Add import:
```dart
import 'package:nano_embryo/core/utils/cupertino_date_picker_sheet.dart';
```

Replace the `_buildDateTimePicker` body:
```dart
Widget _buildDateTimePicker({
  required DateTime value,
  required Function(DateTime) onChanged,
}) {
  return GestureDetector(
    onTap: () async {
      if (_isAllDay) {
        final picked = await showCupertinoDatePickerSheet(
          context: context,
          initialDate: value,
          minimumDate: DateTime.now(),
          maximumDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      } else {
        final datePicked = await showCupertinoDatePickerSheet(
          context: context,
          initialDate: value,
          minimumDate: DateTime.now(),
          maximumDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (datePicked == null) return;
        final timePicked = await showCupertinoDatePickerSheet(
          context: context,
          initialDate: value,
          mode: CupertinoDatePickerMode.time,
          sheetHeight: 260,
        );
        final time = timePicked ?? value;
        onChanged(DateTime(
          datePicked.year, datePicked.month, datePicked.day,
          time.hour, time.minute,
        ));
      }
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w, vertical: Spacing.sm.h),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 20.sp),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              _formatDateTime(value),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 4: Fix `business_hours_screen.dart` — replace `_pickTime`**

Add import:
```dart
import 'package:nano_embryo/core/utils/cupertino_date_picker_sheet.dart';
```

Replace `_pickTime` (lines ~148-162). Current signature: `Future<void> _pickTime(BuildContext context, {required bool isOpen})`. Read the existing method to capture the state fields it modifies, then replace:
```dart
Future<void> _pickTime(BuildContext context, {required bool isOpen}) async {
  final now = DateTime.now();
  // Read current HH:mm string from state (existing field name from the file)
  final existing = isOpen ? _opensAt : _closesAt; // adjust field names to match
  final parts = existing.split(':');
  final initial = DateTime(now.year, now.month, now.day,
    int.tryParse(parts.firstOrNull ?? '9') ?? 9,
    int.tryParse(parts.skip(1).firstOrNull ?? '0') ?? 0,
  );
  final picked = await showCupertinoDatePickerSheet(
    context: context,
    initialDate: initial,
    mode: CupertinoDatePickerMode.time,
    sheetHeight: 260,
  );
  if (picked == null || !mounted) return;
  final formatted = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}';
  // NOTE: Read `business_hours_screen.dart` fully to confirm the exact setState
  // call and field names before applying this step.
}
```
> ⚠️ **Read `business_hours_screen.dart` lines 140–170 before applying this step** to confirm exact field names (`_opensAt`/`_closesAt` or similar) and the `setState` body.

- [ ] **Step 5: Verify all 4 files compile**

```bash
flutter analyze \
  lib/presentation/features/shops/dashboard/presentation/screens/pricing_override_form_screen.dart \
  lib/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart \
  lib/presentation/features/shops/creation/presentation/widgets/add_unavailability_modal.dart \
  lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart \
  --no-fatal-infos 2>&1 | grep "error"
```
Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add \
  lib/presentation/features/shops/dashboard/presentation/screens/pricing_override_form_screen.dart \
  lib/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart \
  lib/presentation/features/shops/creation/presentation/widgets/add_unavailability_modal.dart \
  lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart
git commit -m "feat(ux): replace all Material date/time pickers with CupertinoDatePickerSheet"
```

---

## Task 3: Phone field with country picker in AddContactModal

**Files:**
- Create: `lib/core/utils/phone_field_widget.dart`
- Modify: `lib/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart`
- Modify: `pubspec.yaml` (add `phone_form_field: ^10.0.17`)

- [ ] **Step 1: Add `phone_form_field` to pubspec.yaml**

In `pubspec.yaml`, under `dependencies:`, after `uuid: ^3.0.7`, add:
```yaml
  phone_form_field: ^10.0.17
```

Run:
```bash
flutter pub get 2>&1 | tail -5
```
Expected: `Got dependencies!`

- [ ] **Step 2: Create `PhoneFieldWidget`**

```dart
// lib/core/utils/phone_field_widget.dart
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

/// Wraps PhoneFormField with shop-context defaults.
/// [initialCountryIsoCode] — ISO 3166-1 alpha-2 e.g. 'GH', 'NG', 'US'.
/// [onChanged] — called with the E.164 string on every valid change,
///               or null when the field is invalid/incomplete.
/// [validator] — optional additional Form validator (runs after built-in).
class PhoneFieldWidget extends StatefulWidget {
  final String? initialCountryIsoCode;
  final String? initialValue; // existing E.164 value when editing
  final void Function(String? e164) onChanged;
  final String? Function(PhoneNumber?)? validator;
  final PhoneController? controller;

  const PhoneFieldWidget({
    super.key,
    this.initialCountryIsoCode,
    this.initialValue,
    required this.onChanged,
    this.validator,
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
      final country = IsoCode.values.firstWhere(
        (c) => c.name == (widget.initialCountryIsoCode ?? 'GH'),
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
      validator: widget.validator ??
          PhoneValidator.compose([
            PhoneValidator.required(context, errorText: 'Phone number required'),
            PhoneValidator.validMobile(context, errorText: 'Enter a valid mobile number'),
          ]),
      onChanged: (phone) {
        if (phone != null && phone.isValid(type: PhoneNumberType.mobile)) {
          widget.onChanged(phone.international); // E.164
        } else {
          widget.onChanged(null);
        }
      },
    );
  }
}
```

- [ ] **Step 3: Verify PhoneFieldWidget compiles**

```bash
flutter analyze lib/core/utils/phone_field_widget.dart --no-fatal-infos 2>&1 | grep error
```
Expected: no output.

- [ ] **Step 4: Update `AddContactModal` to use `PhoneFieldWidget` for phone type, and wire the primary-contact checkbox**

Replace `add_contact_modal.dart` body. Key changes:
1. Add `String? _e164Phone` field to state.
2. When `_selectedType == ContactType.phone`, render `PhoneFieldWidget` instead of `AppTextFormField`.
3. Auto-set `initialCountryIsoCode` from the shop draft's country (if available) — we pass it as a constructor parameter.
4. Wire primary-contact checkbox: replace hardcoded `value: false` with a `bool _isPrimary` state field.

Updated constructor add parameter:
```dart
class AddContactModal extends StatefulWidget {
  final Function(ContactDraft) onSave;
  final ContactDraft? initialContact;
  final String? shopCountryIsoCode; // e.g. 'GH', auto-set from location

  const AddContactModal({
    super.key,
    required this.onSave,
    this.initialContact,
    this.shopCountryIsoCode,
  });
  ...
}
```

Updated state fields:
```dart
class _AddContactModalState extends State<AddContactModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valueController;
  ContactType? _selectedType;
  String? _typeError;
  String? _e164Phone; // holds validated E.164 for phone type
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _isPrimary = widget.initialContact?.isPrimary ?? false;
    if (widget.initialContact != null) {
      _selectedType = widget.initialContact!.type;
      _e164Phone = widget.initialContact!.type == ContactType.phone
          ? widget.initialContact!.value
          : null;
      _valueController = TextEditingController(
        text: widget.initialContact!.type == ContactType.phone
            ? '' // PhoneFieldWidget owns its own controller
            : widget.initialContact!.value,
      );
    } else {
      _valueController = TextEditingController();
    }
  }
  ...
}
```

Replace the `AppTextFormField` section in `build()` with:
```dart
if (_selectedType == ContactType.phone)
  PhoneFieldWidget(
    initialCountryIsoCode: widget.shopCountryIsoCode,
    initialValue: widget.initialContact?.type == ContactType.phone
        ? widget.initialContact!.value
        : null,
    onChanged: (e164) => setState(() => _e164Phone = e164),
    validator: (phone) {
      if (phone == null || !phone.isValid()) return 'Enter a valid phone number';
      return null;
    },
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
    validator: _getValidator(),
  ),
```

Wire the primary checkbox:
```dart
if (widget.initialContact == null)
  Row(
    children: [
      Checkbox(
        value: _isPrimary,
        onChanged: (v) => setState(() => _isPrimary = v ?? false),
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
```

Update `_submit()` to use `_e164Phone` for phone type:
```dart
void _submit() {
  if (_selectedType == null) {
    setState(() => _typeError = 'Please select a contact type');
    return;
  }
  if (!_formKey.currentState!.validate()) return;

  final String finalValue;
  if (_selectedType == ContactType.phone) {
    if (_e164Phone == null) {
      // PhoneFormField validator will have shown the error; do nothing.
      return;
    }
    finalValue = _e164Phone!;
  } else {
    finalValue = _normaliseValue(_valueController.text.trim());
  }

  widget.onSave(ContactDraft(
    id: widget.initialContact?.id,
    type: _selectedType!,
    value: finalValue,
    isPrimary: _isPrimary,
  ));
  Navigator.pop(context);
}
```

- [ ] **Step 5: Update call sites of `AddContactModal` to pass `shopCountryIsoCode`**

In `lib/presentation/features/shops/creation/presentation/screens/manage_contacts_screen.dart`, find where `AddContactModal` is instantiated and add:
```dart
shopCountryIsoCode: ref.read(shopCreationProvider).country != null
    ? _isoCodeFromCountryName(ref.read(shopCreationProvider).country!)
    : null,
```

Add helper in the screen:
```dart
String? _isoCodeFromCountryName(String name) {
  const m = {
    'Ghana': 'GH', 'Nigeria': 'NG', 'United Kingdom': 'GB',
    'United States': 'US', 'South Africa': 'ZA', 'Kenya': 'KE',
  };
  return m[name];
}
```

Alternatively: the shop draft stores `currencyCode`. Map `GHS→GH`, `NGN→NG`, `GBP→GB`, `USD→US`, `ZAR→ZA`:
```dart
String? _isoCodeFromCurrencyCode(String? code) {
  const m = {'GHS':'GH','NGN':'NG','GBP':'GB','USD':'US','ZAR':'ZA','KES':'KE','EUR':null};
  return code == null ? null : m[code];
}
```
Pass via:
```dart
shopCountryIsoCode: _isoCodeFromCurrencyCode(ref.read(shopCreationProvider).currencyCode),
```

- [ ] **Step 6: Verify**

```bash
flutter analyze \
  lib/core/utils/phone_field_widget.dart \
  lib/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart \
  --no-fatal-infos 2>&1 | grep error
```
Expected: no output.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock \
  lib/core/utils/phone_field_widget.dart \
  lib/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart \
  lib/presentation/features/shops/creation/presentation/screens/manage_contacts_screen.dart
git commit -m "feat(contacts): replace phone text field with country picker (phone_form_field), wire primary checkbox"
```

---

## Task 4: Service form — buffer time, currency prefix, "select all days" chip

**Files:**
- Modify: `lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart`

- [ ] **Step 1: Add `_bufferMinutes` state field (already in DTO, just not editable)**

In `_ServiceFormModalState`, add:
```dart
late int _bufferMinutes;
```

In `initState()`, after `_maxClients = ...`:
```dart
_bufferMinutes = widget.initialService?.bufferMinutes ?? 0;
```

- [ ] **Step 2: Add currency symbol prefix to price field**

`ServiceFormModal` receives the shop draft's currency via the `manage_services_screen.dart` call site. Pass it as a constructor parameter:

```dart
class ServiceFormModal extends ConsumerStatefulWidget {
  ...
  final String? currencySymbol; // new — e.g. 'GH₵', '₦', '$'
  const ServiceFormModal({
    ...
    this.currencySymbol,
  });
}
```

In the price `AppTextFormField`, change:
```dart
prefixIcon: Icons.attach_money,
```
to:
```dart
prefix: currencySymbol != null
    ? Padding(
        padding: EdgeInsets.only(right: 4.w),
        child: Text(
          widget.currencySymbol!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      )
    : null,
prefixIcon: currencySymbol == null ? Icons.attach_money : null,
```

- [ ] **Step 3: Add "Select all open days" chip above the day checklist**

In `_buildDaySelector`, after the title `Text('Available Days', ...)` and `Gap(...)`:
```dart
// Select-all chip
Wrap(
  spacing: 8.w,
  children: [
    ActionChip(
      label: const Text('Select all open days'),
      avatar: const Icon(Icons.select_all, size: 16),
      onPressed: () {
        final allOpen = _shopHours
            .where((h) => !h.isClosed)
            .map((h) => h.dayOfWeek)
            .toList();
        ref.read(_selectedDaysProvider.notifier).state = allOpen;
      },
    ),
    if (selectedDays.isNotEmpty)
      ActionChip(
        label: const Text('Clear'),
        avatar: const Icon(Icons.clear, size: 16),
        onPressed: () {
          ref.read(_selectedDaysProvider.notifier).state = [];
        },
      ),
  ],
),
Gap(Spacing.sm.h),
```

- [ ] **Step 4: Add buffer time stepper below max-clients dropdown**

Add a new `_buildBufferStepper` widget method:
```dart
Widget _buildBufferStepper(ThemeData theme) {
  const options = [0, 5, 10, 15, 30];
  return Row(
    children: [
      Icon(Icons.timer_outlined, size: 20.sp, color: theme.colorScheme.onSurface.withOpacity(0.6)),
      SizedBox(width: Spacing.sm.w),
      Expanded(
        child: Text('Buffer time after service', style: theme.textTheme.bodyMedium),
      ),
      DropdownButton<int>(
        value: options.contains(_bufferMinutes) ? _bufferMinutes : 0,
        underline: const SizedBox(),
        items: options.map((m) => DropdownMenuItem(
          value: m,
          child: Text(m == 0 ? 'None' : '$m min'),
        )).toList(),
        onChanged: (v) => setState(() => _bufferMinutes = v ?? 0),
      ),
    ],
  );
}
```

In the `build` body, inside the second `CardInkWell`, after `_buildWorkerToggle`:
```dart
Gap(Spacing.md.h),
_buildBufferStepper(theme),
```

- [ ] **Step 5: Update `_submitAndClose` to use `_bufferMinutes`**

Change:
```dart
bufferMinutes: widget.initialService?.bufferMinutes ?? 0,
```
to:
```dart
bufferMinutes: _bufferMinutes,
```

- [ ] **Step 6: Update call site in `manage_services_screen.dart` to pass `currencySymbol`**

Find where `ServiceFormModal` is constructed (two call sites — data branch and loading/error branch). In each, add:
```dart
currencySymbol: ref.read(shopCreationProvider).currencySymbol,
```

- [ ] **Step 7: Verify**

```bash
flutter analyze \
  lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart \
  lib/presentation/features/shops/creation/presentation/screens/manage_services_screen.dart \
  --no-fatal-infos 2>&1 | grep error
```
Expected: no output.

- [ ] **Step 8: Commit**

```bash
git add \
  lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart \
  lib/presentation/features/shops/creation/presentation/screens/manage_services_screen.dart
git commit -m "feat(services): add buffer-time picker, currency symbol, select-all-days chip to service form"
```

---

## Task 5: Service sub-type — hybrid predefined+freetext per shop type

**Files:**
- Modify: `lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart`

The "Service Type" free-text field becomes a **hybrid picker**: predefined chips for the shop's type, plus a "Custom…" option that reveals a text field.

- [ ] **Step 1: Add sub-type map constant and state field**

At the top of `service_form_modal.dart`, before the class, add:
```dart
/// Predefined service sub-types per shop type. Keys match ShopDraft.shopType values.
const _kServiceSubTypes = {
  'Salon': [
    'Haircut', 'Hair Colour', 'Highlights', 'Blowout', 'Brazilian Blowout',
    'Box Braids', 'Cornrows', 'Senegalese Twist', 'Locs', 'Afro',
    'Weave', 'Wig Install', 'Natural Styling', 'Relaxer', 'Keratin',
  ],
  'Barbershop': [
    'Fade', 'Low Fade', 'High Fade', 'Skin Fade', 'Taper',
    'Lineup', 'Shape-Up', 'Beard Trim', 'Hot Towel Shave', 'Edge-Up',
    'Kids Cut', 'Bald Cut', 'Design Cut', 'Afro Trim',
  ],
  'Spa': [
    'Swedish Massage', 'Deep Tissue', 'Hot Stone', 'Aromatherapy',
    'Facial', 'Hydrafacial', 'Body Wrap', 'Scrub', 'Waxing',
    'Eyebrow Threading', 'Eyelash Extensions', 'Foot Massage',
  ],
  'Nail Salon': [
    'Manicure', 'Pedicure', 'Gel Nails', 'Acrylic Nails', 'Nail Art',
    'Nail Repair', 'Dip Powder', 'French Tips', 'Ombre Nails', 'Chrome Nails',
  ],
};
```

Add to `_ServiceFormModalState`:
```dart
bool _useCustomSubType = false;
late TextEditingController _customSubTypeController;
```

In `initState()`, after `_typeController`:
```dart
_customSubTypeController = TextEditingController();
// If the initialService has a type that doesn't match any predefined list entry,
// mark it as custom.
final predefined = _getPredefinedSubTypes();
if (widget.initialService?.serviceType != null &&
    !predefined.contains(widget.initialService!.serviceType)) {
  _useCustomSubType = true;
  _customSubTypeController.text = widget.initialService!.serviceType!;
}
```

In `dispose()`:
```dart
_customSubTypeController.dispose();
```

- [ ] **Step 2: Add `shopType` parameter to `ServiceFormModal`**

```dart
class ServiceFormModal extends ConsumerStatefulWidget {
  ...
  final String? shopType; // e.g. 'Salon', 'Barbershop'
  const ServiceFormModal({..., this.shopType});
}
```

Helper method:
```dart
List<String> _getPredefinedSubTypes() {
  return _kServiceSubTypes[widget.shopType] ?? [];
}
```

- [ ] **Step 3: Replace `_typeController`-based `AppTextFormField` with hybrid UI**

Remove the existing `AppTextFormField` for "Service Type" and replace with:
```dart
_buildSubTypePicker(theme),
```

Add the method:
```dart
Widget _buildSubTypePicker(ThemeData theme) {
  final predefined = _getPredefinedSubTypes();
  final selected = _useCustomSubType ? null : _typeController.text;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Service Type',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      if (predefined.isNotEmpty) ...[
        Gap(Spacing.xs.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: [
            ...predefined.map((sub) => ChoiceChip(
              label: Text(sub),
              selected: selected == sub,
              onSelected: (_) => setState(() {
                _typeController.text = sub;
                _useCustomSubType = false;
              }),
              selectedColor: theme.colorScheme.primaryContainer,
            )),
            ChoiceChip(
              label: const Text('Custom…'),
              selected: _useCustomSubType,
              onSelected: (_) => setState(() {
                _useCustomSubType = true;
                _typeController.text = '';
              }),
              selectedColor: theme.colorScheme.secondaryContainer,
            ),
          ],
        ),
      ],
      if (_useCustomSubType || predefined.isEmpty) ...[
        Gap(Spacing.sm.h),
        AppTextFormField(
          controller: _customSubTypeController,
          label: 'Custom service type',
          hintText: predefined.isEmpty
              ? 'e.g., Fade, Box Braids, Deep Tissue'
              : 'Describe the service type',
          prefixIcon: Icons.label,
          onChanged: (v) => _typeController.text = v,
          validator: (v) => (v == null || v.isEmpty) ? 'Service type is required' : null,
        ),
      ],
      if (!_useCustomSubType && predefined.isNotEmpty && _typeController.text.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: Spacing.xs.h),
          child: Text(
            'Select a type above',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
          ),
        ),
    ],
  );
}
```

- [ ] **Step 4: Update `_submitAndClose` to handle custom sub-type**

```dart
final serviceType = _useCustomSubType
    ? _customSubTypeController.text.trim()
    : _typeController.text.trim();

if (serviceType.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please select or enter a service type')),
  );
  return;
}

final service = AppointmentSlotDTO(
  ...
  serviceType: serviceType,
  ...
);
```

- [ ] **Step 5: Pass `shopType` from `manage_services_screen.dart`**

In each `ServiceFormModal(...)` constructor call:
```dart
shopType: ref.read(shopCreationProvider).shopType,
```

- [ ] **Step 6: Verify**

```bash
flutter analyze \
  lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart \
  --no-fatal-infos 2>&1 | grep error
```
Expected: no output.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart \
        lib/presentation/features/shops/creation/presentation/screens/manage_services_screen.dart
git commit -m "feat(services): hybrid service sub-type picker — predefined chips + custom freetext per shop type"
```

---

## Task 6: Supabase migration — service_templates table + seed data

**Files:**
- Create: `supabase/migrations/20260613_service_templates.sql`

- [ ] **Step 1: Create migration directory and file**

```bash
mkdir -p supabase/migrations
```

- [ ] **Step 2: Write the SQL**

```sql
-- supabase/migrations/20260613_service_templates.sql
-- Creates service_templates table and seeds templates for all 4 shop types.

CREATE TABLE IF NOT EXISTS service_templates (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_type    TEXT NOT NULL,          -- 'Salon' | 'Barbershop' | 'Spa' | 'Nail Salon'
  service_name TEXT NOT NULL,
  service_type TEXT NOT NULL,          -- sub-type label
  duration_minutes INTEGER NOT NULL DEFAULT 30,
  suggested_price_minor INTEGER,       -- in minor units (kobo/cents), nullable = no suggestion
  description  TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Read-only for all authenticated users (client fetches templates).
ALTER TABLE service_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "templates_read" ON service_templates
  FOR SELECT USING (true);

-- Index for fast lookup by shop type.
CREATE INDEX idx_service_templates_shop_type ON service_templates(shop_type);

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO service_templates (shop_type, service_name, service_type, duration_minutes, suggested_price_minor, description) VALUES
-- Barbershop
('Barbershop', 'Haircut', 'Fade', 30, NULL, 'Classic fade haircut'),
('Barbershop', 'Haircut', 'Low Fade', 30, NULL, 'Low fade haircut'),
('Barbershop', 'Haircut', 'High Fade', 30, NULL, 'High fade haircut'),
('Barbershop', 'Haircut', 'Skin Fade', 45, NULL, 'Skin/bald fade haircut'),
('Barbershop', 'Haircut', 'Taper', 30, NULL, 'Classic taper cut'),
('Barbershop', 'Beard Trim', 'Beard Trim', 20, NULL, 'Beard shaping and trim'),
('Barbershop', 'Lineup', 'Edge-Up', 15, NULL, 'Hairline and edge-up shaping'),
('Barbershop', 'Hot Towel Shave', 'Hot Towel Shave', 45, NULL, 'Traditional hot towel straight razor shave'),
('Barbershop', 'Kids Cut', 'Kids Cut', 20, NULL, 'Haircut for children under 12'),
('Barbershop', 'Design Cut', 'Design Cut', 60, NULL, 'Custom hair design or pattern'),

-- Salon
('Salon', 'Haircut', 'Haircut', 45, NULL, 'Women''s haircut and style'),
('Salon', 'Hair Colour', 'Full Colour', 120, NULL, 'Full hair colour application'),
('Salon', 'Hair Colour', 'Highlights', 90, NULL, 'Partial or full highlights'),
('Salon', 'Blowout', 'Blowout', 45, NULL, 'Wash and blow dry styling'),
('Salon', 'Braids', 'Box Braids', 240, NULL, 'Box braids protective style'),
('Salon', 'Braids', 'Cornrows', 120, NULL, 'Traditional cornrow braiding'),
('Salon', 'Braids', 'Senegalese Twist', 300, NULL, 'Senegalese twist protective style'),
('Salon', 'Locs', 'Starter Locs', 180, NULL, 'Starting dreadlocks'),
('Salon', 'Natural Styling', 'Afro', 60, NULL, 'Natural afro shaping and styling'),
('Salon', 'Weave', 'Weave Install', 180, NULL, 'Sew-in weave installation'),
('Salon', 'Wig Install', 'Wig Install', 90, NULL, 'Wig fitting, gluing, and styling'),
('Salon', 'Relaxer', 'Relaxer', 120, NULL, 'Chemical hair relaxer treatment'),
('Salon', 'Keratin', 'Keratin Treatment', 180, NULL, 'Smoothing keratin treatment'),

-- Spa
('Spa', 'Swedish Massage', 'Swedish Massage', 60, NULL, 'Relaxing full-body Swedish massage'),
('Spa', 'Swedish Massage', 'Swedish Massage', 90, NULL, '90-minute full-body Swedish massage'),
('Spa', 'Deep Tissue Massage', 'Deep Tissue', 60, NULL, 'Therapeutic deep tissue massage'),
('Spa', 'Hot Stone Massage', 'Hot Stone', 90, NULL, 'Hot stone relaxation massage'),
('Spa', 'Facial', 'Classic Facial', 60, NULL, 'Deep cleansing facial'),
('Spa', 'Facial', 'Hydrafacial', 60, NULL, 'Hydradermabrasion facial treatment'),
('Spa', 'Body Scrub', 'Body Scrub', 60, NULL, 'Full body exfoliation scrub'),
('Spa', 'Waxing', 'Eyebrow Wax', 15, NULL, 'Eyebrow shaping with wax'),
('Spa', 'Waxing', 'Full Leg Wax', 45, NULL, 'Full leg waxing'),
('Spa', 'Eyelash Extensions', 'Classic Lashes', 90, NULL, 'Classic eyelash extension set'),
('Spa', 'Foot Treatment', 'Foot Massage', 30, NULL, 'Relaxing foot and ankle massage'),

-- Nail Salon
('Nail Salon', 'Manicure', 'Classic Manicure', 30, NULL, 'Classic nail shaping and polish'),
('Nail Salon', 'Pedicure', 'Classic Pedicure', 45, NULL, 'Classic foot care and polish'),
('Nail Salon', 'Gel Nails', 'Gel Manicure', 45, NULL, 'Long-lasting gel polish application'),
('Nail Salon', 'Acrylic Nails', 'Full Set Acrylics', 90, NULL, 'Full acrylic nail set'),
('Nail Salon', 'Acrylic Nails', 'Acrylic Fill', 60, NULL, 'Acrylic infill/refill'),
('Nail Salon', 'Nail Art', 'Nail Art', 30, NULL, 'Custom nail art design'),
('Nail Salon', 'Dip Powder', 'Dip Powder Manicure', 60, NULL, 'Dip powder nail application'),
('Nail Salon', 'Nail Repair', 'Nail Repair', 15, NULL, 'Single nail repair');
```

- [ ] **Step 3: Run the migration in Supabase dashboard**

Copy the SQL above, go to Supabase Dashboard → SQL Editor → paste and run. Verify:
```sql
SELECT shop_type, COUNT(*) FROM service_templates GROUP BY shop_type;
```
Expected: 4 rows, each with 10+ count.

- [ ] **Step 4: Commit the migration file**

```bash
git add supabase/migrations/20260613_service_templates.sql
git commit -m "feat(db): add service_templates table with seed data for 4 shop types"
```

---

## Task 7: ServiceTemplate DTO + repository + provider

**Files:**
- Create: `lib/presentation/features/shops/creation/domain/models/service_template_dto.dart`
- Create: `lib/presentation/features/shops/creation/data/service_templates_repository.dart`
- Create: `lib/presentation/features/shops/creation/providers/service_templates_provider.dart`

- [ ] **Step 1: Create `ServiceTemplateDTO`**

```dart
// lib/presentation/features/shops/creation/domain/models/service_template_dto.dart
import 'package:equatable/equatable.dart';

class ServiceTemplateDTO extends Equatable {
  final String id;
  final String shopType;
  final String serviceName;
  final String serviceType;
  final int durationMinutes;
  final int? suggestedPriceMinor; // nullable — no price suggestion for most
  final String? description;

  const ServiceTemplateDTO({
    required this.id,
    required this.shopType,
    required this.serviceName,
    required this.serviceType,
    required this.durationMinutes,
    this.suggestedPriceMinor,
    this.description,
  });

  factory ServiceTemplateDTO.fromJson(Map<String, dynamic> json) {
    return ServiceTemplateDTO(
      id: json['id'] as String,
      shopType: json['shop_type'] as String,
      serviceName: json['service_name'] as String,
      serviceType: json['service_type'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      suggestedPriceMinor: json['suggested_price_minor'] as int?,
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, shopType, serviceName, serviceType, durationMinutes];
}
```

- [ ] **Step 2: Create `ServiceTemplatesRepository`**

```dart
// lib/presentation/features/shops/creation/data/service_templates_repository.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_template_dto.dart';

class ServiceTemplatesRepository {
  final SupabaseClient _client;

  ServiceTemplatesRepository(this._client);

  Future<List<ServiceTemplateDTO>> fetchByShopType(String shopType) async {
    try {
      final response = await _client
          .from('service_templates')
          .select()
          .eq('shop_type', shopType)
          .order('service_name');

      return (response as List)
          .map((row) => ServiceTemplateDTO.fromJson(
                row is Map ? Map<String, dynamic>.from(row) : row,
              ))
          .toList();
    } catch (e) {
      debugPrint('ServiceTemplatesRepository.fetchByShopType error: $e');
      return const [];
    }
  }
}
```

- [ ] **Step 3: Create `serviceTemplatesProvider`**

```dart
// lib/presentation/features/shops/creation/providers/service_templates_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/service_templates_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_template_dto.dart';

final _serviceTemplatesRepoProvider = Provider<ServiceTemplatesRepository>((ref) {
  return ServiceTemplatesRepository(Supabase.instance.client);
});

/// Fetches templates for [shopType]. Returns empty list on error (graceful degradation).
final serviceTemplatesProvider =
    FutureProvider.family<List<ServiceTemplateDTO>, String>((ref, shopType) async {
  return ref.read(_serviceTemplatesRepoProvider).fetchByShopType(shopType);
});
```

- [ ] **Step 4: Verify**

```bash
flutter analyze \
  lib/presentation/features/shops/creation/domain/models/service_template_dto.dart \
  lib/presentation/features/shops/creation/data/service_templates_repository.dart \
  lib/presentation/features/shops/creation/providers/service_templates_provider.dart \
  --no-fatal-infos 2>&1 | grep error
```
Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add \
  lib/presentation/features/shops/creation/domain/models/service_template_dto.dart \
  lib/presentation/features/shops/creation/data/service_templates_repository.dart \
  lib/presentation/features/shops/creation/providers/service_templates_provider.dart
git commit -m "feat(templates): add ServiceTemplateDTO, repository, and Riverpod provider"
```

---

## Task 8: ServiceTemplatesSheet widget + wire to manage_services_screen

**Files:**
- Create: `lib/presentation/features/shops/creation/presentation/widgets/service_templates_sheet.dart`
- Modify: `lib/presentation/features/shops/creation/presentation/screens/manage_services_screen.dart`

- [ ] **Step 1: Create `ServiceTemplatesSheet`**

```dart
// lib/presentation/features/shops/creation/presentation/widgets/service_templates_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_icon_button.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_template_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_templates_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

class ServiceTemplatesSheet extends ConsumerWidget {
  final String shopType;
  final String? currencySymbol;
  final void Function(AppointmentSlotDTO prefilled) onTemplateSelected;

  const ServiceTemplatesSheet({
    super.key,
    required this.shopType,
    required this.onTemplateSelected,
    this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(serviceTemplatesProvider(shopType));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text('Templates for $shopType', style: theme.textTheme.titleMedium),
        leading: AppIconButton(
          icon: Icons.close,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularLoadingIndicator()),
        error: (_, __) => EmptyStateWidget(
          title: 'Could not load templates',
          subtitle: 'Check your connection and try again',
          icon: Icons.cloud_off,
        ),
        data: (templates) {
          if (templates.isEmpty) {
            return EmptyStateWidget(
              title: 'No templates for $shopType',
              subtitle: 'Add services manually',
              icon: Icons.content_cut,
            );
          }

          // Group by service_name for section headers.
          final grouped = <String, List<ServiceTemplateDTO>>{};
          for (final t in templates) {
            grouped.putIfAbsent(t.serviceName, () => []).add(t);
          }

          return ListView(
            padding: EdgeInsets.all(Spacing.md.h),
            children: [
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: EdgeInsets.only(top: Spacing.md.h, bottom: Spacing.xs.h),
                  child: Text(
                    entry.key,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                for (final t in entry.value)
                  ListTile(
                    title: Text(t.serviceType),
                    subtitle: Text('${t.durationMinutes} min'
                        '${t.description != null ? ' · ${t.description}' : ''}'),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      final prefilled = AppointmentSlotDTO(
                        id: '',
                        serviceName: t.serviceName,
                        serviceType: t.serviceType,
                        duration: '${t.durationMinutes} minutes',
                        price: t.suggestedPriceMinor ?? 0,
                        slotType: 'in-person',
                        maxClients: 1,
                        daysOfWeek: const [],
                        selectPreferredWorker: false,
                        workerIds: const [],
                        bufferMinutes: 0,
                        description: t.description,
                      );
                      Navigator.pop(context);
                      onTemplateSelected(prefilled);
                    },
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Add "Use template" button to `manage_services_screen.dart`**

In `ManageServicesScreen`, the shop type is available via `ref.watch(shopCreationProvider).shopType`. Add a helper that opens the sheet:

```dart
void _showTemplatesSheet() {
  final draft = ref.read(shopCreationProvider);
  if (draft.shopType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Set your shop type in Basics first')),
    );
    return;
  }
  BottomSheetUtils.showDocumentationBottomSheet(
    context: context,
    maxHeight: 600.h,
    widget: ServiceTemplatesSheet(
      shopType: draft.shopType!,
      currencySymbol: draft.currencySymbol,
      onTemplateSelected: (prefilled) {
        // Open ServiceFormModal pre-filled with template values.
        _editServiceById(prefilled); // reuse the existing method with blank id
      },
    ),
  );
}
```

In the `Scaffold`, add a secondary FAB or action button. The screen already has an `appBar` with actions. Add:
```dart
floatingActionButton: FloatingActionButton.extended(
  heroTag: 'templates_fab',
  onPressed: _showTemplatesSheet,
  icon: const Icon(Icons.auto_awesome),
  label: const Text('Templates'),
),
```

- [ ] **Step 3: Handle the case where `prefilled.id == ''` in `_editServiceById`**

In `_editServiceById`, the `onSave` calls `updateServiceById(service.id, ...)`. When `id == ''` (template), we want to **add** instead:

```dart
void _editServiceById(AppointmentSlotDTO service) {
  ...
  void openForm(List<dynamic> workers) {
    if (!mounted) return;
    final isNew = service.id.isEmpty; // template case
    BottomSheetUtils.showDocumentationBottomSheet(
      ...
      widget: ServiceFormModal(
        initialService: service,
        shopType: ref.read(shopCreationProvider).shopType,
        currencySymbol: ref.read(shopCreationProvider).currencySymbol,
        onSave: (updatedService) {
          if (isNew) {
            ref.read(servicesProvider.notifier).addService(updatedService);
          } else {
            ref.read(servicesProvider.notifier).updateServiceById(service.id, updatedService);
          }
        },
        ...
      ),
    );
  }
  ...
}
```

- [ ] **Step 4: Verify**

```bash
flutter analyze \
  lib/presentation/features/shops/creation/presentation/widgets/service_templates_sheet.dart \
  lib/presentation/features/shops/creation/presentation/screens/manage_services_screen.dart \
  --no-fatal-infos 2>&1 | grep error
```
Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add \
  lib/presentation/features/shops/creation/presentation/widgets/service_templates_sheet.dart \
  lib/presentation/features/shops/creation/presentation/screens/manage_services_screen.dart
git commit -m "feat(templates): ServiceTemplatesSheet + FAB on manage_services — tap to pre-fill ServiceFormModal"
```

---

## Task 9: Document picker — file_picker (PDF/JPG/PNG) + expiry date bug fix

**Files:**
- Modify: `lib/presentation/features/shops/creation/presentation/widgets/document_picker_sheet.dart`

- [ ] **Step 1: Fix the expiry date picker bug**

In `_selectExpiryDate()`, the last `setState` at the bottom (after the sheet closes) unconditionally overwrites `_expiryDate` with `initialDate`, even if the user didn't pick anything. Remove it:

Current (broken) code at end of `_selectExpiryDate`:
```dart
setState(() {
  _expiryDate = initialDate;
});
```

**Delete those 3 lines entirely.** The `CupertinoDatePicker.onDateTimeChanged` callback inside the sheet already updates `_expiryDate` correctly via setState.

- [ ] **Step 2: Replace `_pickDocument` with `file_picker`**

Replace the entire `_pickDocument` method:
```dart
Future<void> _pickDocument() async {
  if (_selectedType == null) return;
  setState(() => _isLoading = true);

  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false, // stream path only, avoid loading full bytes into memory
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty || result.files.first.path == null) {
      return; // user cancelled
    }

    final path = result.files.first.path!;
    final file = File(path);

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
    if (mounted) {
      context.showErrorSnackbar('Error picking document: $e');
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

- [ ] **Step 3: Update the build method to remove camera option + unify to one button**

The camera option for documents is removed (you can't take a photo of a PDF). Replace the two `InfoRowWidget` options with one:

```dart
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
```

- [ ] **Step 4: Add missing imports**

```dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
```

Remove unused import `package:nano_embryo/core/providers/media_%20service_providers.dart` if it's no longer used after removing `imagePickerServiceProvider`.

- [ ] **Step 5: Verify**

```bash
flutter analyze \
  lib/presentation/features/shops/creation/presentation/widgets/document_picker_sheet.dart \
  --no-fatal-infos 2>&1 | grep error
```
Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/features/shops/creation/presentation/widgets/document_picker_sheet.dart
git commit -m "fix(documents): use file_picker for PDF/JPG/PNG, fix expiry date always-overwrite bug, remove camera option"
```

---

## Task 10: Final analyze + smoke check

**Files:** None (verification only)

- [ ] **Step 1: Run full analyze**

```bash
flutter analyze --no-fatal-infos 2>&1 | grep "^  error" | grep -v "test/chat\|test/wallet"
```
Expected: no output (zero production errors).

- [ ] **Step 2: Run shop_creation tests**

```bash
flutter test test/shop_creation/ --reporter=compact --timeout=60s 2>&1 | tail -5
```
Expected: all pass.

- [ ] **Step 3: Verify `phone_form_field` is resolved**

```bash
flutter pub deps 2>&1 | grep phone_form_field
```
Expected: `phone_form_field 10.0.17` (or similar).

- [ ] **Step 4: Commit (if any analysis-driven cleanups were needed)**

```bash
git add -p  # only stage actual fixes
git commit -m "chore(ux-hardening): fix analyze warnings from UX hardening phase"
```

---

## Self-Review

**Spec coverage check:**
- ✅ Phone: country picker with auto-set from shop country → Task 3
- ✅ "Set as primary" checkbox wired → Task 3
- ✅ Buffer time UI → Task 4
- ✅ Currency symbol next to price → Task 4
- ✅ "Select all open days" → Task 4
- ✅ Service sub-type hybrid (predefined + freetext) → Task 5
- ✅ Service templates from Supabase → Tasks 6 + 7 + 8
- ✅ Document picker → file_picker for PDF/JPG/PNG → Task 9
- ✅ Expiry date picker bug → Task 9
- ✅ All Material date pickers → Cupertino → Tasks 1 + 2
- ✅ All Material time pickers → Cupertino → Task 2

**Placeholder scan:** All steps include complete code. `business_hours_screen.dart` in Task 2 Step 4 has a note to read field names first — this is intentional (the field names vary and must be confirmed from the file) not a placeholder.

**Type consistency:** `ServiceTemplateDTO`, `ServiceTemplatesRepository`, `serviceTemplatesProvider`, `ServiceTemplatesSheet` — names consistent across Tasks 6/7/8. `_editServiceById` extended in Task 8 to handle `id == ''` template case consistently with Task 4's `updateServiceById`.
