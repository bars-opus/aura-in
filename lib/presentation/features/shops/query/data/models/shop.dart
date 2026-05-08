// lib/features/shops/data/models/shop.dart
// lib/features/shops/domain/entities/shop.dart

import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/contact.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/simple_media.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/social_media.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';

class Shop {
  final String id;
  final String userId;
  final String shopName;
  final String? shopLogoUrl;
  final bool verified;
  final String? shopType;
  final String? dynamicLink;
  final String? terms;
  final String? overview;
  final bool noBooking;
  final String? city;
  final String? country;
  final String? address;
  final String? currency;
  final String? transferRecipientId;
  final String? subaccountId;
  final String? accountType;
  final double? averageRating;
  final int? numberClientsWorked;
  final bool isPaidForWeek;
  final bool isMainShop;
  final String? mainShopId;
  final String? luxuryLevel;
  final bool showOnExplorePage;
  final DateTime createdAt;

  // Related entities (for domain use)
  final List<WorkerDTO>? workers;
  final List<SimpleMedia>? media;
  final List<SimpleMedia>? awards;
  final List<SocialMedia>? socialLinks;
  final List<Contact>? contacts;
  final Map<String, DateTimeRange>? openingHours;
  final List<AppointmentSlotDTO>? appointmentSlots;
  final int? totalReviews;

  Shop({
    required this.id,
    required this.userId,
    required this.shopName,
    this.shopLogoUrl,
    required this.verified,
    this.shopType,
    this.dynamicLink,
    this.terms,
    this.overview,
    required this.noBooking,
    this.city,
    this.country,
    this.address,
    this.currency,
    this.transferRecipientId,
    this.subaccountId,
    this.accountType,
    this.averageRating,
    this.numberClientsWorked,
    required this.isPaidForWeek,
    required this.isMainShop,
    this.mainShopId,
    this.luxuryLevel,
    required this.showOnExplorePage,
    required this.createdAt,
    // required this.updatedAt,
    this.workers,
    this.media,
    this.awards,
    this.socialLinks,
    this.contacts,
    this.openingHours,
    this.appointmentSlots,
    this.totalReviews,
  });
}
