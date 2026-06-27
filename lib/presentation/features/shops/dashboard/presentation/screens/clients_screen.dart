// lib/features/dashboard/presentation/screens/clients_screen.dart

import 'package:nano_embryo/core/widgets/search_text_field.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/client_management_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/client_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

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
    final loc = AppLocalizations.of(context)!;
    final currentShop = ref.watch(currentShopProvider);
    final currencyCode = currentShop?.currency ?? '';
    final state = ref.watch(
      clientManagementControllerProviderFamily(
        ClientManagementParams(shopId: widget.shopId),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
            child: SearchFormField(
              controller: _searchController,
              autofocus: false,
              hintText: loc.clientsSearchHint,
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
          Gap(Spacing.sm.h),
          Expanded(child: _buildContent(state, currencyCode)),
        ],
      ),
    );
  }

  Widget _buildContent(ClientManagementState state, String currencyCode) {
    final loc = AppLocalizations.of(context)!;

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
          subtitle: loc.clientsLoadError,
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
          title: hasSearch ? loc.clientsNotFound : loc.clientsEmpty,
          subtitle:
              hasSearch
                  ? loc.clientsSearchEmpty(state.searchQuery ?? '')
                  : loc.clientsEmptySubtitle,
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
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        itemBuilder: (context, index) {
          final client = filteredClients[index];
          return ClientCard(client: client, currencyCode: currencyCode);
        },
      ),
    );
  }
}
