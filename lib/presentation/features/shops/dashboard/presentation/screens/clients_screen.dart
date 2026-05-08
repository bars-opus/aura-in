// lib/features/dashboard/presentation/screens/clients_screen.dart

import 'package:nano_embryo/core/widgets/search_text_field.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/clients/client_profile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/client_management_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/client_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  final String shopId;

  const ClientsScreen({super.key, required this.shopId});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      clientManagementControllerProviderFamily(
        ClientManagementParams(shopId: widget.shopId),
      ),
    );

   

    return Scaffold(

      body: CardInkWell(
        elevation: 0,

        margin: EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
              child: SearchFormField(
                controller: _searchController,
                autofocus: false,
                hintText: 'Search by name...',
                onChanged: (query) {
                  ref
                      .read(
                        clientManagementControllerProviderFamily(
                          ClientManagementParams(shopId: widget.shopId),
                        ).notifier,
                      )
                      .setSearchQuery(query);
                },
              ),
            ),
            Gap(Spacing.xl.h),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ClientManagementState state) {
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
          subtitle: 'Failed to load clients',
          onPrimaryAction:
              () =>
                  ref
                      .read(
                        clientManagementControllerProviderFamily(
                          ClientManagementParams(shopId: widget.shopId),
                        ).notifier,
                      )
                      .refresh(),
        ),
      );
    }
    final filteredClients = state.filteredClients;
    if (filteredClients.isEmpty) {
      final hasSearch =
          state.searchQuery != null && state.searchQuery!.isNotEmpty;
      return Center(
        child: EmptyStateWidget(
          icon: Icons.people_outline,
          title: hasSearch ? 'No Clients Match' : 'No Clients Yet',
          subtitle:
              hasSearch
                  ? 'No clients match "${state.searchQuery}"'
                  : 'Clients will appear here when they make their first booking.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          () =>
              ref
                  .read(
                    clientManagementControllerProviderFamily(
                      ClientManagementParams(shopId: widget.shopId),
                    ).notifier,
                  )
                  .refresh(),
      child: ListView.builder(
        itemCount: filteredClients.length,
        itemBuilder: (context, index) {
          final client = filteredClients[index];
          return ClientCard(client: client);
        },
      ),
    );
  }
}
