// lib/features/dashboard/data/models/category_breakdown.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class QuaterlyCategoryBreakdown extends Equatable {
  final String name;
  final double amount;
  final double percentage;
  final IconData icon;

  const QuaterlyCategoryBreakdown({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.icon,
  });

  factory QuaterlyCategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return QuaterlyCategoryBreakdown(
      name: json['name'],
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      icon: _getIconForCategory(json['name']),
    );
  }

  static IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'hair services':
        return Icons.content_cut;
      case 'spa services':
        return Icons.spa;
      case 'nail services':
        return Icons.color_lens;
      case 'makeup services':
        return Icons.brush;
      case 'waxing services':
        return Icons.cleaning_services;
      default:
        return Icons.attach_money;
    }
  }

  @override
  List<Object?> get props => [name, amount, percentage];
}
