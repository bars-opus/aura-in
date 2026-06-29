import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/presentation/screens/calendar_screen.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/presentation/screens/daily_schedule_screen.dart';

class ShopScheduleHub extends ConsumerStatefulWidget {
  final String shopId;
  final String accountType;
  // final String currentUserId;

  const ShopScheduleHub({
    super.key,
    required this.shopId,
    required this.accountType,
  });

  @override
  ConsumerState<ShopScheduleHub> createState() => _ShopScheduleHubState();
}

class _ShopScheduleHubState extends ConsumerState<ShopScheduleHub>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final tabs = [
      AppTabItem(
        label: loc.scheduleTabDaily,
        // icon: Icons.view_day,
        content: DailyScheduleScreen(
          shopId: widget.shopId,
          key: const ValueKey('daily_schedule'),
        ),
      ),
      AppTabItem(
        label: loc.scheduleTabMonthly,
        // icon: Icons.calendar_month,
        content: MediaQuery.removePadding(
          removeTop: true,
          context: context,

          child: CalendarScreen(
            currentUserId: widget.shopId,
            isShopOwner: true,
            key: const ValueKey('monthly_calendar'),
            isCurrentUser: true,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          loc.scheduleTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: Spacing.md.w),
            child: AppIconButton(
              icon: Icons.search,
              onPressed: () => context.push('/search'),
            ),
          ),
        ],
      ),
      body: TabsWithContent(
        useNestedScrollMode: false,
        tabs: tabs.toList(),
        initialIndex: 0,
        scrollable: false,
        showContent: true,
      ),
    );
  }
}
