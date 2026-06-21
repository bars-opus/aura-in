import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tags selected on the discover screen to filter freelancers. Empty = All.
/// Multi-select: a freelancer matches if ANY selected tag overlaps theirs
/// (w.specialties && p_tags in the RPC).
final selectedFreelancerTagsProvider =
    StateProvider<Set<String>>((ref) => <String>{});
