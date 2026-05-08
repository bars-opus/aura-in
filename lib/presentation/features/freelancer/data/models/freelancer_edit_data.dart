// lib/features/freelancer/data/models/freelancer_edit_data.dart

import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';

/// Complete freelancer data for editing (includes all related data)
class FreelancerEditData {
  final FreelancerDetailsDTO profile;
  final List<AppointmentSlotDTO> services;
  final List<OpeningHoursDraft> openingHours;
  final List<ContactDraft> contacts;
  final List<SocialLinkDraft> socialLinks;
  final List<String> portfolioImages;
  final List<DocumentDraft> documents;
  final List<AwardDTO> awards;
  final List<String> toolIds;

  const FreelancerEditData({
    required this.profile,
    required this.services,
    required this.openingHours,
    required this.contacts,
    required this.socialLinks,
    required this.portfolioImages,
    required this.documents,
    required this.awards,
    required this.toolIds,
  });
}
