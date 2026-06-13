// lib/features/shop/creation/presentation/screens/manage_services_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/duration_utils.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/widgets/feedback/confirmation_dialog.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/service_selection/service_category_chips.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/service_selection/service_ticket_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/appointmetn_workers_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/hours_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/services_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/utils/undo_service.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/home/widgets/semantic_container_widget.dart';

class ManageServicesScreen extends ConsumerStatefulWidget {
  final String shopId;
  const ManageServicesScreen({super.key, required this.shopId});

  @override
  ConsumerState<ManageServicesScreen> createState() =>
      _ManageServicesScreenState();
}

class _ManageServicesScreenState extends ConsumerState<ManageServicesScreen> {
  String _selectedCategory = 'All';
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    // Initial update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCategories(ref.read(servicesProvider));
    });
  }

  void _updateCategories(List<AppointmentSlotDTO> services) {
    // Group by service name (the main service category)
    final categories = services.map((s) => s.serviceName).toSet().toList();
    categories.remove('All');
    categories.sort();
    setState(() {
      _categories = ['All', ...categories];
      // Reset selected category if current category no longer exists
      if (_selectedCategory != 'All' &&
          !categories.contains(_selectedCategory)) {
        _selectedCategory = 'All';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyCode = ref.watch(
      shopCreationProvider.select((d) => d.currencyCode ?? 'USD'),
    );

    // Update categories when services change
    _updateCategories(services);

    final filteredServices = _filterServices(services);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServiceModal,
            tooltip: 'Add Service',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Padding(
            padding: EdgeInsets.all(Spacing.md.h),
            child: SemanticContainerWidget(
              content:
                  'Add at least one service to continue. You can add more later.',
              icon: Icons.content_cut,
              title: 'Your Services',
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              borderColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              textTheme: theme.textTheme,
            ),
          ),

          // Category chips
          if (services.isNotEmpty && _categories.isNotEmpty)
            ServiceCategoryChips(
              categories: _categories,
              showAllOption: false,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

          // Services list
          Expanded(
            child:
                services.isEmpty
                    ? _buildEmptyState()
                    : filteredServices.isEmpty
                    ? Center(
                      child: EmptyStateWidget(
                        subtitle: 'No services in this category',
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(Spacing.md.h),
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        return Container(
                          key: ValueKey(service.id),
                          margin: EdgeInsets.only(bottom: Spacing.sm.h),
                          child: Stack(
                            children: [
                              ServiceTicketWidget(
                                service: service,
                                isSelected: false,
                                onTap: () => _editServiceById(service),
                                currency: currencyCode,
                                showWorkerIndicator:
                                    service.selectPreferredWorker,
                              ),
                              // Edit/Delete buttons overlay
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildActionButton(
                                      icon: Icons.edit,
                                      color: theme.colorScheme.primary,
                                      onTap: () => _editServiceById(service),
                                    ),
                                    SizedBox(width: 4.w),
                                    _buildActionButton(
                                      icon: Icons.delete,
                                      color: theme.colorScheme.error,
                                      onTap: () =>
                                          _deleteServiceConfirmById(service.id),
                                    ),
                                    if (services.length > 1)
                                      _buildActionButton(
                                        icon: Icons.drag_handle,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.3),
                                        onTap: null,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),

          // Continue button (only when services exist)

          // SafeArea(
          //   child: Padding(
          //     padding: EdgeInsets.all(Spacing.md.h),
          //     child: AppButton(
          //       elevation: 0,
          //       label: 'Continue to Contacts',
          //       onPressed: _saveAndContinue,
          //       size: ButtonSize.small,
          //       width: double.infinity,
          //       padding: Spacing.horizontalMd,
          //       height: 40.h,
          //     ),
          //   ),
          // ),
        ],
      ),

      bottomNavigationBar:
          services.isNotEmpty
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child:AppButton(
                    elevation: 0,
                    label: 'Continue to contacts',
                    center: false,
                    iconData: Icons.call,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,
                    onPressed: _saveAndContinue,
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Icon(icon, size: 18.sp, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final shopType = ref.watch(shopCreationProvider.select((d) => d.shopType));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyStateWidget(
            icon: Icons.content_cut,
            title: 'No services yet',
            subtitle: 'Add your first service to get started',
            actionLabel: 'Add Service',
            onAction: _showAddServiceModal,
          ),
          if (shopType != null) ...[
            SizedBox(height: Spacing.md.h),
            Text(
              'Quick add templates for $shopType',
              style: theme.textTheme.titleSmall,
            ),
            SizedBox(height: Spacing.md.h),
            _buildTemplateSuggestions(),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplateSuggestions() {
    // You'll need to define templates based on shop type
    // This is a placeholder - implement based on your template system
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ActionChip(
          label: const Text('Haircut'),
          onPressed:
              () =>
                  _addServiceFromTemplate(_createTemplate('Haircut', 45, 30.0)),
        ),
        ActionChip(
          label: const Text('Color'),
          onPressed:
              () => _addServiceFromTemplate(_createTemplate('Color', 90, 60.0)),
        ),
        ActionChip(
          label: const Text('Blowout'),
          onPressed:
              () =>
                  _addServiceFromTemplate(_createTemplate('Blowout', 30, 25.0)),
        ),
      ],
    );
  }

  AppointmentSlotDTO _createTemplate(String name, int minutes, double majorPrice) {
    return AppointmentSlotDTO(
      id: '',
      serviceName: name,
      serviceType: '',
      duration: DurationUtils.format(Duration(minutes: minutes)),
      price: (majorPrice * 100).round(), // minor units
      slotType: 'individual',
      maxClients: 1,
      daysOfWeek: const [1, 2, 3, 4, 5],
      selectPreferredWorker: false,
      workerIds: const [],
      bufferMinutes: 0,
    );
  }

  List<AppointmentSlotDTO> _filterServices(List<AppointmentSlotDTO> services) {
    if (_selectedCategory == 'All') return services;
    return services.where((s) => s.serviceName == _selectedCategory).toList();
  }

  void _showAddServiceModal() {
    final workersAsync = ref.read(shopActiveWorkersProvider(widget.shopId));

    workersAsync.when(
      data: (workers) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ServiceFormModal(
                    onSave: (service) {
                      ref.read(servicesProvider.notifier).addService(service);
                    },
                    shopId: widget.shopId,
                    availableWorkers: workers,
                    availableHours: ref.read(hoursProvider),
                  ),
            ),
          );

          // BottomSheetUtils.showDocumentationBottomSheet(
          //   context: context,
          //   maxHeight: 650.h,
          // widget: ServiceFormModal(
          //   onSave: (service) {
          //     ref.read(servicesProvider.notifier).addService(service);
          //   },
          //   shopId: widget.shopId,
          //   availableWorkers: workers,
          // ),
          // );
        }
      },
      loading: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Loading workers...')));
      },
      error: (error, _) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ServiceFormModal(
                    onSave: (service) {
                      ref.read(servicesProvider.notifier).addService(service);
                    },
                    shopId: widget.shopId,
                    availableWorkers: const [],
                    availableHours: ref.read(hoursProvider),
                  ),
            ),
          );

          // BottomSheetUtils.showDocumentationBottomSheet(
          //   context: context,
          //   widget: ServiceFormModal(
          //     onSave: (service) {
          //       ref.read(servicesProvider.notifier).addService(service);
          //     },
          //     shopId: widget.shopId,
          //     availableWorkers: const [],
          //   ),
          // );
        }
      },
    );
  }

  void _editServiceById(AppointmentSlotDTO service) {
    final workersAsync = ref.read(shopActiveWorkersProvider(widget.shopId));

    void openForm(List<dynamic> workers) {
      if (!mounted) return;
      BottomSheetUtils.showDocumentationBottomSheet(
        context: context,
        maxHeight: 650.h,
        widget: ServiceFormModal(
          initialService: service,
          onSave: (updatedService) {
            ref
                .read(servicesProvider.notifier)
                .updateServiceById(service.id, updatedService);
          },
          shopId: widget.shopId,
          availableWorkers: workers.cast(),
          availableHours: ref.read(hoursProvider),
        ),
      );
    }

    workersAsync.when(
      data: openForm,
      loading: () => openForm(const []),
      error: (_, __) => openForm(const []),
    );
  }

  void _deleteServiceConfirmById(String serviceId) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 400,
      widget: ConfirmationDialog(
        type: ConfirmationType.warning,
        title: 'Delete Service?',
        message: 'Are you sure you want to delete this service?',
        confirmText: 'Delete',
        onConfirm: () {
          ref.read(servicesProvider.notifier).removeServiceById(serviceId);
          UndoService.showUndoSnackbar(
            context: context,
            message: 'Service deleted',
            onUndo: () => ref.read(servicesProvider.notifier).undo(),
          );
        },
      ),
    );
  }

  void _addServiceFromTemplate(AppointmentSlotDTO template) {
    ref.read(servicesProvider.notifier).addService(template);
  }

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/manageContacts');
  }
}
