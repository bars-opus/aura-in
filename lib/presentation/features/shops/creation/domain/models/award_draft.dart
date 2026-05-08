// // lib/features/shop/creation/domain/entities/award_draft.dart

// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';

// class AwardDraft extends Equatable {
//   final String id;
//   final String name;
//   final String? issuer;
//   final DateTime? dateReceived;
//   final String? description;
//   final String? link;
//   final int sortOrder;

//    AwardDraft({
//     String? id,
//     required this.name,
//     this.issuer,
//     this.dateReceived,
//     this.description,
//     this.link,
//     this.sortOrder = 0,
//   }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

//   /// Format date for display
//   String? get formattedDate {
//     if (dateReceived == null) return null;
//     return '${dateReceived!.year}-${dateReceived!.month.toString().padLeft(2, '0')}';
//   }

//   /// Validate URL if provided
//   String? validateLink() {
//     if (link == null || link!.isEmpty) return null;
//     if (!link!.startsWith('http://') && !link!.startsWith('https://')) {
//       return 'Link must start with http:// or https://';
//     }
//     return null;
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'issuer': issuer,
//     'dateReceived': dateReceived?.toIso8601String(),
//     'description': description,
//     'link': link,
//     'sortOrder': sortOrder,
//   };

//   factory AwardDraft.fromJson(Map<String, dynamic> json) {
//     return AwardDraft(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       issuer: json['issuer'] as String?,
//       dateReceived: json['dateReceived'] != null
//           ? DateTime.parse(json['dateReceived'] as String)
//           : null,
//       description: json['description'] as String?,
//       link: json['link'] as String?,
//       sortOrder: json['sortOrder'] as int? ?? 0,
//     );
//   }

//   AwardDraft copyWith({
//     String? name,
//     String? issuer,
//     DateTime? dateReceived,
//     String? description,
//     String? link,
//     int? sortOrder,
//   }) {
//     return AwardDraft(
//       id: id,
//       name: name ?? this.name,
//       issuer: issuer ?? this.issuer,
//       dateReceived: dateReceived ?? this.dateReceived,
//       description: description ?? this.description,
//       link: link ?? this.link,
//       sortOrder: sortOrder ?? this.sortOrder,
//     );
//   }

//   @override
//   List<Object?> get props => [id, name, issuer, dateReceived, description, link, sortOrder];
// }
