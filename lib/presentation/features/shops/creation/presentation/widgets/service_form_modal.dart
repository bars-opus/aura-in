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
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/service_addon_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_addons_provider.dart';

final _selectedDaysProvider = StateProvider<List<int>>((ref) => []);

/// Two-level map: shop type → service name → list of style/variant suggestions.
/// Service names are the broad offerings clients filter by on the booking screen.
/// Variants are the specific styles the owner can optionally attach to a service.
const _kServiceCatalog = <String, Map<String, List<String>>>{
  'Salon': {
    'Haircut': ['Trim', 'Layers', 'Bob', 'Pixie', 'Fringe', 'Afro Shape'],
    'Hair Colour': ['Full Colour', 'Balayage', 'Highlights', 'Ombre', 'Toner'],
    'Braids': ['Box Braids', 'Cornrows', 'Senegalese Twist', 'Locs', 'Fulani'],
    'Weave & Wig': [
      'Weave Install',
      'Wig Install',
      'Closure Install',
      'Frontal',
    ],
    'Treatment': ['Relaxer', 'Keratin', 'Brazilian Blowout', 'Deep Condition'],
    'Styling': ['Blowout', 'Silk Press', 'Natural Styling', 'Updo'],
  },
  'Barbershop': {
    'Haircut': [
      'Fade',
      'Low Fade',
      'High Fade',
      'Skin Fade',
      'Taper',
      'Afro Trim',
      'Kids Cut',
    ],
    'Beard': ['Beard Trim', 'Beard Line-Up', 'Full Beard Shape', 'Goatee'],
    'Shave': ['Hot Towel Shave', 'Straight Razor Shave', 'Head Shave'],
    'Design': ['Design Cut', 'Shape-Up', 'Edge-Up', 'Lineup'],
  },
  'Spa': {
    'Massage': [
      'Swedish',
      'Deep Tissue',
      'Hot Stone',
      'Aromatherapy',
      'Sports',
      'Foot',
    ],
    'Facial': [
      'Classic Facial',
      'Hydrafacial',
      'Anti-Ageing',
      'Brightening',
      'Acne',
    ],
    'Body': ['Body Wrap', 'Body Scrub', 'Exfoliation', 'Tan'],
    'Hair Removal': ['Waxing', 'Threading', 'Sugaring'],
    'Lashes & Brows': [
      'Eyelash Extensions',
      'Eyebrow Threading',
      'Brow Tint',
      'Lash Lift',
    ],
  },
  'Nail Salon': {
    'Manicure': [
      'Classic',
      'Gel',
      'Acrylic',
      'Dip Powder',
      'French',
      'Ombre',
      'Chrome',
    ],
    'Pedicure': ['Classic', 'Gel', 'Spa Pedicure', 'French'],
    'Nail Art': ['Nail Art', 'Nail Repair', '3D Art', 'Stamping'],
  },
};

class ServiceFormModal extends ConsumerStatefulWidget {
  final AppointmentSlotDTO? initialService;

  /// When set (and [initialService] is null), pre-fills operational fields
  /// (price, duration, buffers, max clients, worker toggle) from the last
  /// saved service so the owner doesn't have to re-enter repeated values.
  final AppointmentSlotDTO? prefillService;
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
    this.prefillService,
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
  bool _useCustomName = false;
  late TextEditingController _customNameController;
  bool _useCustomVariant = false;
  late TextEditingController _customVariantController;

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
    // When editing, source everything from initialService.
    // When adding new, source operational fields from prefillService (last saved)
    // so the owner doesn't re-enter price/duration/buffers for similar services.
    final edit = widget.initialService;
    final prefill = widget.prefillService;

    _nameController = TextEditingController(text: edit?.serviceName ?? '');
    _typeController = TextEditingController(text: edit?.serviceType ?? '');
    _priceController = TextEditingController(
      text:
          edit != null
              ? (edit.price / 100).toStringAsFixed(2)
              : prefill != null && prefill.price > 0
              ? (prefill.price / 100).toStringAsFixed(2)
              : '',
    );
    _descriptionController = TextEditingController(
      text: edit?.description ?? '',
    );
    _selectedDurationMinutes =
        edit != null
            ? DurationUtils.parse(edit.duration).inMinutes
            : prefill != null
            ? DurationUtils.parse(prefill.duration).inMinutes
            : 30;
    _maxClients = edit?.maxClients ?? prefill?.maxClients ?? 1;
    _bufferBeforeMinutes =
        edit?.bufferBeforeMinutes ?? prefill?.bufferBeforeMinutes ?? 0;
    _bufferMinutes = edit?.bufferMinutes ?? prefill?.bufferMinutes ?? 0;
    _selectPreferredWorker =
        edit?.selectPreferredWorker ?? prefill?.selectPreferredWorker ?? false;
    _isOnlineBookingEnabled = edit?.isOnlineBookingEnabled ?? true;
    _selectedWorkerIds = List.from(edit?.workerIds ?? []);

