// lib/features/freelancer/presentation/screens/freelancer_details_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/widgets/freelancer_details_content.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/widgets/freelancer_details_info_section.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/client/service_selection_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_loading_schimmer.dart';

// lib/features/freelancer/presentation/screens/freelancer_details_screen.dart

/// Screen displaying detailed freelancer profile
class FreelancerDetailsScreen extends ConsumerStatefulWidget {
  final String freelancerId;
  final String freelancurrency;

  final String coverImageUrl;

  const FreelancerDetailsScreen({
    super.key,
    required this.freelancerId,
    required this.freelancurrency,
    required this.coverImageUrl,
  });

  @override
  ConsumerState<FreelancerDetailsScreen> createState() =>
      _FreelancerDetailsScreenState();
}

class _FreelancerDetailsScreenState
    extends ConsumerState<FreelancerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AppTabItem> _tabs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabs = _getInitialTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  List<AppTabItem> _getInitialTabs() {
    return [
      AppTabItem(label: 'Info', content: const SizedBox()),
      AppTabItem(label: 'Services', content: const SizedBox()),
      AppTabItem(label: 'Portfolio', content: const SizedBox()),
      AppTabItem(label: 'Reviews', content: const SizedBox()),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final freelancerAsync = ref.watch(
      freelancerDetailsProvider(widget.freelancerId),
    );

    return freelancerAsync.when(
      data: (freelancerDetails) {
        if (freelancerDetails == null) {
          return _buildErrorWidget('Freelancer not found');
        }

        // Update tabs with real content after data loads (only once)
        if (_tabs.first.content is SizedBox) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _tabs = [
                  AppTabItem(
                    label: 'Info',
                    content: FreelancerDetailsInfoSection(
                      freelancer: freelancerDetails,
                    ),
                  ),
                  AppTabItem(
                    label: 'Services',
                    content: Padding(
                      padding: EdgeInsets.all(Spacing.md),
                      child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: ServiceSelectionScreen(
                          shopId: widget.freelancerId,
                          shopCurrency: widget.freelancurrency,
                        ),
                      ),
                    ),
                  ),
                  AppTabItem(label: 'Buy', icon: null, content: Container()),
                  AppTabItem(label: 'Works', icon: null, content: Container()),
                ];
              });
            }
          });
        }

        return FreelancerDetailsContent(
          freelancerDetails: freelancerDetails,
          tabController: _tabController,
          tabs: _tabs,
          coverImageUrl: widget.coverImageUrl,
        );
      },
      loading:
          () => ShopDetailsLoadingSchimmer(coverImageUrl: widget.coverImageUrl),
      error: (error, _) => _buildErrorWidget(error.toString()),
    );
  }

  Widget _buildErrorWidget(String error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: ErrorStateWidget(
          title: '',
          subtitle: 'Failed to load freelancer details: $error',
          onPrimaryAction:
              () => ref.invalidate(
                freelancerDetailsProvider(widget.freelancerId),
              ),
        ),
      ),
    );
  }
}
