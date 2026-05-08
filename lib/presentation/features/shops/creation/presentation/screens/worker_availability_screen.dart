// lib/features/shop/workers/presentation/screens/worker_availability_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/worker_unavailability_model.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/add_unavailability_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/unavailability_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/worker_availability_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';

class WorkerAvailabilityScreen extends ConsumerStatefulWidget {
  final String workerId;
  final String workerName;

  const WorkerAvailabilityScreen({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  @override
  ConsumerState<WorkerAvailabilityScreen> createState() => _WorkerAvailabilityScreenState();
}

class _WorkerAvailabilityScreenState extends ConsumerState<WorkerAvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late final ValueNotifier<List<WorkerUnavailabilityModel>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availabilityAsync = ref.watch(workerAvailabilityProvider(widget.workerId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workerName} - Availability'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUnavailabilityModal(),
            tooltip: 'Add Unavailable Period',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workerAvailabilityProvider(widget.workerId));
          ref.read(workerAvailabilityProvider(widget.workerId).notifier).refresh();
        },
        child: Column(
          children: [
            // Calendar
            _buildCalendar(theme),
            
            // Events list
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _selectedEvents,
                builder: (context, events, _) {
                  if (events.isEmpty) {
                    return _buildEmptyState(theme);
                  }
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return UnavailabilityTile(
                        unavailability: event,
                        onEdit: () => _editUnavailability(event),
                        onDelete: () => _deleteUnavailability(event.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    final availabilityAsync = ref.watch(workerAvailabilityProvider(widget.workerId));

    return availabilityAsync.when(
      data: (unavailabilityList) {
        // Update selected events when calendar changes
        _updateSelectedEvents(unavailabilityList, _selectedDay);
        
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _updateSelectedEvents(unavailabilityList, selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              // Optionally load more data when month changes
            },
            calendarStyle: CalendarStyle(
              markersAlignment: Alignment.bottomCenter,
              markerSize: 6.sp,
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              return _getEventsForDay(unavailabilityList, day);
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 400.h,
        child: const Center(child: CircularLoadingIndicator(
         
        ),),
      ),
      error: (error, _) => SizedBox(
        height: 400.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              SizedBox(height: Spacing.sm.h),
              Text('Failed to load availability'),
              SizedBox(height: Spacing.sm.h),
              AppButton(
                label: 'Retry',
                onPressed: () {
                  ref.invalidate(workerAvailabilityProvider(widget.workerId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: EmptyStateWidget(
        title: 'No Unavailable Periods',
        subtitle: 'This worker is available on ${_formatDate(_selectedDay)}',
        icon: Icons.check_circle_outline,
      ),
    );
  }

  void _updateSelectedEvents(
    List<WorkerUnavailabilityModel> events,
    DateTime day,
  ) {
    final dayEvents = _getEventsForDay(events, day);
    _selectedEvents.value = dayEvents;
  }

  List<WorkerUnavailabilityModel> _getEventsForDay(
    List<WorkerUnavailabilityModel> events,
    DateTime day,
  ) {
    return events.where((event) {
      final eventDate = event.startTime;
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();
  }

  void _showAddUnavailabilityModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => AddUnavailabilityModal(
        workerId: widget.workerId,
        onSaved: () {
          ref.invalidate(workerAvailabilityProvider(widget.workerId));
          ref.read(workerAvailabilityProvider(widget.workerId).notifier).refresh();
        },
      ),
    );
  }

  void _editUnavailability(WorkerUnavailabilityModel unavailability) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => AddUnavailabilityModal(
        workerId: widget.workerId,
        initialUnavailability: unavailability,
        onSaved: () {
          ref.invalidate(workerAvailabilityProvider(widget.workerId));
          ref.read(workerAvailabilityProvider(widget.workerId).notifier).refresh();
        },
      ),
    );
  }

  Future<void> _deleteUnavailability(String unavailabilityId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Unavailable Period'),
        content: const Text('Are you sure you want to remove this unavailable period?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(workerAvailabilityProvider(widget.workerId).notifier);
      await notifier.removeUnavailability(unavailabilityId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unavailable period removed')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