    // Name chips from catalog keys. Detect custom name on edit or prefill.
    _customNameController = TextEditingController();
    final catalogNames =
        (_kServiceCatalog[widget.shopType] ?? {}).keys.toList();
    // For a new service pre-filled from the last save, seed the name chip
    // selection from prefill so the owner sees the same category pre-selected.
    final existingName = edit?.serviceName ?? prefill?.serviceName ?? '';
    if (existingName.isEmpty) {
      // Truly blank new service — show custom fields immediately.
      _useCustomName = true;
      _useCustomVariant = true;
    } else if (catalogNames.isNotEmpty && catalogNames.contains(existingName)) {
      // Name matches a catalog chip — select it (works for both edit & prefill).
      _nameController.text = existingName;
      _useCustomName = false;
    } else {
      // Name is custom — show the free-text field pre-filled.
      _useCustomName = true;
      _customNameController.text = existingName;
    }

    // Variant chips from catalog. Detect custom variant on edit.
    // For a prefill we intentionally leave the variant blank so the owner
    // picks a new style (the whole point of a new service in the same category).
    _customVariantController = TextEditingController();
    final existingType = edit?.serviceType ?? '';
    final catalogVariants =
        (_kServiceCatalog[widget.shopType] ?? {})[existingName] ?? [];
    if (edit != null &&
        existingType.isNotEmpty &&
        catalogVariants.isNotEmpty &&
        !catalogVariants.contains(existingType)) {
      _useCustomVariant = true;
      _customVariantController.text = existingType;
    } else if (edit == null) {
      // New service — variant always starts blank so owner picks a fresh style.
      _useCustomVariant = catalogVariants.isEmpty;
    }

    // Initialize selected days.
    // For a saved service: restore its days exactly.
    // For a new service: leave the provider empty so _hydrateFromProp
    // can pre-select all open days without racing.
    final initialDays = widget.initialService?.daysOfWeek ?? [];
    if (initialDays.isNotEmpty) {
      Future.microtask(() {
        ref.read(_selectedDaysProvider.notifier).state = initialDays;
      });
    }

