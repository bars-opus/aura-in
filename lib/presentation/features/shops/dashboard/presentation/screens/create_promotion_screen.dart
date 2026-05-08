// lib/features/dashboard/presentation/screens/create_promotion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';


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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _discountValueController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
