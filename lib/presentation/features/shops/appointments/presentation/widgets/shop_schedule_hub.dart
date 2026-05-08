import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/widgets/app_tabs.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/presentation/screens/calendar_screen.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/presentation/screens/daily_schedule_screen.dart';
import 'package:nano_embryo/presentation/home/widgets/tabs_with_content.dart';

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
        label: 'Daily',
        icon: Icons.view_day,
        content: DailyScheduleScreen(
          shopId: widget.shopId,
          key: const ValueKey('daily_schedule'),
        ),
      ),
      AppTabItem(
        label: 'Monthly',
        icon: Icons.calendar_month,
        content: CalendarScreen(
          currentUserId: widget.shopId,
          isShopOwner: true,
          key: const ValueKey('monthly_calendar'),
          isCurrentUser: true,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Shedule',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
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
