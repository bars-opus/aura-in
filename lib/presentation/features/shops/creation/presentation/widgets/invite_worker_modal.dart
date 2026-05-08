// lib/features/shop/workers/widgets/invite_worker_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/widgets/app_text_form_field.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/appointment_slot_add_workers_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';

class InviteWorkerModal extends ConsumerStatefulWidget {
  final String shopId;
  final VoidCallback onInviteSent;

  const InviteWorkerModal({
    super.key,
    required this.shopId,
    required this.onInviteSent,
  });

  @override
  ConsumerState<InviteWorkerModal> createState() => _InviteWorkerModalState();
}

class _InviteWorkerModalState extends ConsumerState<InviteWorkerModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _searchController;
  late TextEditingController _messageController;
  bool _isLoading = false;
  List<WorkerDTO> _searchResults = [];
  WorkerDTO? _selectedWorker;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _messageController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length >= 2) {
      _searchWorkers(query);
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _searchWorkers(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final repository = ref.read(workerRepositoryProvider);
      final allWorkers = await repository.getAllWorkers();

      // Filter workers by name or email (case-insensitive)
      final results =
          allWorkers.where((worker) {
            final nameMatch = worker.name.toLowerCase().contains(
              query.toLowerCase(),
            );
            // If you have email in WorkerDTO, add email search
            return nameMatch;
          }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invite Worker',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),

          // Search for worker
          Text(
            'Search for Worker',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Spacing.xs.h),
          AppTextFormField(
            controller: _searchController,
            label: 'Name or Email',
            hintText: 'Type at least 2 characters...',
            prefixIcon: Icons.search,
          ),
          SizedBox(height: Spacing.sm.h),

          // Search results
          if (_isSearching)
            const Center(child: CircularLoadingIndicator())
          else if (_searchResults.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxHeight: 200.h),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final worker = _searchResults[index];
                  final isSelected = _selectedWorker?.id == worker.id;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          worker.profileImage != null
                              ? NetworkImage(worker.profileImage!)
                              : null,
                      child:
                          worker.profileImage == null
                              ? Text(worker.name[0].toUpperCase())
                              : null,
                    ),
                    title: Text(worker.name),
                    subtitle: Text(worker.specialties.take(2).join(', ')),
                    trailing:
                        isSelected
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedWorker = worker;
                        _searchResults = [];
                        _searchController.text = worker.name;
                      });
                    },
                  );
                },
              ),
            )
          else if (_searchController.text.trim().length >= 2 && !_isSearching)
            Padding(
              padding: EdgeInsets.all(Spacing.sm.h),
              child: Text(
                'No workers found. They need to create an account first.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ),

          if (_selectedWorker != null) ...[
            SizedBox(height: Spacing.md.h),
            Divider(),
            SizedBox(height: Spacing.sm.h),

            // Selected worker preview
            Container(
              padding: EdgeInsets.all(Spacing.sm.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage:
                        _selectedWorker!.profileImage != null
                            ? NetworkImage(_selectedWorker!.profileImage!)
                            : null,
                    child:
                        _selectedWorker!.profileImage == null
                            ? Text(_selectedWorker!.name[0].toUpperCase())
                            : null,
                  ),
                  SizedBox(width: Spacing.sm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedWorker!.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          'Will be invited to join your shop',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, size: 16.sp),
                    onPressed: () {
                      setState(() {
                        _selectedWorker = null;
                        _searchController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: Spacing.md.h),

            // Optional message
            AppTextFormField(
              controller: _messageController,
              label: 'Personal Message (optional)',
              hintText: 'We\'d love to have you join our team!',
              prefixIcon: Icons.message,
              maxLines: 2,
            ),
          ],

          SizedBox(height: Spacing.lg.h),

          // Info note
          Container(
            padding: EdgeInsets.all(Spacing.sm.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: Spacing.sm.w),
                Expanded(
                  child: Text(
                    'The worker will receive an in-app invitation and must accept it before they can be assigned to services.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Spacing.lg.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Expanded(
                child: AppButton(
                  label: _isLoading ? 'Sending...' : 'Send Invitation',
                  onPressed:
                      (_selectedWorker == null || _isLoading)
                          ? null
                          : _sendInvitation,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.sm.h),
        ],
      ),
    );
  }

  Future<void> _sendInvitation() async {
    if (_selectedWorker == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(workerRepositoryProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await repository.inviteWorker(
        shopId: widget.shopId,
        workerId: _selectedWorker!.id,
        invitedBy: currentUser.id,
        message:
            _messageController.text.trim().isEmpty
                ? 'You have been invited to join our team!'
                : _messageController.text.trim(),
      );

      widget.onInviteSent();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
