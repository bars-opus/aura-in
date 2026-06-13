// lib/presentation/features/shops/dashboard/presentation/screens/pricing_override_form_screen.dart
//
// Phase 15 — owner-facing create/edit form for a pricing rule on a slot.
//
// Sections:
//   1. Name
//   2. Day of week (null = All week, else 1..7)
//   3. Time window (start / end pickers)
//   4. Adjustment (segmented kind + value)
//   5. Validity range (optional valid_from / valid_until)
//   6. Live price preview (computed client-side, slot.price as base)
//   7. Soft warnings (>50% surcharge, fixed_surcharge > 5x base)
//
// Soft warnings WARN — they never block Save. Server is source of truth.
// Errors → typed PricingOverrideException → message shown via snackbar.
//
// v1 limitation: dayOfWeek / validUntil cannot be CLEARED on edit (server
// RPC limitation). The form disables clearing them once set in edit mode
// and surfaces an inline hint pointing to the archive-and-recreate path.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/cupertino_date_picker_sheet.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/pricing_overrides_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

class PricingOverrideFormScreen extends ConsumerStatefulWidget {
  final AppointmentSlotDTO slot;

  /// Null = create mode. Non-null = edit mode (form pre-filled).
  final PricingOverrideDTO? rule;

  const PricingOverrideFormScreen({
    super.key,
    required this.slot,
    this.rule,
  });

  @override
  ConsumerState<PricingOverrideFormScreen> createState() =>
      _PricingOverrideFormScreenState();
}

