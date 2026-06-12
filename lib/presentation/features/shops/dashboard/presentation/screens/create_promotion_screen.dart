// lib/features/dashboard/presentation/screens/create_promotion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';


class CreatePromotionScreen extends ConsumerStatefulWidget {
  final String shopId;
  final Promotion? promotion;

  const CreatePromotionScreen({
    super.key,
    required this.shopId,
    this.promotion,
  });

  @override
  ConsumerState<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends ConsumerState<CreatePromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late DiscountType _discountType;
  late TextEditingController _discountValueController;
  late DateTime _validFrom;
  late DateTime _validTo;
  late TextEditingController _usageLimitController;
  late bool _isActive;
  bool _isLoading = false;

  // ── Phase 13.1 — owner-facing fields wired through to the server ──
  late TextEditingController _perClientMaxController;
  late TextEditingController _minBookingAmountController;
  Set<String> _serviceRestriction = {};
  late bool _archived; // edit mode only

  @override
  void initState() {
    super.initState();
    final promotion = widget.promotion;

    _nameController = TextEditingController(text: promotion?.name);
    _codeController = TextEditingController(text: promotion?.code);
    _discountType = promotion?.discountType ?? DiscountType.percentage;
    _discountValueController = TextEditingController(
      text: promotion?.discountValue.toString(),
    );
    _validFrom = promotion?.validFrom ?? DateTime.now();
    _validTo = promotion?.validTo ?? DateTime.now().add(const Duration(days: 30));
    _usageLimitController = TextEditingController(
      text: promotion?.usageLimit?.toString(),
    );
    _isActive = promotion?.isActive ?? true;

    // Phase 13.1 seeds.
    _perClientMaxController =
        TextEditingController(text: (promotion?.perClientMax ?? 1).toString());
    _minBookingAmountController = TextEditingController(
      text: promotion?.minBookingAmount?.toStringAsFixed(2) ?? '',
    );
    _serviceRestriction = (promotion?.serviceRestriction ?? const [])
        .toSet();
    _archived = promotion?.archivedAt != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _discountValueController.dispose();
    _usageLimitController.dispose();
    _perClientMaxController.dispose();
    _minBookingAmountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Phase 13.1: parse the new fields. Empty min_booking_amount = no
    // floor (null). Empty per_client_max defaults to 1 (server CHECK
    // mirrors this). service_restriction = null when the owner picked
    // nothing (= any service).
    final perClientMax = int.tryParse(_perClientMaxController.text.trim());
    final minAmount = _minBookingAmountController.text.trim().isEmpty
        ? null
        : double.tryParse(_minBookingAmountController.text.trim());
    final restriction = _serviceRestriction.isEmpty
        ? null
        : _serviceRestriction.toList();

    // archived_at toggle. Edit-mode only — the server CHECK accepts
    // null / non-null; we just flip between current value and now().
    final archivedAt = !_archived
        ? null
        : (widget.promotion?.archivedAt ?? DateTime.now());

    final promotion = Promotion(
      id: widget.promotion?.id ?? '',
      shopId: widget.shopId,
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      discountType: _discountType,
      discountValue: double.parse(_discountValueController.text),
      validFrom: _validFrom,
      validTo: _validTo,
      usageLimit: _usageLimitController.text.isNotEmpty
          ? int.parse(_usageLimitController.text)
          : null,
      isActive: _isActive,
      createdAt: widget.promotion?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      // Phase 13.1 additions.
      source: widget.promotion?.source ?? PromoSource.ownerDefined,
      targetUserId: widget.promotion?.targetUserId,
      targetGuestProfileId: widget.promotion?.targetGuestProfileId,
      perClientMax: perClientMax ?? 1,
      minBookingAmount: minAmount,
      serviceRestriction: restriction,
      archivedAt: archivedAt,
    );

    try {
      final controller = ref.read(promotionsControllerProviderFamily(
        PromotionsParams(shopId: widget.shopId),
      ).notifier);

      if (widget.promotion == null) {
        await controller.createPromotion(promotion);
      } else {
        await controller.updatePromotion(promotion);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on PromotionException catch (e) {
      AppLogger.warn(
        'promotion.save_failed',
        fields: {'shop_id': widget.shopId, 'code': e.code},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.userMessage)),
        );
      }
    } catch (e) {
      AppLogger.warn(
        'promotion.save_failed',
        fields: {'shop_id': widget.shopId, 'error': e.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("We couldn't save this promotion. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _validFrom : _validTo,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.promotion == null ? 'Create Promotion' : 'Edit Promotion',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularLoadingIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(Spacing.md.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promotion Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Promotion Name',
                        hintText: 'e.g., Summer Sale 2024',
                        prefixIcon: Icon(Icons.local_offer),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a promotion name';
                        }
                        return null;
                      },
                    ),
                    Gap(Spacing.md.h),

                    // Promotion Code
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Promotion Code',
                        hintText: 'e.g., SUMMER20',
                        prefixIcon: Icon(Icons.qr_code),
                        helperText: 'Customers will enter this code at checkout',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a promotion code';
                        }
                        if (value.length < 3) {
                          return 'Code must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    Gap(Spacing.md.h),

                    // Discount Type
                    Text(
                      'Discount Type',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(Spacing.sm.h),
                    SegmentedButton<DiscountType>(
                      segments: const [
                        ButtonSegment(
                          value: DiscountType.percentage,
                          label: Text('Percentage'),
                        ),
                        ButtonSegment(
                          value: DiscountType.fixed,
                          label: Text('Fixed Amount'),
                        ),
                        ButtonSegment(
                          value: DiscountType.freeAddon,
                          label: Text('Free Add-on'),
                        ),
                      ],
                      selected: {_discountType},
                      onSelectionChanged: (Set<DiscountType> selection) {
                        setState(() {
                          _discountType = selection.first;
                        });
                      },
                    ),
                    Gap(Spacing.md.h),

                    // Discount Value
                    TextFormField(
                      controller: _discountValueController,
                      decoration: InputDecoration(
                        labelText: _discountType == DiscountType.percentage
                            ? 'Discount Percentage'
                            : 'Discount Amount',
                        hintText: _discountType == DiscountType.percentage
                            ? 'e.g., 20'
                            : 'e.g., 10.00',
                        prefixIcon: _discountType == DiscountType.percentage
                            ? const Icon(Icons.percent)
                            : const Icon(Icons.attach_money),
                        suffixText: _discountType == DiscountType.percentage
                            ? '%'
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a discount value';
                        }
                        final numValue = double.tryParse(value);
                        if (numValue == null || numValue <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        if (_discountType == DiscountType.percentage && numValue > 100) {
                          return 'Percentage cannot exceed 100%';
                        }
                        return null;
                      },
                    ),
                    Gap(Spacing.md.h),

                    // Valid From
                    ListTile(
                      title: const Text('Valid From'),
                      subtitle: Text(_formatDate(_validFrom)),
                      leading: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Gap(Spacing.sm.h),

                    // Valid To
                    ListTile(
                      title: const Text('Valid To'),
                      subtitle: Text(_formatDate(_validTo)),
                      leading: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Gap(Spacing.md.h),

                    // Usage Limit
                    TextFormField(
                      controller: _usageLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Usage Limit (Optional)',
                        hintText: 'Leave empty for unlimited',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = int.tryParse(value);
                          if (numValue == null || numValue <= 0) {
                            return 'Please enter a valid positive number';
                          }
                        }
                        return null;
                      },
                    ),
                    Gap(Spacing.md.h),

                    // ── Phase 13.1: per-client max ───────────────────
                    TextFormField(
                      controller: _perClientMaxController,
                      decoration: InputDecoration(
                        labelText: loc.promoFieldPerClientMaxLabel,
                        hintText: loc.promoFieldPerClientMaxHint,
                        prefixIcon: const Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final n = int.tryParse(value);
                        if (n == null || n < 1) {
                          return loc.promoValidationPerClientMin;
                        }
                        return null;
                      },
                    ),
                    Gap(Spacing.md.h),

                    // ── Phase 13.1: minimum booking amount ───────────
                    TextFormField(
                      controller: _minBookingAmountController,
                      decoration: InputDecoration(
                        labelText: loc.promoFieldMinAmountLabel,
                        hintText: loc.promoFieldMinAmountHint,
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final n = double.tryParse(value);
                        if (n == null || n < 0) {
                          return loc.promoValidationMinAmountNonNegative;
                        }
                        return null;
                      },
                    ),
                    Gap(Spacing.md.h),

                    // ── Phase 13.1: service restriction picker ────────
                    _ServiceRestrictionPicker(
                      shopId: widget.shopId,
                      selected: _serviceRestriction,
                      onChanged: (next) => setState(() {
                        _serviceRestriction = next;
                      }),
                    ),
                    Gap(Spacing.md.h),

                    // Active Toggle
                    SwitchListTile(
                      title: const Text('Active'),
                      subtitle: const Text('Inactive promotions won\'t be available for use'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    // ── Phase 13.1: archive toggle (edit mode only) ──
                    if (widget.promotion != null)
                      SwitchListTile(
                        title: Text(loc.promoFieldArchivedTitle),
                        subtitle: Text(loc.promoFieldArchivedSubtitle),
                        value: _archived,
                        onChanged: (value) {
                          setState(() => _archived = value);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    Gap(Spacing.lg.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: Text(
                          widget.promotion == null ? 'Create Promotion' : 'Update Promotion',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Phase 13.1 — multi-select for the shop's active services. Null
/// (empty set on submit) = no restriction (any service eligible).
///
/// Loads the shop's services lazily via dashboardRepositoryProvider's
/// `getActiveServices`. Failure to load degrades to an info card —
/// owners can still save the promotion with no restriction.
class _ServiceRestrictionPicker extends ConsumerStatefulWidget {
  final String shopId;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const _ServiceRestrictionPicker({
    required this.shopId,
    required this.selected,
    required this.onChanged,
  });

  @override
  ConsumerState<_ServiceRestrictionPicker> createState() =>
      _ServiceRestrictionPickerState();
}

class _ServiceRestrictionPickerState
    extends ConsumerState<_ServiceRestrictionPicker> {
  late Future<List<AppointmentSlotDTO>> _future;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(dashboardRepositoryProvider);
    _future = repo.getActiveServices(widget.shopId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.filter_list, size: 20),
            const SizedBox(width: 12),
            Text(loc.promoFieldServiceRestrictionTitle,
                style: theme.textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          loc.promoFieldServiceRestrictionSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<AppointmentSlotDTO>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              );
            }
            if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  snapshot.hasError
                      ? loc.promoFieldServiceRestrictionLoadFailed
                      : loc.promoFieldServiceRestrictionEmpty,
                  style: theme.textTheme.bodySmall,
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: snapshot.data!.map((slot) {
                final isSelected = widget.selected.contains(slot.id);
                return FilterChip(
                  label: Text(slot.serviceName),
                  selected: isSelected,
                  onSelected: (value) {
                    final next = Set<String>.from(widget.selected);
                    if (value) {
                      next.add(slot.id);
                    } else {
                      next.remove(slot.id);
                    }
                    widget.onChanged(next);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
