// lib/features/freelancer/presentation/providers/freelancer_details_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_edit_data.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/opening_hours_dto.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';

/// Provider for fetching freelancer details
final freelancerDetailsProvider =
    FutureProvider.family<FreelancerDetailsDTO?, String>((
      ref,
      freelancerId,
    ) async {
      final repository = ref.watch(freelancerRepositoryProvider);
      return repository.getFreelancerById(freelancerId);
    });

/// Provider for freelancer services
final freelancerServicesProvider =
    FutureProvider.family<List<AppointmentSlotDTO>, String>((
      ref,
      freelancerId,
    ) async {
      final repository = ref.watch(freelancerRepositoryProvider);
      // Fetch services from appointment_slots where shop_id = freelancerId
      try {
        final response = await repository.getFreelancerServices(freelancerId);
        return response;
      } catch (e) {
        return [];
      }
    });

/// Provider for freelancer reviews
final freelancerReviewsProvider =
    FutureProvider.family<List<BookingReview>, String>((
      ref,
      freelancerId,
    ) async {
      final repository = ref.watch(freelancerRepositoryProvider);
      try {
        return await repository.getFreelancerReviews(freelancerId);
      } catch (e) {
        return [];
      }
    });

/// Provider for freelancer portfolio images
final freelancerPortfolioProvider = FutureProvider.family<List<String>, String>(
  (ref, freelancerId) async {
    final repository = ref.watch(freelancerRepositoryProvider);
    try {
      return await repository.getFreelancerPortfolio(freelancerId);
    } catch (e) {
      return [];
    }
  },
);

// Add this provider for fetching complete edit data
final freelancerEditDataProvider =
    FutureProvider.family<FreelancerEditData?, String>((
      ref,
      freelancerId,
    ) async {
      final repository = ref.watch(freelancerRepositoryProvider);

      // Fetch all data in parallel
      final results = await Future.wait([
        repository.getFreelancerById(freelancerId),
        repository.getFreelancerServices(freelancerId),
        repository.getFreelancerHours(freelancerId),
        repository.getFreelancerContacts(freelancerId),
        repository.getFreelancerSocialLinks(freelancerId),
        repository.getFreelancerPortfolio(freelancerId),
        repository.getFreelancerDocuments(freelancerId),
        repository.getFreelancerAwards(freelancerId),
        repository.getFreelancerTools(freelancerId),
      ]);

      final profile = results[0] as FreelancerDetailsDTO?;
      if (profile == null) return null;

      return FreelancerEditData(
        profile: profile,
        services: results[1] as List<AppointmentSlotDTO>,
        openingHours: results[2] as List<OpeningHoursDraft>,
        contacts: results[3] as List<ContactDraft>,
        socialLinks: results[4] as List<SocialLinkDraft>,
        portfolioImages: results[5] as List<String>,
        documents: results[6] as List<DocumentDraft>,
        awards: results[7] as List<AwardDTO>,
        toolIds: results[8] as List<String>,
      );
    });

/// Provider for freelancer opening hours
final freelancerHoursProvider =
    FutureProvider.family<List<OpeningHoursDTO>, String>((
      ref,
      freelancerId,
    ) async {
      final repository = ref.watch(freelancerRepositoryProvider);
      try {
        return await repository.getFreelancerHours(freelancerId);
      } catch (e) {
        print('Error getting freelancer hours: $e');
        return [];
      }
    });

/// Provider for freelancer contacts
final freelancerContactsProvider =
    FutureProvider.family<List<ContactDraft>, String>((
      ref,
      freelancerId,
    ) async {
      final repository = ref.watch(freelancerRepositoryProvider);
      try {
        return await repository.getFreelancerContacts(freelancerId);
      } catch (e) {
        print('Error getting freelancer contacts: $e');
        return [];
      }
    });

/// Provider for freelancer social links
final freelancerSocialLinksProvider =
    FutureProvider.family<List<SocialLinkDraft>, String>((
      ref,
      freelancerId,
    ) async {
      final repository = ref.watch(freelancerRepositoryProvider);
      try {
        return await repository.getFreelancerSocialLinks(freelancerId);
      } catch (e) {
        print('Error getting freelancer social links: $e');
        return [];
      }
    });

/// Provider for freelancer awards
final freelancerAwardsProvider =
    FutureProvider.family<List<AwardDTO>, String>((ref, freelancerId) async {
      final repository = ref.watch(freelancerRepositoryProvider);
      try {
        return await repository.getFreelancerAwards(freelancerId);
      } catch (e) {
        print('Error getting freelancer awards: $e');
        return [];
      }
    });

/// Provider for freelancer tools (from junction table)
final freelancerToolsProvider = FutureProvider.family<List<String>, String>((
  ref,
  freelancerId,
) async {
  final repository = ref.watch(freelancerRepositoryProvider);
  try {
    return await repository.getFreelancerTools(freelancerId);
  } catch (e) {
    print('Error getting freelancer tools: $e');
    return [];
  }
});

/// Provider for freelancer document URLs
final freelancerDocumentUrlsProvider =
    FutureProvider.family<List<String>, String>((ref, freelancerId) async {
      final repository = ref.watch(freelancerRepositoryProvider);
      try {
        return await repository.getFreelancerDocumentUrls(freelancerId);
      } catch (e) {
        print('Error getting freelancer document URLs: $e');
        return [];
      }
    });
