// lib/features/dashboard/presentation/screens/workers_screen.dart
import 'package:flutter/material.dart';
import 'package:nano_embryo/core/widgets/custom_universal_tabs.dart';
import 'package:nano_embryo/core/widgets/search_text_field.dart';

import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_profile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/attendance_registry_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/worker_detail_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/attendance/worker_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/worker_management_controller.dart';

class DashboardWorkersScreen extends ConsumerStatefulWidget {
  final String shopId;

  const DashboardWorkersScreen({super.key, required this.shopId});

  @override
  ConsumerState<DashboardWorkersScreen> createState() =>
      _DashboardWorkersScreenState();
}

class _DashboardWorkersScreenState extends ConsumerState<DashboardWorkersScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0; // Track selected tab locally

  @override
  void initState() {
    super.initState();
    // No need for TabController anymore - UniversalTabs handles it
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onAddWorker() {
    // Add worker logic
  }

  void _onWorkerTap(WorkerProfile worker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                WorkerDetailScreen(shopId: widget.shopId, worker: worker),
      ),
    );
  }

  void _onEditWorker(WorkerProfile worker) {
    // Edit worker logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(
      workerManagementControllerProviderFamily(
        WorkerManagementParams(shopId: widget.shopId),
      ),
    );

    return CardInkWell(
      elevation: 0,

      margin: EdgeInsets.all(Spacing.md),
      child: Scaffold(
        // backgroundColor: colorScheme.background,
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [],
          backgroundColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(35.h),
            child: CustomUniversalTabs(
              tabs: [
                TabItem(
                  label: 'Attendance Registry',
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_month,
                ),
                TabItem(
                  label: 'Staff List',
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                ),
              ],
              selectedIndex: _selectedTabIndex,
              onIndexChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              height: 80.h,
              iconSize: 25.sp,
              fontSize: 12.sp,
              showUnderline: true,
              showLabels: true,
              animateIconScale: true,
              showBottomBorder: true,
              padding: EdgeInsets.only(top: Spacing.md + 11),
            ),
          ),
        ),
        body: _buildTabContent(state),
      ),
    );
  }

  Widget _buildTabContent(WorkerManagementState state) {
    switch (_selectedTabIndex) {
      case 0:
        return AttendanceRegistryScreen(shopId: widget.shopId);
      case 1:
        return _buildStaffList(state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStaffList(WorkerManagementState state) {
    if (state.isLoading) {
      return ListView.separated(
        shrinkWrap: true,

        itemCount: 10,
        separatorBuilder: (_, __) => Gap(Spacing.sm.w),
        itemBuilder: (_, __) => ShopSchimmerSkeleton(height: 100.h),
      );
    }

    if (state.hasError) {
      return Center(
        child: ErrorStateWidget(
          subtitle: 'Failed to load staff',
          title: '',
          onPrimaryAction:
              () =>
                  ref
                      .read(
                        workerManagementControllerProviderFamily(
                          WorkerManagementParams(shopId: widget.shopId),
                        ).notifier,
                      )
                      .refresh(),
        ),
      );
    }

    // Search bar and staff list
    return Column(
      children: [
        Gap(Spacing.md),
        Padding(
          padding: EdgeInsets.all(Spacing.md.h),
          child: SearchFormField(
            controller: _searchController,
            autofocus: false,
            hintText: 'Search by name or specialty...',
            onChanged: (query) {
              ref
                  .read(
                    workerManagementControllerProviderFamily(
                      WorkerManagementParams(shopId: widget.shopId),
                    ).notifier,
                  )
                  .setSearchQuery(query);
            },
          ),
        ),
        Expanded(child: _buildFilteredWorkersList(state)),
      ],
    );
  }

  Widget _buildFilteredWorkersList(WorkerManagementState state) {
    final filteredWorkers = state.filteredWorkers;
    if (filteredWorkers.isEmpty) {
      final hasSearch =
          state.searchQuery != null && state.searchQuery!.isNotEmpty;
      return Center(
        child: EmptyStateWidget(
          icon: Icons.analytics_outlined,
          title: hasSearch ? 'No Staff Match' : 'No Staff Members',
          subtitle:
              hasSearch
                  ? 'No staff members match "${state.searchQuery}"'
                  : 'Add your first staff member to get started.',
          onAction: _onAddWorker,
          actionLabel: 'Add Staff',
        ),
      );
    }

    return SizedBox(
      height: filteredWorkers.length * 250,
      child: ListView.builder(
        itemCount: filteredWorkers.length,
        itemBuilder: (context, index) {
          final worker = filteredWorkers[index];
          return WorkerCard(
            worker: worker,
            onTap: () => _onWorkerTap(worker),
            onEditTap: () => _onEditWorker(worker),
          );
        },
      ),
    );
  }
}
