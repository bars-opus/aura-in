// lib/features/shop/workers/repositories/worker_repository.dart

import 'package:flutter/foundation.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/worker_unavailability_model.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/worker_invite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerRepository {
  final SupabaseClient _client;

  WorkerRepository(this._client);

  // ==================== Worker CRUD ====================

  /// Get all active workers for a specific shop
  Future<List<WorkerDTO>> getActiveWorkersForShop(String shopId) async {
    try {
      final response = await _client
          .from('shop_workers')
          .select('''
            *,
            worker:worker_id (*)
          ''')
          .eq('shop_id', shopId)
          .eq('status', 'active')
          .eq('worker.is_active', true);

      return response.map((json) {
        final workerJson = json['worker'] as Map<String, dynamic>;
        return WorkerDTO.fromJson({
          ...workerJson,
          'shop_worker_id': json['id'],
          'role': json['role'],
          'roles': json['roles'],
          'commission_percentage': json['commission_percentage'],
          'status': json['status'],
          'joined_at': json['joined_at'],
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching shop workers: $e');
      return [];
    }
  }

  /// Get all workers (for debugging/admin)
  Future<List<WorkerDTO>> getAllWorkers() async {
    try {
      final response = await _client.from('workers').select('*');
      return response.map((json) => WorkerDTO.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching all workers: $e');
      return [];
    }
  }

  // ==================== Invitation Methods ====================

  /// Get pending invites for a shop
  Future<List<WorkerInvite>> getPendingInvites(String shopId) async {
    try {
      final response = await _client
          .from('worker_invites')
          .select('''
            *,
            worker:worker_id (*),
            inviter:invited_by (*)
          ''')
          .eq('shop_id', shopId)
          .eq('status', 'pending');

      return response.map((json) => WorkerInvite.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching pending invites: $e');
      return [];
    }
  }

  /// Invite a worker to join a shop
  Future<void> inviteWorker({
    required String shopId,
    required String workerId,
    required String invitedBy,
    String? message,
  }) async {
    // Check if already invited or already a member
    final existing =
        await _client
            .from('shop_workers')
            .select('id, status')
            .eq('shop_id', shopId)
            .eq('worker_id', workerId)
            .maybeSingle();

    if (existing != null) {
      final status = existing['status'] as String;
      if (status == 'active') {
        throw Exception('Worker is already a member of this shop');
      }
      if (status == 'pending') {
        throw Exception('Worker has already been invited');
      }
    }

    await _client.from('worker_invites').insert({
      'shop_id': shopId,
      'worker_id': workerId,
      'invited_by': invitedBy,
      'message': message,
      'status': 'pending',
    });
  }

  /// Accept an invitation (called by worker)
  // In worker_repository.dart

  /// Accept an invitation (called by worker)
  Future<void> acceptInvite(String inviteId) async {
    // Get the invite details
    final invite =
        await _client
            .from('worker_invites')
            .select()
            .eq('id', inviteId)
            .single();

    if (invite['status'] != 'pending') {
      throw Exception('Invite already processed');
    }

    if (DateTime.parse(invite['expires_at']).isBefore(DateTime.now())) {
      throw Exception('Invite has expired');
    }

    // Update invite status
    await _client
        .from('worker_invites')
        .update({
          'status': 'accepted',
          'responded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', inviteId);

    // Add to shop_workers
    await _client.from('shop_workers').insert({
      'shop_id': invite['shop_id'],
      'worker_id': invite['worker_id'],
      'status': 'active',
      'joined_at': DateTime.now().toIso8601String(),
      'invited_by': invite['invited_by'],
    });
  }

  /// Get all pending invites for a worker
  Future<List<WorkerInvite>> getPendingInvitesForWorker(String workerId) async {
    try {
      final response = await _client
          .from('worker_invites')
          .select('''
          *,
          shop:shop_id (*)
        ''')
          .eq('worker_id', workerId)
          .eq('status', 'pending');

      return response.map((json) => WorkerInvite.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching worker invites: $e');
      return [];
    }
  }

  /// Decline an invitation (called by worker OR shop owner to cancel)
  Future<void> declineInvite(String inviteId) async {
    await _client
        .from('worker_invites')
        .update({
          'status': 'declined',
          'responded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', inviteId);
  }

  /// Cancel an invitation (shop owner removes pending invite)
  Future<void> cancelInvite(String inviteId) async {
    // This is the same as declineInvite for shop owners
    await declineInvite(inviteId);
  }

  /// Resend an invitation (create a new invite)
  Future<void> resendInvite({
    required String shopId,
    required String workerId,
    required String invitedBy,
    String? message,
  }) async {
    // First cancel the old invite
    final oldInvites = await _client
        .from('worker_invites')
        .select('id')
        .eq('shop_id', shopId)
        .eq('worker_id', workerId)
        .eq('status', 'pending');

    for (final invite in oldInvites) {
      await declineInvite(invite['id'] as String);
    }

    // Create new invite
    await inviteWorker(
      shopId: shopId,
      workerId: workerId,
      invitedBy: invitedBy,
      message: message,
    );
  }

  // ==================== Shop Worker Management ====================

  /// Remove a worker from a shop (soft delete)
  Future<void> removeWorkerFromShop({
    required String shopWorkerId,
    String? reason,
  }) async {
    await _client
        .from('shop_workers')
        .update({
          'status': 'inactive',
          'left_at': DateTime.now().toIso8601String(),
          'left_reason': reason,
          'is_active': false,
        })
        .eq('id', shopWorkerId);
  }

  /// Reactivate a previously removed worker
  Future<void> reactivateWorker(String shopWorkerId) async {
    await _client
        .from('shop_workers')
        .update({
          'status': 'active',
          'left_at': null,
          'left_reason': null,
          'is_active': true,
        })
        .eq('id', shopWorkerId);
  }

  /// Get shop worker relationship by worker and shop
  Future<Map<String, dynamic>?> getShopWorker(
    String shopId,
    String workerId,
  ) async {
    try {
      final response =
          await _client
              .from('shop_workers')
              .select()
              .eq('shop_id', shopId)
              .eq('worker_id', workerId)
              .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error fetching shop worker: $e');
      return null;
    }
  }

  // ==================== Worker Availability ====================

  /// Get all unavailability periods for a worker within a date range
  Future<List<WorkerUnavailabilityModel>> getWorkerUnavailability({
    required String workerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client
          .from('worker_unavailability')
          .select('*')
          .eq('worker_id', workerId)
          .gte('start_time', startDate.toIso8601String())
          .lte('end_time', endDate.toIso8601String())
          .order('start_time', ascending: true);

      return response
          .map((json) => WorkerUnavailabilityModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching unavailability: $e');
      return [];
    }
  }

  /// Add a new unavailability period
  Future<void> addUnavailability({
    required String workerId,
    required DateTime startTime,
    required DateTime endTime,
    String? reason,
  }) async {
    if (endTime.isBefore(startTime)) {
      throw Exception('End time must be after start time');
    }

    await _client.from('worker_unavailability').insert({
      'worker_id': workerId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'reason': reason,
    });
  }

  /// Remove an unavailability period
  Future<void> removeUnavailability(String unavailabilityId) async {
    await _client
        .from('worker_unavailability')
        .delete()
        .eq('id', unavailabilityId);
  }

  /// Update an existing unavailability period
  Future<void> updateUnavailability({
    required String unavailabilityId,
    required DateTime startTime,
    required DateTime endTime,
    String? reason,
  }) async {
    if (endTime.isBefore(startTime)) {
      throw Exception('End time must be after start time');
    }

    await _client
        .from('worker_unavailability')
        .update({
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'reason': reason,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', unavailabilityId);
  }

  // ==================== Service Worker Assignments ====================

  /// Get all workers assigned to a specific service slot
  Future<List<String>> getWorkersForSlot(String slotId) async {
    try {
      final response = await _client
          .from('slot_worker_assignments')
          .select('worker_id')
          .eq('slot_id', slotId);

      return response.map((row) => row['worker_id'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching workers for slot: $e');
      return [];
    }
  }

  /// Assign workers to a service slot
  Future<void> assignWorkersToSlot({
    required String slotId,
    required List<String> workerIds,
  }) async {
    // First delete existing assignments
    await _client
        .from('slot_worker_assignments')
        .delete()
        .eq('slot_id', slotId);

    // Add new assignments
    if (workerIds.isNotEmpty) {
      final assignments =
          workerIds
              .map(
                (workerId) => {
                  'slot_id': slotId,
                  'worker_id': workerId,
                  'is_preferred': true,
                },
              )
              .toList();

      await _client.from('slot_worker_assignments').insert(assignments);
    }
  }
}
