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

final _selectedDaysProvider = StateProvider<List<int>>((ref) => []);

class ServiceFormModal extends ConsumerStatefulWidget {
  final AppointmentSlotDTO? initialService;
  final int? index;
  final Function(AppointmentSlotDTO) onSave;
  final String? shopId;
  final List<WorkerDTO>? availableWorkers;

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
  late bool _selectPreferredWorker;
  late List<String> _selectedWorkerIds;
  List<OpeningHoursDraft> _shopHours = [];
  bool _isLoadingHours = true;
  bool _hasHoursError = false;

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
      text: widget.initialService?.price.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialService?.description ?? '',
    );
    _selectedDurationMinutes =
        widget.initialService?.duration != null
            ? DurationUtils.parse(widget.initialService!.duration).inMinutes
            : 30;
    _maxClients = widget.initialService?.maxClients ?? 1;
    _selectPreferredWorker =
        widget.initialService?.selectPreferredWorker ?? false;
    _selectedWorkerIds = List.from(widget.initialService?.workerIds ?? []);

    // Initialize selected days
    final initialDays = widget.initialService?.daysOfWeek ?? [];
    Future.microtask(() {
      ref.read(_selectedDaysProvider.notifier).state = initialDays;
    });

    _hydrateFromProp();
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
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
                          // Service Type (new field)
                          AppTextFormField(
                            controller: _typeController,
                            label: 'Service Type',
                            hintText:
                                'e.g., Afro, Fade, Box Braids, Full Color',
                            prefixIcon: Icons.label,
                            validator:
                                (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Service type is required'
                                        : null,
                          ),
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
                                  label: 'Price',
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
                        ],
                      ),
                    ),

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

  void _submitAndClose() {
    if (!_formKey.currentState!.validate()) return;

    final selectedDays = ref.read(_selectedDaysProvider);
    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day for this service'),
        ),
      );
      return;
    }

    // Debug: Print the ID to see if it's being passed
    print('🔍 Original service ID: ${widget.initialService?.id}');
    print('🔍 Service name: ${_nameController.text}');

    final service = AppointmentSlotDTO(
      id: widget.initialService?.id ?? '', // Keep existing ID if editing
      serviceName: _nameController.text.trim(), // Add trim()
      serviceType: _typeController.text.trim(),
      price: double.parse(_priceController.text),
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
      // Phase 11 locked correction 7: preserve the saved bufferMinutes
      // instead of overwriting with a hard-coded 15. The previous value
      // silently regressed every edit. ?? 0 covers the create-mode case
      // where initialService is null.
      bufferMinutes: widget.initialService?.bufferMinutes ?? 0,
    );

    print('✅ Saving service with ID: ${service.id}');
    print('✅ Service name: ${service.serviceName}');

    widget.onSave(service);
    Navigator.pop(context);
  }
}
