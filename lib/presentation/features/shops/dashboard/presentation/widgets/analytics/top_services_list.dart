// lib/features/dashboard/presentation/widgets/top_services_list.dart
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/service_detail_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/service_analytics_header.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/service_list_item.dart';

class TopServicesList extends StatelessWidget {
  final TopServicesData data;
  final VoidCallback? onSeeAll;
  final String shopId;
  final AnalyticsPeriod peroid;
  // final Function(String serviceId)? onServiceTap;

  const TopServicesList({
    super.key,
    required this.data,
    required this.shopId,
    required this.peroid,
    this.onSeeAll,
    // this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.services.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        ServiceAnalyticsHeader(
          onSeeAll: onSeeAll,
          headerTitle: 'Top services',
          periodName: data.period.displayName,
        ),
        CardInkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service list
              ...data.services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;

                return ServiceListItem(
                  rank: index + 1,
                  isWorker: false,
                  name: service.name,
                  bookingCount: service.bookingCount,
                  percentage: service.percentage,
                  revenue: service.revenue,
                  onTap: () {
                    BottomSheetUtils.showDocumentationBottomSheet(
                      showButtons: false,
                      
                      // maxHeight: 320.h,
                      context: context,
                      widget: ServiceDetailScreen(
                        shopId: shopId,
                        slotId: service.id,
                        serviceName: service.name,
                        period: peroid,
                      ),
                    );
                  },
                  averageRating: 0,
                  profileImageUrl: '',
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CardInkWell(
      elevation: 0,
      onTap: () {},
      child: Center(
        child: EmptyStateWidget(
          icon: Icons.assessment_outlined,
          title: '',
          subtitle:
              'No service data for ${data.period.displayName.toLowerCase()}',
        ),
      ),
    );
  }
}
