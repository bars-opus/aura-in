// lib/features/freelancer/creation/data/local_freelancer_storage.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';

const String _freelancerDraftBoxName = 'freelancer_drafts';

/// Service for persisting freelancer drafts locally using Hive
class LocalFreelancerStorage {
  final Box _box;

  LocalFreelancerStorage._(this._box);

  static Future<LocalFreelancerStorage> create() async {
    final box = await Hive.openBox(_freelancerDraftBoxName);
    return LocalFreelancerStorage._(box);
  }

  Future<void> saveDraft(String profileId, FreelancerDraft draft) async {
    await _box.put('freelancer_$profileId', draft.toJson());
  }

  Future<FreelancerDraft?> loadDraft(String profileId) async {
    try {
      final json = _box.get('freelancer_$profileId');
      if (json == null) return null;

      final Map<String, dynamic> safeJson;
      if (json is Map<String, dynamic>) {
        safeJson = json;
      } else if (json is Map) {
        safeJson = Map<String, dynamic>.from(json);
      } else {
        return null;
      }

      return FreelancerDraft.fromJson(safeJson);
    } catch (e) {
      print('Error loading freelancer draft: $e');
      return null;
    }
  }

  Future<void> clearDraft(String profileId) async {
    await _box.delete('freelancer_$profileId');
  }

  bool hasDraft(String profileId) {
    return _box.containsKey('freelancer_$profileId');
  }
}

// Global reference
LocalFreelancerStorage? _cachedFreelancerStorage;

final localFreelancerStorageProvider = Provider<LocalFreelancerStorage>((ref) {
  if (_cachedFreelancerStorage != null) {
    return _cachedFreelancerStorage!;
  }
  throw StateError('LocalFreelancerStorage must be initialized in main.dart');
});

void setLocalFreelancerStorage(LocalFreelancerStorage storage) {
  _cachedFreelancerStorage = storage;
}
