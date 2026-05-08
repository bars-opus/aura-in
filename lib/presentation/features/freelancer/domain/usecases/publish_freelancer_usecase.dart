// lib/features/freelancer/domain/usecases/publish_freelancer_usecase.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';

/// Use case for publishing a freelancer profile
class PublishFreelancerUseCase {
  final SupabaseFreelancerRepository _repository;

  PublishFreelancerUseCase(this._repository);

  /// Create a new freelancer profile
  Future<String> execute({
    required String userId,
    required FreelancerDraft draft,
    required List<File> portfolioImages,
    required List<File> documents,
  }) async {
    // Validate minimum requirements
    if (!draft.isMinimumViable) {
      throw Exception(
        'Profile incomplete. Please complete all required sections.',
      );
    }

    try {
      final workerId = await _repository.createFreelancer(
        userId: userId,
        draft: draft,
        portfolioImages: portfolioImages,
        documents: documents,
      );

      return workerId;
    } catch (e) {
      throw Exception('Failed to publish freelancer profile: $e');
    }
  }

  /// Update an existing freelancer profile (matches repository signature)
  Future<void> update({
    required String workerId,
    required FreelancerDraft draft,
    required List<String> newImageUrls,
    required List<String> imageIdsToDelete,
    required List<String> imagesToDelete,
    required List<String> newDocumentUrls,
    required List<String> docIdsToDelete,
    required List<String> documentUrlsToDelete,
  }) async {
    try {
      await _repository.updateFreelancer(
        workerId: workerId,
        draft: draft,
        newImageUrls: newImageUrls,
        imageIdsToDelete: imageIdsToDelete,
        imagesToDelete: imagesToDelete,
        newDocumentUrls: newDocumentUrls,
        docIdsToDelete: docIdsToDelete,
        documentUrlsToDelete: documentUrlsToDelete,
      );
    } catch (e) {
      throw Exception('Failed to update freelancer profile: $e');
    }
  }
}

// Provider
final publishFreelancerUseCaseProvider = Provider<PublishFreelancerUseCase>((
  ref,
) {
  final repository = ref.watch(freelancerRepositoryProvider);
  return PublishFreelancerUseCase(repository);
});
