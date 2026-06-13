// lib/features/shop/workers/providers/slot_assignments_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final workerSlotWorkerAssignmentsProvider = FutureProvider.family<Map<String, List<String>>, String>((ref, shopId) async {
  final client = Supabase.instance.client;
  
  try {
    final response = await client
        .from('slot_worker_assignments')
        .select('''
          slot_id,
          worker_id,
          appointment_slots!inner(shop_id)
        ''')
        .eq('appointment_slots.shop_id', shopId);

    final Map<String, List<String>> assignments = {};
    for (var row in response) {
      final slotId = row['slot_id'] as String;
      final workerId = row['worker_id'] as String;
      assignments.putIfAbsent(slotId, () => []).add(workerId);
    }
    return assignments;
  } catch (e) {
    debugPrint('Error fetching slot assignments: $e');
    return {};
  }
});
