// lib/features/shop/workers/widgets/service_worker_assignment_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';

class ServiceWorkerAssignmentTile extends StatefulWidget {
  final AppointmentSlotDTO service;
  final List<WorkerDTO> availableWorkers;
  final Function(List<String>) onWorkersChanged;

  const ServiceWorkerAssignmentTile({
    super.key,
    required this.service,
    required this.availableWorkers,
    required this.onWorkersChanged,
  });

  @override
  State<ServiceWorkerAssignmentTile> createState() =>
      _ServiceWorkerAssignmentTileState();
}

class _ServiceWorkerAssignmentTileState
    extends State<ServiceWorkerAssignmentTile> {
  late Set<String> _selectedWorkerIds;
  late bool _enableWorkerSelection;

  @override
  void initState() {
    super.initState();
    _selectedWorkerIds = Set.from(widget.service.workerIds ?? []);
    _enableWorkerSelection = widget.service.selectPreferredWorker;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardInkWell(
      padding: EdgeInsets.all(Spacing.md.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.serviceName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Spacing.xs.h),
                    Text(
                      '${widget.service.duration} · \$${(widget.service.price / 100).toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Enable worker selection toggle
              Row(
                children: [
                  Text(
                    'Allow worker selection',
                    style: theme.textTheme.bodySmall,
                  ),
                  SizedBox(width: Spacing.xs.w),
                  Switch(
                    value: _enableWorkerSelection,
                    onChanged: (value) {
                      setState(() {
                        _enableWorkerSelection = value;
                        if (!value) {
                          _selectedWorkerIds.clear();
                        }
                        widget.onWorkersChanged(_selectedWorkerIds.toList());
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_enableWorkerSelection) ...[
            SizedBox(height: Spacing.md.h),
            Divider(),
            SizedBox(height: Spacing.sm.h),
            Text(
              'Assign Workers',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  widget.availableWorkers.map((worker) {
                    final isSelected = _selectedWorkerIds.contains(worker.id);
                    return FilterChip(
                      label: Text(worker.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedWorkerIds.add(worker.id);
                          } else {
                            _selectedWorkerIds.remove(worker.id);
                          }
                          widget.onWorkersChanged(_selectedWorkerIds.toList());
                        });
                      },
                      avatar:
                          worker.profileImage != null
                              ? CircleAvatar(
                                radius: 12.r,
                                backgroundImage: NetworkImage(
                                  worker.profileImage!,
                                ),
                              )
                              : null,
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.primary,
                    );
                  }).toList(),
            ),
            if (_selectedWorkerIds.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: Spacing.sm.h),
                child: Text(
                  '${_selectedWorkerIds.length} worker(s) assigned',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
