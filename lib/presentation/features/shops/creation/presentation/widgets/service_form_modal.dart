// lib/features/shop/creation/presentation/widgets/service_form_modal.dart
//
// Phase 11 changes (locked corrections 7 + 8):
//   * `availableHours` is now a required constructor parameter. The
//     widget no longer reads `hoursProvider` at runtime. Call sites
//     pass the shop's hours explicitly (creation flow reads from
//     `hoursProvider`; Tools-tab edit flow passes the loaded shop's
//     hours from `shopDetailsProvider`). This removes the silent
//     cross-contamination risk where opening this modal from a
//     published shop could pick up another shop's in-progress draft.
//   * `bufferMinutes` is no longer hard-coded to 15. It now defaults
//     to `widget.initialService?.bufferMinutes ?? 0`, so editing a
//     saved service preserves its buffer.
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_addon_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_addons_provider.dart';

final _selectedDaysProvider = StateProvider<List<int>>((ref) => []);

/// Predefined service sub-types per shop type.
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

class ServiceFormModal extends ConsumerStatefulWidget {
  final AppointmentSlotDTO? initialService;
  final int? index;
  final Function(AppointmentSlotDTO) onSave;
  final String? shopId;
  final List<WorkerDTO>? availableWorkers;
  final String? currencySymbol; // e.g. 'GH₵', '₦', '$'
  final String? shopType; // e.g. 'Salon', 'Barbershop'

  /// Weekly opening hours for the shop the service belongs to. Required
  /// so the form can validate day-of-week selections without reaching
  /// for a global `hoursProvider` that may belong to a different shop.
  final List<OpeningHoursDraft> availableHours;

  const ServiceFormModal({
    super.key,
    this.initialService,
    this.index,
    required this.onSave,
    this.shopId,
    this.availableWorkers,
    required this.availableHours,
    this.currencySymbol,
    this.shopType,
  });

  @override
  ConsumerState<ServiceFormModal> createState() => _ServiceFormModalState();
}

