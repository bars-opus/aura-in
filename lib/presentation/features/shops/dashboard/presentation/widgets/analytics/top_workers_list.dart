// lib/features/dashboard/presentation/widgets/top_workers_list.dart
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_performance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/worker_bookings_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/service_analytics_header.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/service_list_item.dart';

class TopWorkersList extends StatelessWidget {
  final TopWorkersData data;
  final VoidCallback? onSeeAll;

  const TopWorkersList({
    super.key,
    required this.data,
    this.onSeeAll,
    
  });

  @override
  Widget build(BuildContext context) {
    if (data.workers.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        ServiceAnalyticsHeader(
          onSeeAll: onSeeAll,
          headerTitle: 'Top workers',
          periodName: data.period.displayName,
        ),
        CardInkWell(
          // padding: const EdgeInsets.all(0),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service list
              ...data.workers.asMap().entries.map((entry) {
                final index = entry.key;
                final worker = entry.value;
                final isLast = index == data.workers.length - 1;

                return ServiceListItem(
                  rank: index + 1,
                  showDivider: !isLast,
                  isWorker: true,
                  name: worker.name,
                  bookingCount: worker.bookingCount,
                  averageRating: worker.averageRating ?? 0,
                  percentage: 0.0,
                  revenue: worker.revenue,
                  onTap: () {
                    BottomSheetUtils.showDocumentationBottomSheet(
                      showButtons: false,
                      // maxHeight: 320.h,
                      context: context,
                      widget: WorkerBookingsScreen(
                        workerId: worker.id,
                        workerName: worker.name,
                        period: data.period
                      ),
                    );
                  },
                  profileImageUrl: worker.profileImageUrl,
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
          icon: Icons.people_outline,
          title: '',
          subtitle:
              'No worker data for ${data.period.displayName.toLowerCase()}',
        ),
      ),
    );
  }
}