class _PricingOverrideFormScreenState
    extends ConsumerState<PricingOverrideFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _valueController;

  int? _dayOfWeek; // 1..7 or null (all week)
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 12, minute: 0);
  AdjustmentKind _kind = AdjustmentKind.percentDiscount;
  DateTime? _validFrom;
  DateTime? _validUntil;

  bool _saving = false;
  bool _dirty = false;

  bool get _isEdit => widget.rule != null;

  AppLocalizations get _loc => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    _nameController = TextEditingController(text: r?.name ?? '');
    _valueController = TextEditingController(
      text: r == null ? '' : _formatValue(r.value),
    );
    if (r != null) {
      _dayOfWeek = r.dayOfWeek;
      _start = _parseTime(r.timeWindowStart);
      _end = _parseTime(r.timeWindowEnd);
      _kind = r.kind;
      _validFrom = r.validFrom;
      _validUntil = r.validUntil;
    }
    _nameController.addListener(_markDirty);
    _valueController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  String _formatValue(double v) {
    // Trim trailing .0 for percent (most owners type whole numbers);
    // keep 2dp for fixed currency.
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  TimeOfDay _parseTime(String hms) {
    final parts = hms.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _timeToHms(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _timeLabel(TimeOfDay t) {
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final mm = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$mm $period';
  }

  Map<int, String> _dayLabels(AppLocalizations loc) => {
        1: loc.pricingOverrideDayMonday,
        2: loc.pricingOverrideDayTuesday,
        3: loc.pricingOverrideDayWednesday,
        4: loc.pricingOverrideDayThursday,
        5: loc.pricingOverrideDayFriday,
        6: loc.pricingOverrideDaySaturday,
        7: loc.pricingOverrideDaySunday,
      };

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

  double? get _parsedValue {
    final t = _valueController.text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  /// Compute effective price for a sample base = slot.price. Used in
  /// the live preview row. Mirrors the server math exactly (clamp at 0).
  double? get _previewPrice {
    final v = _parsedValue;
    if (v == null || v <= 0) return null;
    final base = widget.slot.price;
    switch (_kind) {
      case AdjustmentKind.percentDiscount:
        if (v > 100) return null;
        return (base * (1 - v / 100.0)).clamp(0.0, double.infinity);
      case AdjustmentKind.percentSurcharge:
        return base * (1 + v / 100.0);
      case AdjustmentKind.fixedDiscount:
        return (base - v).clamp(0.0, double.infinity);
      case AdjustmentKind.fixedSurcharge:
        return base + v;
    }
  }

  /// Soft warning state — flagged when the rule is unusually aggressive
  /// but still server-acceptable.
  String? get _softWarning {
    final v = _parsedValue;
    if (v == null) return null;
    if (_kind == AdjustmentKind.percentSurcharge && v > 50) {
      return _loc.pricingOverrideFormSoftWarnPercent(v.toStringAsFixed(0));
    }
    if (_kind == AdjustmentKind.fixedSurcharge && v > widget.slot.price * 5) {
      return _loc.pricingOverrideFormSoftWarnFixed;
    }
    return null;
  }

  String? _validateName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return _loc.pricingOverrideFormNameRequired;
    if (t.length > 80) return _loc.pricingOverrideFormNameTooLong;
    return null;
  }

  String? _validateValue(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return _loc.pricingOverrideFormValueRequired;
    final d = double.tryParse(t);
    if (d == null || d <= 0) return _loc.pricingOverrideFormValueMustBePositive;
    if (_kind.isPercent && d > 100) {
      return _loc.pricingOverrideFormValuePercentRange;
    }
    return null;
  }

  String? _validateWindow() {
    if (_toMinutes(_end) <= _toMinutes(_start)) {
      return _loc.pricingOverrideFormWindowError;
    }
    return null;
  }

  String? _validateValidity() {
    if (_validFrom != null &&
        _validUntil != null &&
        !_validUntil!.isAfter(_validFrom!)) {
      return _loc.pricingOverrideFormValidityError;
    }
    return null;
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l.pricingOverrideFormDiscardTitle),
          content: Text(l.pricingOverrideFormDiscardBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.pricingOverrideFormDiscardKeep),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.pricingOverrideFormDiscardConfirm),
            ),
          ],
        );
      },
    );
    return ok ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final windowErr = _validateWindow();
    if (windowErr != null) {
      Snackbar.error(context, windowErr);
      return;
    }
    final validityErr = _validateValidity();
    if (validityErr != null) {
      Snackbar.error(context, validityErr);
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(dashboardRepositoryProvider);
    final name = _nameController.text.trim();
    final value = double.parse(_valueController.text.trim());

    try {
      if (_isEdit) {
        await repo.updatePricingOverride(
          overrideId: widget.rule!.id,
          name: name,
          dayOfWeek: _dayOfWeek,
          timeWindowStart: _timeToHms(_start),
          timeWindowEnd: _timeToHms(_end),
          kind: _kind,
          value: value,
          validFrom: _validFrom,
          validUntil: _validUntil,
        );
      } else {
        await repo.createPricingOverride(
          slotId: widget.slot.id,
          name: name,
          dayOfWeek: _dayOfWeek,
          timeWindowStart: _timeToHms(_start),
          timeWindowEnd: _timeToHms(_end),
          kind: _kind,
          value: value,
          validFrom: _validFrom,
          validUntil: _validUntil,
        );
      }
      ref.invalidate(pricingOverridesProvider(widget.slot.id));
      if (!mounted) return;
      Snackbar.success(
        context,
        _isEdit
            ? _loc.pricingOverrideUpdatedToast
            : _loc.pricingOverrideCreatedToast,
      );
      Navigator.of(context).pop(true);
    } on PricingOverrideException catch (e) {
      AppLogger.warn(
        'pricing_override.save_failed',
        fields: {
          'slot_id': widget.slot.id,
          'edit_mode': _isEdit,
          'code': e.code,
        },
      );
      if (!mounted) return;
      Snackbar.error(context, e.userMessage);
    } catch (e) {
      AppLogger.warn(
        'pricing_override.save_failed',
        fields: {
          'slot_id': widget.slot.id,
          'edit_mode': _isEdit,
          'error': e.toString(),
        },
      );
      if (!mounted) return;
      Snackbar.error(context, _loc.pricingOverrideErrorSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: scheme.background,
        appBar: AppBar(
          title: Text(
            _isEdit
                ? loc.pricingOverrideFormTitleEdit
                : loc.pricingOverrideFormTitleNew,
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              Spacing.md.w,
              Spacing.md.h,
              Spacing.md.w,
              Spacing.xl.h * 2,
            ),
            children: [
              _SectionLabel(text: loc.pricingOverrideFormName),
              TextFormField(
                controller: _nameController,
                maxLength: 80,
                decoration: InputDecoration(
                  hintText: loc.pricingOverrideFormNameHint,
                  border: const OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              Gap(Spacing.md.h),

              _SectionLabel(text: loc.pricingOverrideFormDayOfWeek),
              DropdownButtonFormField<int?>(
                value: _dayOfWeek,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(loc.pricingOverrideAllWeek),
                  ),
                  for (final entry in _dayLabels(loc).entries)
                    DropdownMenuItem<int?>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: (v) => setState(() {
                  _dayOfWeek = v;
                  _dirty = true;
                }),
              ),
              if (_isEdit && widget.rule!.dayOfWeek != null && _dayOfWeek == null)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.xs.h),
                  child: Text(
                    loc.pricingOverrideFormClearDayHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              Gap(Spacing.md.h),

              _SectionLabel(text: loc.pricingOverrideFormTimeWindow),
              Row(
                children: [
                  Expanded(
                    child: _PickerTile(
                      label: loc.pricingOverrideFormStart,
                      value: _timeLabel(_start),
                      icon: Icons.access_time,
                      onTap: _pickStart,
                    ),
                  ),
                  Gap(Spacing.sm.w),
                  Expanded(
                    child: _PickerTile(
                      label: loc.pricingOverrideFormEnd,
                      value: _timeLabel(_end),
                      icon: Icons.access_time,
                      onTap: _pickEnd,
                    ),
                  ),
                ],
              ),
              if (_validateWindow() != null)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.xs.h),
                  child: Text(
                    _validateWindow()!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              Gap(Spacing.md.h),

              _SectionLabel(text: loc.pricingOverrideFormAdjustment),
              SegmentedButton<AdjustmentKind>(
                segments: [
                  ButtonSegment(
                    value: AdjustmentKind.percentDiscount,
                    label: Text(loc.pricingOverrideFormKindPercentDiscount),
                  ),
                  ButtonSegment(
                    value: AdjustmentKind.percentSurcharge,
                    label: Text(loc.pricingOverrideFormKindPercentSurcharge),
                  ),
                  ButtonSegment(
                    value: AdjustmentKind.fixedDiscount,
                    label: Text(loc.pricingOverrideFormKindFixedDiscount),
                  ),
                  ButtonSegment(
                    value: AdjustmentKind.fixedSurcharge,
                    label: Text(loc.pricingOverrideFormKindFixedSurcharge),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() {
                  _kind = s.first;
                  _dirty = true;
                }),
              ),
              Gap(Spacing.sm.h),
              TextFormField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: _kind.isFixed ? '\$ ' : null,
                  suffixText: _kind.isPercent ? '%' : null,
                  hintText: _kind.isPercent ? '20' : '10.00',
                  border: const OutlineInputBorder(),
                ),
                validator: _validateValue,
              ),
              if (_softWarning != null) ...[
                Gap(Spacing.sm.h),
                _SoftWarningBanner(text: _softWarning!),
              ],
              Gap(Spacing.md.h),

              _PreviewRow(
                base: widget.slot.price,
                effective: _previewPrice,
                isDiscount: _kind.isDiscount,
              ),
              Gap(Spacing.md.h),

              _SectionLabel(text: loc.pricingOverrideFormValidity),
              Row(
                children: [
                  Expanded(
                    child: _PickerTile(
                      label: loc.pricingOverrideFormValidityStarts,
                      value: _formatDate(_validFrom) ??
                          loc.pricingOverrideFormValidityToday,
                      icon: Icons.calendar_today,
                      onTap: _pickValidFrom,
                    ),
                  ),
                  Gap(Spacing.sm.w),
                  Expanded(
                    child: _PickerTile(
                      label: loc.pricingOverrideFormValidityEnds,
                      value: _formatDate(_validUntil) ??
                          loc.pricingOverrideFormValidityNoExpiry,
                      icon: Icons.event,
                      onTap: _pickValidUntil,
                    ),
                  ),
                ],
              ),
              if (_validateValidity() != null)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.xs.h),
                  child: Text(
                    _validateValidity()!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              if (_isEdit && widget.rule!.validUntil != null && _validUntil == null)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.xs.h),
                  child: Text(
                    loc.pricingOverrideFormClearValidUntilHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              Gap(Spacing.xl.h),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isEdit
                        ? loc.pricingOverrideFormSaveEdit
                        : loc.pricingOverrideFormSaveNew,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _formatDate(DateTime? d) {
    if (d == null) return null;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.xs.h),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.md.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: IconSizes.sm.w, color: scheme.primary),
            Gap(Spacing.sm.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftWarningBanner extends StatelessWidget {
  final String text;
  const _SoftWarningBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(Spacing.sm.w),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.tertiary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.tertiary, size: 20),
          Gap(Spacing.sm.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final int base; // minor units
  final double? effective;
  final bool isDiscount;

  const _PreviewRow({
    required this.base,
    required this.effective,
    required this.isDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final eff = effective;
    return Container(
      padding: EdgeInsets.all(Spacing.md.w),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.preview, color: scheme.primary, size: IconSizes.md.w),
          Gap(Spacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                Gap(2),
                if (eff == null)
                  Text(
                    'Base ${(base / 100).toStringAsFixed(2)} · enter a value to see the effective price.',
                    style: theme.textTheme.bodySmall,
                  )
                else
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '${(eff / 100).toStringAsFixed(2)} ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                        TextSpan(
                          text: isDiscount
                              ? '(saved ${((base - eff) / 100).toStringAsFixed(2)} vs ${(base / 100).toStringAsFixed(2)} base)'
                              : '(+${((eff - base) / 100).toStringAsFixed(2)} vs ${(base / 100).toStringAsFixed(2)} base)',
                          style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
