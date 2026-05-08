// lib/features/shops/query/data/models/dtos/award_dto.dart

import 'package:equatable/equatable.dart';

class AwardDTO extends Equatable {
  final String name;
  final String? issuer; // ✅ Add this
  final String? link;
  final String? dateReceived;
  final String? description; // You might also want this
  final int sortOrder; // And this

  final String id;

  const AwardDTO({
    required this.id,
    required this.name,
    this.issuer,
    this.link,
    this.dateReceived,
    this.description,
    this.sortOrder = 0,
  });

  factory AwardDTO.fromJson(Map<String, dynamic> json) {
    final award = AwardDTO(
      name: json['name'] as String,
      id: json['id'] as String,
      issuer: json['issuer'] as String?, // This line
      link: json['link'] as String?,
      dateReceived: json['date_received'] as String?,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );

    print('   Created award.issuer: ${award.issuer}');
    return award;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'issuer': issuer,
    'link': link,
    'date_received': dateReceived,
    'description': description,
    'sort_order': sortOrder,
  };

  @override
  List<Object?> get props => [
    name,
    issuer,
    link,
    dateReceived,
    description,
    sortOrder,
    id,
  ];
}