class _ServiceFormModalState extends ConsumerState<ServiceFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;

  late int _selectedDurationMinutes;
  late int _maxClients;
  late int _bufferBeforeMinutes;
  late int _bufferMinutes;
  late bool _selectPreferredWorker;
  late bool _isOnlineBookingEnabled;
  late List<String> _selectedWorkerIds;
  List<OpeningHoursDraft> _shopHours = [];
  bool _isLoadingHours = true;
  bool _hasHoursError = false;
  bool _useCustomSubType = false;
  late TextEditingController _customSubTypeController;

  // Add-ons managed inline on the form
  List<ServiceAddonDTO> _addons = [];
  bool _addonsExpanded = false;

  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialService?.serviceName ?? '',
    );
    _typeController = TextEditingController(
      text: widget.initialService?.serviceType ?? '',
    );
    _priceController = TextEditingController(
      text: widget.initialService != null
          ? (widget.initialService!.price / 100).toStringAsFixed(2)
          : '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialService?.description ?? '',
    );
    _selectedDurationMinutes =
        widget.initialService?.duration != null
            ? DurationUtils.parse(widget.initialService!.duration).inMinutes
            : 30;
    _maxClients = widget.initialService?.maxClients ?? 1;
    _bufferBeforeMinutes = widget.initialService?.bufferBeforeMinutes ?? 0;
    _bufferMinutes = widget.initialService?.bufferMinutes ?? 0;
    _selectPreferredWorker =
        widget.initialService?.selectPreferredWorker ?? false;
    _isOnlineBookingEnabled =
        widget.initialService?.isOnlineBookingEnabled ?? true;
    _selectedWorkerIds = List.from(widget.initialService?.workerIds ?? []);

    // Sub-type: detect if initialService has a custom (non-predefined) type.
    _customSubTypeController = TextEditingController();
    final predefined = _kServiceSubTypes[widget.shopType] ?? [];
    final existingType = widget.initialService?.serviceType ?? '';
    if (existingType.isNotEmpty && predefined.isNotEmpty && !predefined.contains(existingType)) {
      _useCustomSubType = true;
      _customSubTypeController.text = existingType;
    }

    // Initialize selected days
    final initialDays = widget.initialService?.daysOfWeek ?? [];
    Future.microtask(() {
      ref.read(_selectedDaysProvider.notifier).state = initialDays;
    });

    _hydrateFromProp();
    _loadAddons();
  }

  Future<void> _loadAddons() async {
    final slotId = widget.initialService?.id ?? '';
    if (slotId.isEmpty) return;
    final loaded = await ref.read(serviceAddonsRepoProvider).fetchBySlotId(slotId);
    if (mounted) setState(() => _addons = loaded);
  }

  /// Hydrate the form's hours state from the constructor parameter.
  /// Phase 11: replaces the previous `ref.read(hoursProvider)` lookup
  /// so this widget no longer couples to creation-flow global state.
  void _hydrateFromProp() {
    final hours = widget.availableHours;
    if (hours.isEmpty) {
      _hasHoursError = true;
      _isLoadingHours = false;
      return;
    }
    _shopHours = List.of(hours);
    _isLoadingHours = false;
    _hasHoursError = false;

    // If no days selected and shop has hours, default to open days.
    if (ref.read(_selectedDaysProvider).isEmpty) {
      final defaultDays =
          _shopHours.where((h) => !h.isClosed).map((h) => h.dayOfWeek).toList();
      if (defaultDays.isNotEmpty) {
        Future.microtask(() {
          ref.read(_selectedDaysProvider.notifier).state = defaultDays;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _customSubTypeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> _getPredefinedSubTypes() =>
      _kServiceSubTypes[widget.shopType] ?? [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEditing = widget.initialService != null;
    final workers = widget.availableWorkers ?? [];
    final selectedDays = ref.watch(_selectedDaysProvider);
    String hearder = isEditing ? 'Edit' : 'Add';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(Spacing.md.h),
        child: ListView(
          children: [
            SemanticContainerWidget(
              content:
                  'Add at least one service to continue. You can add more later.',
              icon: Icons.content_cut,
              title: '$hearder your services',
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              borderColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              textTheme: theme.textTheme,
            ),
            Gap(Spacing.md.h),

            // Show error if no opening hours set
            if (_hasHoursError)
              CardInkWell(
                elevation: 0,

                margin: const EdgeInsets.only(bottom: Spacing.sm),
                child: EmptyStateWidget(
                  icon: Icons.schedule,
                  title: 'No Opening Hours Set',
                  subtitle:
                      'Please set your shop hours first before adding services',
                  actionLabel: 'Set Hours',
                  onAction: () {
                    Navigator.pop(context);
                    context.push('/setHours');
                  },
                ),
              ),

            if (!_hasHoursError) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CardInkWell(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: Spacing.sm),

                      child: Column(
                        children: [
                          AppTextFormField(
                            controller: _nameController,
                            label: 'Service Name',
                            prefixIcon: Icons.content_cut,
                            validator:
                                (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Service name is required'
                                        : null,
                          ),
                          _buildSubTypePicker(theme),
                        ],
                      ),
                    ),

                    CardInkWell(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: Spacing.sm),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextFormField(
                                  controller: _priceController,
                                  label: widget.currencySymbol != null
                                      ? 'Price (${widget.currencySymbol})'
                                      : 'Price',
                                  prefixIcon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Price required';
                                    if (double.tryParse(value) == null)
                                      return 'Invalid price';
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: Spacing.md.w),
                              Expanded(child: _buildDurationDropdown(theme)),
                            ],
                          ),
                          Gap(Spacing.md.h),

                          if (!_selectPreferredWorker) ...[
                            _buildMaxClientsDropdown(theme),
                            Gap(Spacing.md.h),
                          ],

                          _buildWorkerToggle(theme),
                          if (_selectPreferredWorker) ...[
                            Gap(Spacing.md.h),
                            _buildWorkerSelector(theme, workers),
                          ],
                          Gap(Spacing.md.h),
                          _buildBufferBeforeStepper(theme),
                          Gap(Spacing.md.h),
                          _buildBufferStepper(theme),
                          Gap(Spacing.md.h),
                          _buildOnlineBookingToggle(theme),
                        ],
                      ),
                    ),

                    Gap(Spacing.md.h),
                    _buildDepositBanner(theme),
                    Gap(Spacing.md.h),

                    _buildDaySelector(theme, selectedDays),
                    Gap(Spacing.md.h),

                    AppTextFormField(
                      controller: _descriptionController,
                      label: 'Description (optional)',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              Gap(Spacing.md.h),
              _buildAddonsSection(theme),
              Gap(Spacing.lg.h),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: Spacing.md.w),
                  Expanded(
                    child: AppButton(
                      label: isEditing ? 'Update' : 'Add',
                      onPressed: _submitAndClose,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDurationDropdown(ThemeData theme) {
    final durationOptions = [
      15,
      30,
      45,
      60,
      75,
      90,
      105,
      120,
      150,
      180,
      240,
      480,
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedDurationMinutes,
        decoration: const InputDecoration(
          labelText: 'Duration',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.timer),
        ),
        items:
            durationOptions.map((minutes) {
              final duration = Duration(minutes: minutes);
              return DropdownMenuItem(
                value: minutes,
                child: Text(DurationUtils.formatForDisplay(duration)),
              );
            }).toList(),
        onChanged: (value) => setState(() => _selectedDurationMinutes = value!),
      ),
    );
  }

  Widget _buildMaxClientsDropdown(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonFormField<int>(
        value: _maxClients,
        decoration: const InputDecoration(
          labelText: 'Max Clients per Slot',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.people),
        ),
        items:
            List.generate(10, (i) => i + 1).map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value == 1 ? '$value person' : '$value people'),
              );
            }).toList(),
        onChanged: (value) => setState(() => _maxClients = value!),
      ),
    );
  }

  Widget _buildWorkerToggle(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Allow customer to select a specific worker',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Switch(
          value: _selectPreferredWorker,
          onChanged: (value) {
            setState(() {
              _selectPreferredWorker = value;
              if (!value) _selectedWorkerIds.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildWorkerSelector(ThemeData theme, List<WorkerDTO> workers) {
    if (workers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Spacing.sm.h),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 16.sp),
            SizedBox(width: Spacing.sm.w),
            Expanded(
              child: Text(
                'No active workers. Invite workers from Workers Management.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign workers for this service',
          style: theme.textTheme.bodySmall,
        ),
        Gap(Spacing.sm.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              workers.map((worker) {
                final isSelected = _selectedWorkerIds.contains(worker.id);
                return FilterChip(
                  label: Text(worker.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWorkerIds.add(worker.id);
                      } else {
                        _selectedWorkerIds.remove(worker.id);
                      }
                    });
                  },
                  avatar:
                      worker.profileImage != null
                          ? CircleAvatar(
                            radius: 12.r,
                            backgroundImage: NetworkImage(worker.profileImage!),
                          )
                          : null,
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primaryContainer,
                );
              }).toList(),
        ),
        if (_selectedWorkerIds.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: Spacing.sm.h),
            child: Text(
              '${_selectedWorkerIds.length} worker(s) assigned',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubTypePicker(ThemeData theme) {
    final predefined = _getPredefinedSubTypes();
    final selected = _useCustomSubType ? null : _typeController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Service type is required' : null,
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

  Widget _buildBufferBeforeStepper(ThemeData theme) {
    const options = [0, 5, 10, 15, 30];
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 20.sp, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        SizedBox(width: Spacing.sm.w),
        Expanded(
          child: Text('Prep time before service', style: theme.textTheme.bodyMedium),
        ),
        DropdownButton<int>(
          value: options.contains(_bufferBeforeMinutes) ? _bufferBeforeMinutes : 0,
          underline: const SizedBox(),
          items: options.map((m) => DropdownMenuItem(
            value: m,
            child: Text(m == 0 ? 'None' : '$m min'),
          )).toList(),
          onChanged: (v) => setState(() => _bufferBeforeMinutes = v ?? 0),
        ),
      ],
    );
  }

  Widget _buildOnlineBookingToggle(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accept online bookings', style: theme.textTheme.bodyMedium),
              Text(
                _isOnlineBookingEnabled
                    ? 'Clients can book this service online'
                    : 'Hidden from client booking flow',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isOnlineBookingEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _isOnlineBookingEnabled,
          onChanged: (v) => setState(() => _isOnlineBookingEnabled = v),
        ),
      ],
    );
  }

  Widget _buildDepositBanner(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w, vertical: Spacing.sm.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 18.sp, color: theme.colorScheme.primary),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              '30% deposit required at booking — protects your time from no-shows.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferStepper(ThemeData theme) {
    const options = [0, 5, 10, 15, 30];
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 20.sp, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        SizedBox(width: Spacing.sm.w),
        Expanded(
          child: Text('Cleanup time after service', style: theme.textTheme.bodyMedium),
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

  Widget _buildDaySelector(ThemeData theme, List<int> selectedDays) {
    if (_isLoadingHours) {
      return const Center(child: CircularLoadingIndicator());
    }

    final openDays =
        _shopHours.where((h) => !h.isClosed).map((h) => h.dayOfWeek).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Days',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(Spacing.xs.h),
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: List.generate(7, (index) {
              final day = index + 1;
              final isOpenDay = openDays.contains(day);
              final isSelected = selectedDays.contains(day);
              return CheckboxListTile(
                key: ValueKey(day),
                value: isSelected,
                onChanged:
                    isOpenDay
                        ? (selected) {
                          final notifier = ref.read(
                            _selectedDaysProvider.notifier,
                          );
                          final current = ref.read(_selectedDaysProvider);

                          if (selected == true) {
                            notifier.state = [...current, day];
                          } else {
                            notifier.state =
                                current.where((d) => d != day).toList();
                          }
                        }
                        : null,
                title: Text(
                  _dayNames[index],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isOpenDay
                            ? null
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                subtitle:
                    isOpenDay
                        ? null
                        : Text(
                          'Shop closed on this day',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                secondary:
                    isOpenDay
                        ? null
                        : Icon(Icons.lock_clock, color: Colors.grey),
                activeColor: theme.colorScheme.primary,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              );
            }),
          ),
        ),
        if (selectedDays.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: Spacing.sm.h),
            child: Text(
              'Please select at least one day',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddonsSection(ThemeData theme) {
    return CardInkWell(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            leading: Icon(Icons.add_circle_outline,
                color: theme.colorScheme.primary),
            title: Text('Add-ons (${_addons.length})',
                style: theme.textTheme.titleSmall),
            subtitle: Text('Optional extras clients can choose',
                style: theme.textTheme.bodySmall),
            trailing: Icon(
              _addonsExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () => setState(() => _addonsExpanded = !_addonsExpanded),
          ),
          if (_addonsExpanded) ...[
            const Divider(height: 1),
            ..._addons.asMap().entries.map((entry) {
              final i = entry.key;
              final addon = entry.value;
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: Spacing.md.w),
                title: Text(addon.name, style: theme.textTheme.bodyMedium),
                subtitle: Text(
                  [
                    '+${(addon.priceMinor / 100).toStringAsFixed(2)}',
                    if (addon.durationMinutes != null &&
                        addon.durationMinutes! > 0)
                      '+${addon.durationMinutes} min',
                  ].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  onPressed: () =>
                      setState(() => _addons.removeAt(i)),
                ),
              );
            }),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w, vertical: Spacing.sm.h),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add extra'),
                onPressed: () => _showAddAddonDialog(theme),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddAddonDialog(ThemeData theme) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Add-on'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name *'),
              textCapitalization: TextCapitalization.words,
            ),
            Gap(Spacing.sm.h),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Price *'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            Gap(Spacing.sm.h),
            TextField(
              controller: durCtrl,
              decoration: const InputDecoration(
                  labelText: 'Extra duration (minutes, optional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price =
                  (double.tryParse(priceCtrl.text.trim()) ?? 0) * 100;
              if (name.isEmpty || price <= 0) return;
              final dur = int.tryParse(durCtrl.text.trim());
              setState(() {
                _addons.add(ServiceAddonDTO(
                  id: '',
                  slotId: widget.initialService?.id ?? '',
                  name: name,
                  priceMinor: price.round(),
                  durationMinutes: (dur != null && dur > 0) ? dur : null,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    priceCtrl.dispose();
    durCtrl.dispose();
  }

  void _submitAndClose() {
    if (!_formKey.currentState!.validate()) return;

    // Resolve service type from hybrid picker.
    final serviceType = _useCustomSubType
        ? _customSubTypeController.text.trim()
        : _typeController.text.trim();
    if (serviceType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a service type')),
      );
      return;
    }

    final selectedDays = ref.read(_selectedDaysProvider);
    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day for this service'),
        ),
      );
      return;
    }

    final service = AppointmentSlotDTO(
      id: widget.initialService?.id ?? '',
      serviceName: _nameController.text.trim(),
      serviceType: serviceType,
      // User types major units (e.g. "30.00"); store as minor units (3000 kobo).
      price: ((double.tryParse(_priceController.text) ?? 0) * 100).round(),
      duration: DurationUtils.format(
        Duration(minutes: _selectedDurationMinutes),
      ),
      description:
          _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
      maxClients: _maxClients,
      slotType: 'in-person',
      daysOfWeek: selectedDays,
      selectPreferredWorker: _selectPreferredWorker,
      workerIds: _selectedWorkerIds,
      bufferBeforeMinutes: _bufferBeforeMinutes,
      bufferMinutes: _bufferMinutes,
      isOnlineBookingEnabled: _isOnlineBookingEnabled,
      pendingAddons: List.from(_addons),
    );

    widget.onSave(service);
    Navigator.pop(context);
  }
}
