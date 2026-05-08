// lib/features/freelancer/data/models/tool.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Tool model representing equipment/supplies a freelancer can use
/// FULLY DATA-DRIVEN - no hardcoded icon mappings!
class Tool extends Equatable {
  final String id;
  final String name;
  final int iconCodePoint;
  final String iconFontFamily;
  final String? iconFontPackage;
  final String category;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Tool({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    this.iconFontPackage,
    required this.category,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Dynamically create IconData from database values
  /// NO SWITCH STATEMENT NEEDED!
  IconData get icon => IconData(
    iconCodePoint,
    fontFamily: iconFontFamily,
    fontPackage: iconFontPackage,
  );

  /// Create from JSON
  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: json['icon_code_point'] as int,
      iconFontFamily: json['icon_font_family'] as String? ?? 'MaterialIcons',
      iconFontPackage: json['icon_font_package'] as String?,
      category: json['category'] as String? ?? 'General',
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_code_point': iconCodePoint,
      'icon_font_family': iconFontFamily,
      if (iconFontPackage != null) 'icon_font_package': iconFontPackage,
      'category': category,
      'display_order': displayOrder,
    };
  }

  /// Create a copy with updated fields
  Tool copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    String? category,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tool(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      category: category ?? this.category,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    iconCodePoint,
    iconFontFamily,
    iconFontPackage,
    category,
    displayOrder,
    createdAt,
    updatedAt,
  ];
}

/// Category grouping for tools
class ToolCategory {
  final String name;
  final List<Tool> tools;

  const ToolCategory({required this.name, required this.tools});

  factory ToolCategory.fromJson(Map<String, dynamic> json) {
    return ToolCategory(
      name: json['name'] as String,
      tools:
          (json['tools'] as List)
              .map((t) => Tool.fromJson(t as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'tools': tools.map((t) => t.toJson()).toList()};
  }
}
