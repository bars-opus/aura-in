// lib/features/shop/creation/presentation/screens/manage_services_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/enums/freelancer_category_mapper.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/draft_context_provider.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/service_selection/service_category_chips.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/service_selection/service_ticket_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/service_templates_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/appointmetn_workers_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/hours_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/services_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/utils/undo_service.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

class ManageServicesScreen extends ConsumerStatefulWidget {
  final String shopId;

  /// Set to true when used inside the freelancer creation flow so the screen
  /// reads the shop/profession type from [freelancerCreationProvider] instead
  /// of [shopCreationProvider].
  final bool freelancerMode;

  const ManageServicesScreen({
    super.key,
    required this.shopId,
    this.freelancerMode = false,
  });

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCategories(ref.read(servicesProvider));
    });
  }

  void _updateCategories(List<AppointmentSlotDTO> services) {
    final categories = services.map((s) => s.serviceName).toSet().toList();
    categories.remove('All');
    categories.sort();
    setState(() {
      _categories = ['All', ...categories];
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
    final draft = ref.watch(shopCreationProvider);
    final freelancerDraft = ref.watch(freelancerCreationProvider);
    // This is a shared creation screen. Use draftContextProvider (set to
    // freelancer by FreelancerCreationDashboard) as the source of truth rather
    // than relying on a route query param, which can be dropped on push.
    final isFreelancer =
        widget.freelancerMode ||
        ref.watch(draftContextProvider) == DraftContext.freelancer;
    // For freelancers, templates live under shop types. Resolve the freelancer's
    // profession (e.g. 'barber') to the shop category it's grouped under
    // (e.g. 'barbershop') so we can load that category's service templates.
    final shopType =
        isFreelancer
            ? (freelancerDraft.freelancerType == null
                ? null
                : FreelancerCategoryMapper.getCategoryForFreelancerType(
                  freelancerDraft.freelancerType!,
                ))
            : draft.shopType;
    final currencyCode = draft.currencyCode ?? 'USD';

    _updateCategories(services);

    final hasServices = services.isNotEmpty;
    final hasShopType = shopType != null;

    // ── No shop type set ───────────────────────────────────────────────────
    if (!hasShopType) {
      return Scaffold(
        backgroundColor: colorScheme.neutral,
        appBar: _buildAppBar(colorScheme),
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.storefront_outlined,
            title:
                widget.freelancerMode
                    ? 'Profession type not set'
                    : 'Shop type not set',
            subtitle:
                widget.freelancerMode
                    ? 'Go back to Basics and select your profession type first'
                    : 'Go back to Basics and select your shop type first',
            actionLabel: 'Go to Basics',
            onAction: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final filteredServices = _filterServices(services);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: _buildAppBar(colorScheme),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Info banner ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              Spacing.md.w,
              Spacing.sm.h,
              Spacing.md.w,
              0,
            ),
            child: SemanticContainerWidget(
              content:
                  'You can edit the templates of popular service below to make it easy to add services, or create a new one yourself.',
              icon: Icons.content_cut,
              title: 'Your Services',
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              borderColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              textTheme: theme.textTheme,
            ),
          ),

          // ── Action buttons ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
            child:
                hasServices
                    ? Column(
                      children: [
                        Gap(Spacing.md),
                        AppButton(
                          elevation: 0,
                          label: 'New service',
                          prefixIcon: Icons.add,
                          onPressed: _showAddServiceModal,
                          size: ButtonSize.small,
                          height: 40.h,
                          padding: Spacing.horizontalSm,
                        ),
                        Gap(Spacing.sm),
                        AppButton(
                          elevation: 0,
                          label: 'Templates',
                          prefixIcon: Icons.auto_awesome,
                          onPressed: _showTemplatesSheet,
                          size: ButtonSize.small,
                          height: 40.h,
                          padding: Spacing.horizontalSm,
                          variant: ButtonVariant.outline,
                        ),
                        Gap(Spacing.md),
                      ],
                    )
                    : Column(
                      children: [
                        AppButton(
                          elevation: 0,
                          label: 'Create service',
                          prefixIcon: Icons.add,
                          onPressed: _showAddServiceModal,
                          size: ButtonSize.small,
                          width: double.infinity,
                          height: 40.h,
                          padding: Spacing.horizontalMd,
                        ),
                        Gap(Spacing.lg),
                        AppDivider(),
                        Gap(Spacing.md),
                        Text(
                          'Templates',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
          ),

          // ── Category chips (only when services exist) ─────────────────
          if (hasServices && _categories.isNotEmpty)
            ServiceCategoryChips(
              categories: _categories,
              showAllOption: false,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),

          // ── Body: service list or inline templates ────────────────────
          Expanded(
            child:
                hasServices
                    ? (filteredServices.isEmpty
                        ? Center(
                          child: EmptyStateWidget(
                            subtitle: 'No services in this category',
                          ),
                        )
                        : _buildServiceList(
                          filteredServices,
                          currencyCode,
                          services,
                        ))
                    : _buildInlineTemplates(shopType, draft.currencySymbol),
          ),
        ],
      ),

      bottomNavigationBar:
          hasServices
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to contacts',
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

  AppBar _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddServiceModal,
          tooltip: 'Add Service',
        ),
      ],
    );
  }

  Widget _buildServiceList(
    List<AppointmentSlotDTO> filtered,
    String currencyCode,
    List<AppointmentSlotDTO> all,
  ) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: EdgeInsets.all(Spacing.md.h),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final service = filtered[index];
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
                showWorkerIndicator: service.selectPreferredWorker,
              ),
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
                      onTap: () => _deleteServiceConfirmById(service.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Inline template browser shown when no services exist yet.
  Widget _buildInlineTemplates(String shopType, String? currencySymbol) {
    return ServiceTemplatesSheet(
      shopType: shopType,
      currencySymbol: currencySymbol,
      onTemplateSelected: (prefilled) => _editServiceById(prefilled),
      inline: true,
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

  List<AppointmentSlotDTO> _filterServices(List<AppointmentSlotDTO> services) {
    if (_selectedCategory == 'All') return services;
    return services.where((s) => s.serviceName == _selectedCategory).toList();
  }

  /// Effective shop type used for templates + the service-name catalog. For
  /// freelancers, resolves their profession to the shop category it's grouped
  /// under (see [FreelancerCategoryMapper]).
  String? _resolveShopType() {
    final isFreelancer =
        widget.freelancerMode ||
        ref.read(draftContextProvider) == DraftContext.freelancer;
    if (isFreelancer) {
      final type = ref.read(freelancerCreationProvider).freelancerType;
      return type == null
          ? null
          : FreelancerCategoryMapper.getCategoryForFreelancerType(type);
    }
    return ref.read(shopCreationProvider).shopType;
  }

  void _showTemplatesSheet() {
    final shopType = _resolveShopType();
    if (shopType == null) {
      context.showErrorSnackbar('Set your type in Basics first');
      return;
    }
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 600.h,
      widget: ServiceTemplatesSheet(
        shopType: shopType,
        currencySymbol: ref.read(shopCreationProvider).currencySymbol,
        onTemplateSelected: (prefilled) => _editServiceById(prefilled),
      ),
    );
  }

  void _showAddServiceModal() {
    final workersAsync = ref.read(shopActiveWorkersProvider(widget.shopId));
    final lastService = ref.read(lastSavedServiceProvider);

    void openForm(List<dynamic> workers) {
      if (!mounted) return;
      BottomSheetUtils.showDocumentationBottomSheet(
        context: context,
        maxHeight: 700.h,
        widget: ServiceFormModal(
          prefillService: lastService,
          onSave: (service) {
            ref.read(servicesProvider.notifier).addService(service);
          },
          shopId: widget.shopId,
          availableWorkers: workers.cast(),
          availableHours: ref.read(hoursProvider),
          currencySymbol: ref.read(shopCreationProvider).currencySymbol,
          shopType: _resolveShopType(),
        ),
      );
    }

    workersAsync.when(
      data: openForm,
      loading: () => context.showLoadingSnackbar('Loading workers...'),
      error: (_, __) => openForm(const []),
    );
  }

  void _editServiceById(AppointmentSlotDTO service) {
    final workersAsync = ref.read(shopActiveWorkersProvider(widget.shopId));

    void openForm(List<dynamic> workers) {
      if (!mounted) return;
      BottomSheetUtils.showDocumentationBottomSheet(
        context: context,
        maxHeight: 700.h,
        widget: ServiceFormModal(
          initialService: service,
          onSave: (updatedService) {
            final existsInState = ref
                .read(servicesProvider)
                .any((s) => s.id == service.id);
            if (!existsInState || service.id.isEmpty) {
              ref.read(servicesProvider.notifier).addService(updatedService);
            } else {
              ref
                  .read(servicesProvider.notifier)
                  .updateServiceById(service.id, updatedService);
            }
          },
          shopId: widget.shopId,
          availableWorkers: workers.cast(),
          availableHours: ref.read(hoursProvider),
          currencySymbol: ref.read(shopCreationProvider).currencySymbol,
          shopType: _resolveShopType(),
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

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/manageContacts');
  }
}
