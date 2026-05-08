// lib/features/shops/creation/domain/models/amenity.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../utils/amenity_icon_helper.dart';

class Amenity extends Equatable {
  final String id;
  final String name;
  final String? iconName;
  final String? category;
  final int displayOrder;

  const Amenity({
    required this.id,
    required this.name,
    this.iconName,
    this.category,
    this.displayOrder = 0,
  });

  /// Get the Flutter IconData from the iconName
  IconData? get icon => AmenityIconHelper.getIconData(iconName);

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['icon_name'] as String?,
      category: json['category'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon_name': iconName,
    'category': category,
    'display_order': displayOrder,
  };

  @override
  List<Object?> get props => [id, name, iconName, category, displayOrder];
}

class AmenityCategory {
  final String name;
  final List<Amenity> amenities;

  const AmenityCategory({required this.name, required this.amenities});
}