    _hydrateFromProp();
    _loadAddons();
  }

  Future<void> _loadAddons() async {
    // Prefer add-ons already carried on the DTO (creation flow keeps them in
    // `pendingAddons` in-memory until the shop is saved). Only hit the DB when
    // the DTO has none — that's the published-shop edit path where add-ons live
    // in the service_addons table.
    final pending =
        widget.initialService?.pendingAddons ??
        widget.prefillService?.pendingAddons ??
        const <ServiceAddonDTO>[];
    if (pending.isNotEmpty) {
      if (mounted) setState(() => _addons = List.from(pending));
      return;
    }

    final slotId = widget.initialService?.id ?? '';
    if (slotId.isEmpty) return;
    final loaded =
        await ref.read(serviceAddonsRepoProvider).fetchBySlotId(slotId);
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

    // Pre-select all open days for new services (initialService has no days).
    if (widget.initialService == null ||
        widget.initialService!.daysOfWeek.isEmpty) {
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
    _customNameController.dispose();
    _customVariantController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Map<String, List<String>> _getCatalog() =>
      _kServiceCatalog[widget.shopType] ?? {};

  List<String> _getVariantsForName(String name) => _getCatalog()[name] ?? [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEditing = widget.initialService != null;
    final workers = widget.availableWorkers ?? [];
    final selectedDays = ref.watch(_selectedDaysProvider);
    String hearder = isEditing ? 'Edit' : 'Add';
    return Scaffold(
      body: ListView(
        children: [
          BottomSheetHeader(title: ''),
          SemanticContainerWidget(
            content:
                'Use this form to add a new servie to your shop. If you need more clarifications, read more.',
            icon: Icons.content_cut,
            title: 'Tap here to read more.',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
            trailingIcon: Icons.info_outline,
          ),
          Gap(Spacing.md.h),

          // Show error if no opening hours set
          if (_hasHoursError)
            CardInkWell(
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
                    margin: const EdgeInsets.only(bottom: Spacing.sm),

                    child: _buildSubTypePicker(theme),
                  ),
                  CardInkWell(
                    margin: const EdgeInsets.only(bottom: Spacing.sm),
                    child: AppTextFormField(
                      controller: _descriptionController,
                      label: 'Description (optional)',
                      hintText:
                          'A clean, modern style where the hair gradually tapers down from just above the ears and the neckline',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                    ),
                  ),

                  CardInkWell(
                    margin: const EdgeInsets.only(bottom: Spacing.sm),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppTextFormField(
                                controller: _priceController,
                                hintText: 'e.g., 50, 100, 120',
                                label:
                                    widget.currencySymbol != null
                                        ? 'Price (${widget.currencySymbol})'
                                        : 'Price',

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
                        Gap(Spacing.sm.h),
                        AppDivider(),
                        Gap(Spacing.sm.h),
                        if (!_selectPreferredWorker) ...[
                          _buildMaxClientsDropdown(theme),
                          Gap(Spacing.sm.h),
                          AppDivider(),
                          Gap(Spacing.sm.h),
                        ],

                        _buildWorkerToggle(theme),
                        if (_selectPreferredWorker) ...[
                          Gap(Spacing.sm.h),
                          _buildWorkerSelector(theme, workers),
                        ],
                      ],
                    ),
                  ),

                  CardInkWell(
                    margin: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Column(
                      children: [
                        Gap(Spacing.md.h),
                        _buildBufferBeforeStepper(theme),
                        Gap(Spacing.sm.h),
                        AppDivider(),
                        Gap(Spacing.sm.h),
                        _buildBufferStepper(theme),

                        Gap(Spacing.sm.h),
                        AppDivider(),
                        Gap(Spacing.sm.h),
                        _buildOnlineBookingToggle(theme),
                        Gap(Spacing.sm.h),
                        _buildDepositBanner(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildAddonsSection(theme),
            CardInkWell(
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              child: _buildDaySelector(theme, selectedDays),
            ),
            Gap(Spacing.md.h),

            AppButton(
              elevation: 0,

              label: isEditing ? 'Update' : 'Add',
              onPressed: _submitAndClose,

              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 40.h,
            ),
            Gap(Spacing.sm.h),
            AppButton(
              height: 40.h,
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              padding: Spacing.horizontalMd,
              variant: ButtonVariant.outline,
              size: ButtonSize.small,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationDropdown(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    // Include the current value in case it came from a template with a
    // duration not in the preset list (e.g. 300 min from the DB).
    final durationOptions = <int>[
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
    if (!durationOptions.contains(_selectedDurationMinutes)) {
      durationOptions.add(_selectedDurationMinutes);
      durationOptions.sort();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timer,
              size: 16.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(width: 4.w),
            Text(
              'Duration',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedDurationMinutes,
            isDense: true,
            icon: Icon(
              Icons.expand_more,
              size: 18.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            items:
                durationOptions.map((minutes) {
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text(
                      DurationUtils.formatForDisplay(
                        Duration(minutes: minutes),
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (v) => setState(() => _selectedDurationMinutes = v!),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxClientsDropdown(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 18.sp,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                SizedBox(width: Spacing.xs.w),
                Text(
                  'Max Clients per Slot',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            MiniContainerIndicator(
              color: colorScheme.primary,
              text: _maxClients == 1 ? '1 person' : '$_maxClients people',
              fontSize: 14.sp,
            ),
          ],
        ),
        Slider(
          value: _maxClients.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() => _maxClients = v.round());
          },
        ),
      ],
    );
  }

  Widget _buildWorkerToggle(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Allow customer to select a specific worker',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
        ),
        AppToggleSwitch(
          toggleValue: _selectPreferredWorker,
          onToggleChanged: (value) {
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
    final colorScheme = theme.colorScheme;
    if (workers.isEmpty) {
      return SemanticContainerWidget(
        content: 'No active workers. Invite workers from Workers Management.',
        icon: Icons.warning_amber_outlined,
        title: '',
        backgroundColor: colorScheme.error.withOpacity(0.1),
        borderColor: colorScheme.error,
        iconColor: colorScheme.error,
        textTheme: theme.textTheme,
      );

      //  Container(
      //   padding: EdgeInsets.all(Spacing.sm.h),
      //   decoration: BoxDecoration(
      //     color: Colors.orange.withOpacity(0.1),
      //     borderRadius: BorderRadius.circular(8.r),
      //   ),
      //   child: Row(
      //     children: [
      //       Icon(Icons.warning, color: Colors.orange, size: 16.sp),
      //       SizedBox(width: Spacing.sm.w),
      //       Expanded(
      //         child: Text(
      //           'No active workers. Invite workers from Workers Management.',
      //           style: theme.textTheme.bodySmall,
      //         ),
      //       ),
      //     ],
      //   ),
      // );
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
    final catalog = _getCatalog();
    final catalogNames = catalog.keys.toList();
    final hasCatalog = catalogNames.isNotEmpty;
    final selectedName = _useCustomName ? null : _nameController.text;
    final variants = _getVariantsForName(selectedName ?? '');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: service name chips ─────────────────────────────────────
        if (hasCatalog) ...[
          Text('Service', style: theme.textTheme.labelLarge),
          Gap(Spacing.xs.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              ...catalogNames.map(
                (name) => AppFilterChip(
                  label: name,
                  selected: selectedName == name,
                  onSelected:
                      (_) => setState(() {
                        _nameController.text = name;
                        _typeController.clear();
                        _useCustomName = false;
                      }),
                  selectedColor: colorScheme.primary,
                  backgroundColor: colorScheme.background,
                  labelColor: colorScheme.onSurface.withOpacity(0.7),
                  borderWidth: 0.3,
                ),
              ),

              AppFilterChip(
                label: 'Custom…',
                selected: _useCustomName,
                onSelected:
                    (_) => setState(() {
                      _useCustomName = true;
                      _nameController.text = '';
                      _typeController.clear();
                    }),
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.background,
                labelColor: colorScheme.onSurface.withOpacity(0.7),
                borderWidth: 0.3,
              ),
            ],
          ),
        ],
        if (_useCustomName || !hasCatalog) ...[
          Gap(Spacing.sm.h),
          AppTextFormField(
            controller: _customNameController,
            label: 'Service name',
            hintText: 'e.g., Haircut, Tattoo, Massage',
            prefixIcon: Icons.content_cut,
            onChanged: (v) => setState(() => _nameController.text = v),
            validator:
                (v) =>
                    (v == null || v.isEmpty)
                        ? 'Service name is required'
                        : null,
          ),
        ],
        if (!_useCustomName && hasCatalog && _nameController.text.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: Spacing.xs.h),
            child: Text(
              'Select a service name above',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),

        // ── Row 2: variant chips (shown once a catalog name is picked) ────
        if (variants.isNotEmpty || _useCustomName) ...[
          Gap(Spacing.sm.h),
          AppDivider(),
          Gap(Spacing.sm.h),
          if (!_useCustomVariant && !_useCustomName)
            Text('Style / Variant', style: theme.textTheme.labelLarge),
          if (!_useCustomVariant && !_useCustomName) Gap(Spacing.xs.h),
          if (variants.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: [
                ...variants.map(
                  (v) => AppFilterChip(
                    label: v,
                    selected: !_useCustomVariant && _typeController.text == v,
                    onSelected:
                        (_) => setState(() {
                          _typeController.text = v;
                          _useCustomVariant = false;
                          _customVariantController.clear();
                        }),
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.background,
                    labelColor: colorScheme.onSurface.withOpacity(0.7),
                    borderWidth: 0.3,
                  ),
                ),

                AppFilterChip(
                  label: 'Custom…',
                  selected: _useCustomVariant,
                  onSelected:
                      (_) => setState(() {
                        _useCustomVariant = true;
                        _typeController.clear();
                      }),
                  selectedColor: colorScheme.primary,
                  backgroundColor: colorScheme.background,
                  labelColor: colorScheme.onSurface.withOpacity(0.7),
                  borderWidth: 0.3,
                ),
              ],
            ),
          if (_useCustomVariant || _useCustomName) ...[
            Gap(Spacing.sm.h),
            AppTextFormField(
              controller: _customVariantController,
              label: 'Style / Variant',
              hintText: 'e.g., Low Fade, Black & White, Deep Tissue',
              prefixIcon: Icons.style_outlined,
              onChanged: (v) => setState(() => _typeController.text = v),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Style / Variant is required'
                          : null,
            ),
          ],
          if (!_useCustomVariant &&
              (variants.isNotEmpty) &&
              _typeController.text.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: Spacing.xs.h),
              child: Text(
                'Select a style above',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildBufferBeforeStepper(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    // Steps: 0, 5, 10, 15, 30 → mapped to slider index 0-4
    const steps = [0, 5, 10, 15, 30];
    final idx = steps.indexOf(
      steps.contains(_bufferBeforeMinutes) ? _bufferBeforeMinutes : 0,
    );
    final label =
        _bufferBeforeMinutes == 0 ? 'None' : '$_bufferBeforeMinutes min';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),

                SizedBox(width: Spacing.xs.w),
                Text(
                  'Prep time before',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            MiniContainerIndicator(
              color: colorScheme.primary,
              text: label,
              fontSize: 14.sp,
            ),
          ],
        ),
        Slider(
          value: idx.toDouble(),
          min: 0,
          max: (steps.length - 1).toDouble(),
          divisions: steps.length - 1,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() => _bufferBeforeMinutes = steps[v.round()]);
          },
        ),
      ],
    );
  }

  Widget _buildOnlineBookingToggle(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accept online bookings',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
              Text(
                _isOnlineBookingEnabled
                    ? 'Clients can book this service online'
                    : 'Hidden from client booking flow',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      _isOnlineBookingEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        AppToggleSwitch(
          toggleValue: _isOnlineBookingEnabled,
          onToggleChanged: (v) => setState(() => _isOnlineBookingEnabled = v),
        ),
      ],
    );
  }

  Widget _buildDepositBanner(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return SemanticContainerWidget(
      content:
          '30% deposit required at booking — protects your time from no-shows.',
      icon: Icons.lock_outline,
      title: '',
      backgroundColor: colorScheme.warning.withOpacity(0.1),
      borderColor: colorScheme.warning,
      iconColor: colorScheme.warning,
      textTheme: theme.textTheme,
    );
  }

  Widget _buildBufferStepper(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    const steps = [0, 5, 10, 15, 30];
    final idx = steps.indexOf(
      steps.contains(_bufferMinutes) ? _bufferMinutes : 0,
    );
    final label = _bufferMinutes == 0 ? 'None' : '$_bufferMinutes min';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(width: Spacing.xs.w),
                Text(
                  'Cleanup time after',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            MiniContainerIndicator(
              color: colorScheme.primary,
              text: label,
              fontSize: 14.sp,
            ),
          ],
        ),
        Slider(
          value: idx.toDouble(),
          min: 0,
          max: (steps.length - 1).toDouble(),
          divisions: steps.length - 1,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() => _bufferMinutes = steps[v.round()]);
          },
        ),
      ],
    );
  }

  Widget _buildDaySelector(ThemeData theme, List<int> selectedDays) {
    final colorScheme = theme.colorScheme;
    const dayIcons = {
      1: FontAwesomeIcons.m,
      2: FontAwesomeIcons.t,
      3: FontAwesomeIcons.w,
      4: FontAwesomeIcons.t,
      5: FontAwesomeIcons.f,
      6: FontAwesomeIcons.s,
      7: FontAwesomeIcons.s,
    };

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
            color: colorScheme.onBackground,
          ),
        ),
        Gap(Spacing.sm.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ActionChip(
              side: BorderSide(
                color: colorScheme.onBackground.withValues(alpha: 0.1),
              ),
              label: Text(
                'Select all',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
              avatar: Icon(
                Icons.select_all,
                size: 16.sp,
                color: colorScheme.onBackground,
              ),
              onPressed: () {
                ref.read(_selectedDaysProvider.notifier).state =
                    _shopHours
                        .where((h) => !h.isClosed)
                        .map((h) => h.dayOfWeek)
                        .toList();
              },
            ),
            if (selectedDays.isNotEmpty)
              ActionChip(
                side: BorderSide(color: Colors.transparent),
                label: Text(
                  'Clear',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),
                avatar: Icon(
                  Icons.clear,
                  size: 16.sp,
                  color: colorScheme.onBackground,
                ),
                onPressed: () {
                  ref.read(_selectedDaysProvider.notifier).state = [];
                },
              ),
          ],
        ),
        Gap(Spacing.sm.h),
        AppDivider(),
        Gap(Spacing.sm.h),
        Column(
          children: List.generate(7, (index) {
            final day = index + 1;
            final isOpenDay = openDays.contains(day);
            final isSelected = selectedDays.contains(day);

            void toggle() {
              HapticFeedback.selectionClick();
              if (!isOpenDay) return;
              final notifier = ref.read(_selectedDaysProvider.notifier);
              final current = ref.read(_selectedDaysProvider);
              notifier.state =
                  isSelected
                      ? current.where((d) => d != day).toList()
                      : [...current, day];
            }

            return InfoRowWidget(
              key: ValueKey(day),
              title: _dayNames[index],
              subtitle: isOpenDay ? '' : 'Shop closed on this day',
              icon: dayIcons[day] ?? FontAwesomeIcons.clock,
              iconSize: 20.h,
              onTap: toggle,
              showAvatar: false,
              showTrailingArrow: false,
              showDivider: day != 7,
              trailing:
                  isOpenDay
                      ? Checkbox(
                        value: isSelected,
                        onChanged: isOpenDay ? (_) => toggle() : null,
                        activeColor: colorScheme.primary,
                      )
                      : SizedBox.shrink(),
            );
          }),
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
    final colorScheme = theme.colorScheme;
    return CardInkWell(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRowWidget(
            subtitle: 'Optional extras clients can choose',
            title: 'Add-ons (${_addons.length})',
            icon: Icons.add_circle_outline,
            avatarRadius: 25.h,
            onTap: () => setState(() => _addonsExpanded = !_addonsExpanded),
            showAvatar: false,
            showTrailingArrow: false,
            showDivider: false,
            trailing: Icon(
              size: IconSizes.md.h,
              color: colorScheme.onBackground.withOpacity(0.3),
              _addonsExpanded ? Icons.expand_less : Icons.expand_more,
            ),
          ),

          if (_addonsExpanded) ...[
            Gap(Spacing.sm.h),
            AppDivider(),
            Gap(Spacing.sm.h),
            ..._addons.asMap().entries.map((entry) {
              final i = entry.key;
              final addon = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
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
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => setState(() => _addons.removeAt(i)),
                ),
              );
            }),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.sm.h,
              ),
              child: AppButton(
                height: 40.h,
                label: 'Add extra',
                onPressed: () => _showAddAddonDialog(theme),
                padding: Spacing.horizontalMd,
                variant: ButtonVariant.outline,
                size: ButtonSize.small,
                width: double.infinity,
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
    int selectedDurMinutes = 0; // 0 = None

    const durOptions = [0, 5, 10, 15, 20, 30, 45, 60, 90, 120];

    await showDialog<void>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
                  title: const Text('New Add-on'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextFormField(
                        controller: nameCtrl,
                        label: 'Add-on name',
                        hintText: 'e.g. Beard Line-Up, Deep Condition',
                        prefixIcon: Icons.add_circle_outline,
                      ),
                      Gap(Spacing.sm.h),
                      AppTextFormField(
                        controller: priceCtrl,
                        hintText: 'e.g., 5, 10, 20',
                        label:
                            widget.currencySymbol != null
                                ? 'Extra price (${widget.currencySymbol})'
                                : 'Extra price',
                        keyboardType: TextInputType.number,
                      ),
                      Gap(Spacing.sm.h),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16.sp,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Extra duration',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const Spacer(),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedDurMinutes,
                              isDense: true,
                              icon: Icon(Icons.expand_more, size: 18.sp),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              items:
                                  durOptions.map((m) {
                                    return DropdownMenuItem(
                                      value: m,
                                      child: Text(
                                        m == 0
                                            ? 'None'
                                            : DurationUtils.formatForDisplay(
                                              Duration(minutes: m),
                                            ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged:
                                  (v) => setDialogState(
                                    () => selectedDurMinutes = v ?? 0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final price =
                            (double.tryParse(priceCtrl.text.trim()) ?? 0) * 100;
                        if (name.isEmpty || price <= 0) return;
                        setState(() {
                          _addons.add(
                            ServiceAddonDTO(
                              id: '',
                              slotId: widget.initialService?.id ?? '',
                              name: name,
                              priceMinor: price.round(),
                              durationMinutes:
                                  selectedDurMinutes > 0
                                      ? selectedDurMinutes
                                      : null,
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );

    nameCtrl.dispose();
    priceCtrl.dispose();
  }

  void _submitAndClose() {
    // Resolve service name first — needed before form validation so we can
    // show a clear error rather than a silent return.
    final serviceName =
        _useCustomName
            ? _customNameController.text.trim()
            : _nameController.text.trim();
    if (serviceName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a service name')),
      );
      return;
    }

    // Validate price field (the only other hard-required text input).
    final rawPrice = double.tryParse(_priceController.text.trim());
    if (rawPrice == null || rawPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
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
      serviceName: serviceName,
      serviceType:
          _typeController.text.trim().isNotEmpty
              ? _typeController.text.trim()
              : null,
      price: (rawPrice * 100).round(),
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
