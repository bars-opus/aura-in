// lib/features/dashboard/data/models/quarterly_revenue.dart
import 'package:equatable/equatable.dart';

/// Represents revenue for a single quarter
class QuarterlyRevenue extends Equatable {
  final int quarter; // 1, 2, 3, 4
  final double amount;
  final int year;

  const QuarterlyRevenue({
    required this.quarter,
    required this.amount,
    required this.year,
  });

  /// Quarter name (Q1, Q2, Q3, Q4)
  String get quarterName => 'Q$quarter';

  /// Short month range for display
  String get monthRange {
    switch (quarter) {
      case 1:
        return 'Jan-Mar';
      case 2:
        return 'Apr-Jun';
      case 3:
        return 'Jul-Sep';
      case 4:
        return 'Oct-Dec';
      default:
        return '';
    }
  }

  factory QuarterlyRevenue.fromJson(Map<String, dynamic> json) {
    return QuarterlyRevenue(
      quarter: json['quarter'],
      amount: (json['revenue'] ?? 0).toDouble(),
      year: json['year'] ?? DateTime.now().year,
    );
  }

  @override
  List<Object?> get props => [quarter, amount, year];
}

/// Collection of quarterly revenues for a year
class YearlyRevenue extends Equatable {
  final int year;
  final List<QuarterlyRevenue> quarters;
  final double totalRevenue;

  const YearlyRevenue({
    required this.year,
    required this.quarters,
    required this.totalRevenue,
  });

  factory YearlyRevenue.fromJson(Map<String, dynamic> json) {
    final quartersData = List<Map<String, dynamic>>.from(json['quarters'] ?? []);
    final quarters = quartersData.map(QuarterlyRevenue.fromJson).toList();

    return YearlyRevenue(
      year: json['year'] ?? DateTime.now().year,
      quarters: quarters,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }

  /// Empty state for loading/error
  static const empty = YearlyRevenue(
    year: 0,
    quarters: [],
    totalRevenue: 0,
  );

  @override
  List<Object?> get props => [year, quarters, totalRevenue];
}
