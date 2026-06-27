import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/status_widget.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client/countdown_widget.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

class ClientBookingCard extends ConsumerWidget {
  final DateTime startTime;
  final DateTime endTime;
  final String bookingId;
  final String shopCurrency;
  final String shopName;
  final String shopType;
  final String? shopLogoUrl;
  final String shopAddress;
  final String serviceName;

  /// Money in int minor units (kobo / cents). Display via [formatMoney].
  /// Checklist v3.1 P0-U 2.19 — never store money as double here.
  final int totalAmountMinor;
  final String status;
  final bool isShopOwner;
  final bool shouldPop;
  final bool showDivider;

  const ClientBookingCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.shopCurrency,
    required this.shopAddress,
    required this.bookingId,
    required this.shopType,
    required this.shopLogoUrl,
    required this.shopName,
    required this.totalAmountMinor,
    required this.serviceName,
    required this.shouldPop,
    required this.status,
    required this.isShopOwner,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveShopCurrency =
        shopCurrency.isNotEmpty
            ? shopCurrency
            : (ref.watch(currentShopProvider)?.currency ?? '');
    final amountText = formatMoney(totalAmountMinor, effectiveShopCurrency);
    final timeText = _buildTimeSummary(context);
    final locationText = _compactLocation(shopAddress);

    return CardInkWell(
      margin: EdgeInsets.only(bottom: 0),
      onTap: () {
        if (shouldPop) {
          Navigator.pop(context);
        }
        _navigateToDetail(context);
      },
      child: InfoRowWidget(
        title: serviceName,
        subtitle: locationText == null ? shopName : '$shopName\n$locationText',
        imageUrl: shopLogoUrl,
        icon: shopLogoUrl == null ? Icons.person : null,
        showDivider: false,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            StatusWidget(status: status),
            if (_showCountdown) ...[
              Gap(Spacing.sm.h),
              CountdownStreamWidget(targetDate: endTime),
            ],
          ],
        ),
        showTrailingArrow: false,
        bottomWidget: Padding(
          padding: EdgeInsets.only(top: Spacing.sm.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDivider(),
              Gap(Spacing.sm),
              Text(
                timeText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _showCountdown {
    final normalizedStatus = status.toLowerCase();
    final isUpcoming = endTime.isAfter(DateTime.now());

    return isUpcoming &&
        (normalizedStatus == 'pending' || normalizedStatus == 'confirmed');
  }

  String _buildTimeSummary(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDay = DateTime(startTime.year, startTime.month, startTime.day);
    final dayDifference = bookingDay.difference(today).inDays;

    final dayLabel = switch (dayDifference) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ => localizations.formatShortMonthDay(startTime),
    };

    final startLabel = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(startTime),
      alwaysUse24HourFormat: false,
    );
    final endLabel = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(endTime),
      alwaysUse24HourFormat: false,
    );

    return '$startLabel - $endLabel\n$dayLabel,';
  }

  String? _compactLocation(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;

    final parts =
        trimmed
            .split(',')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();

    if (parts.isEmpty) return null;
    if (parts.length == 1) return parts.first;

    return '${parts.first}, ${parts[1]}';
  }

  void _navigateToDetail(BuildContext context) {
    context.pushNamed(
      'bookingDetail',
      extra: <String, dynamic>{
        'startTime': startTime,
        'endTime': endTime,
        'bookingId': bookingId,
        'totalAmountMinor': totalAmountMinor,
        'preLoadedBookingDetail': null,
        'shopCurrency': shopCurrency,
        'shopType': shopType,
        'shopName': shopName,
        'status': status,
        'shopLogoUrl': shopLogoUrl,
        'shopAddress': shopAddress,
        'isShopOwner': isShopOwner,
      },
    );
  }
}
