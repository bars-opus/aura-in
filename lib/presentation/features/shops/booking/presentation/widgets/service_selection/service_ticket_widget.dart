// lib/features/booking/presentation/widgets/service_selection/service_ticket_widget.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// A beautiful card for displaying service information.
///
/// Follows the design system with consistent spacing, typography,
/// and visual feedback for selection states.
///
/// ## Features
/// - Displays service name, duration, price
/// - Visual selection state with checkmark
/// - Shows worker requirement indicator
/// - Animated on tap
///
/// ## Usage
/// ```dart
/// ServiceTicketWidget(
///   service: service,
///   isSelected: isSelected,
///   onTap: () => toggleService(service),
///   currency: 'GHS',
/// )

class ServiceTicketWidget extends ConsumerWidget {
  final AppointmentSlotDTO service;
  final bool isSelected;
  final VoidCallback onTap;
  final String currency;
  final bool showWorkerIndicator;

  const ServiceTicketWidget({
    Key? key,
    required this.service,
    required this.isSelected,
    required this.onTap,
    required this.currency,
    this.showWorkerIndicator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        margin: EdgeInsets.symmetric(vertical: Spacing.sm.h),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onBackground, width: .1),
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(Spacing.md.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildSelectionIndicator(colorScheme),
                  Gap(Spacing.md.w),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.serviceName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                              color:
                                  isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onBackground,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                        Text(
                          '$currency ${(service.price / 100).toStringAsFixed(2)}',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (service.description != null) ...[
                Gap(Spacing.xs.h),
                Text(
                  service.description!,
                  style: textTheme.bodyMedium?.copyWith(
                    color:
                        isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              Gap(Spacing.md.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWorkerIndicator(
                    context,
                    Icons.access_time,
                    _formatDuration(service.duration),
                  ),

                  // Worker indicator
                  if (showWorkerIndicator && service.selectPreferredWorker)
                    _buildWorkerIndicator(
                      context,
                      Icons.person,
                      'Worker available',
                    ),

                  Text(
                    'Up to ${service.maxClients} clients',
                    style: textTheme.labelSmall?.copyWith(
                      color:
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              Gap(Spacing.xs.h),
              AppTextButton(
                padding: const EdgeInsets.all(0),
                // alignment: Alignment.bottomLeft,
                text: 'Expand',
                textColor: isSelected ? colorScheme.onBackground : null,
                fontSize: 12,
              ),

              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.md.h),
                  child: _buildQuantitySelector(context, ref),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quantityNotifier = ref.read(serviceQuantityProvider.notifier);

    // 👇 CHANGE THIS: Use ref.watch to listen to changes
    final currentQty = ref.watch(serviceQuantityProvider)[service.id] ?? 1;

    return Container(
      padding: EdgeInsets.all(Spacing.sm.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),

        border: Border.all(color: colorScheme.onPrimary, width: .3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Number of people:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onPrimary,
            ),
          ),
          Row(
            children: [
              // Decrement button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      currentQty > 1
                          ? () => quantityNotifier.setQuantity(
                            service.id,
                            currentQty - 1,
                          )
                          : null,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: colorScheme.onPrimary),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: IconSizes.sm.w,
                      color:
                          currentQty < service.maxClients
                              ? colorScheme.onPrimary.withOpacity(0.3)
                              : colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),

              // Quantity display
              Container(
                width: 48.w,
                alignment: Alignment.center,
                child: Text(
                  '$currentQty',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),

              // Increment button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      currentQty < service.maxClients
                          ? () => quantityNotifier.setQuantity(
                            service.id,
                            currentQty + 1,
                          )
                          : null,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: colorScheme.onPrimary),
                    ),
                    child: Icon(
                      Icons.add,
                      size: IconSizes.sm.w,
                      color:
                          currentQty < service.maxClients
                              ? colorScheme.onPrimary
                              : colorScheme.onPrimary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator(ColorScheme colorScheme) {
    return Container(
      width: isSelected ? 20 : 12.w,
      height: isSelected ? 20 : 12.h,
      decoration: BoxDecoration(
        shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
        border: Border.all(
          color: isSelected ? colorScheme.onBackground : colorScheme.outline,
          width: 1.w,
        ),
        color: isSelected ? colorScheme.onBackground : Colors.transparent,
      ),
      child:
          isSelected
              ? Icon(
                Icons.check,
                size: IconSizes.xs.w,
                color: colorScheme.onPrimary,
              )
              : null,
    );
  }

  Widget _buildWorkerIndicator(
    BuildContext context,
    IconData icon,
    String name,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Row(
      children: [
        Icon(
          icon,
          size: IconSizes.xs.w,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onBackground,
        ),
        Gap(Spacing.xs.w),
        Text(
          name,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color:
                isSelected ? colorScheme.onPrimary : colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  String _formatDuration(String durationString) {
    final duration = DurationUtils.parse(durationString);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
