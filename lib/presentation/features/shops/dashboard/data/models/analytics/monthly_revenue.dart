class MonthlyRevenue {
  final int month;
  final int year;
  final double revenue;
  final int bookingCount;

  MonthlyRevenue({
    required this.month,
    required this.year,
    required this.revenue,
    required this.bookingCount,
  });

  String get monthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      month: json['month'],
      year: json['year'],
      revenue: (json['revenue'] ?? 0).toDouble(),
      bookingCount: json['booking_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'revenue': revenue, 'booking_count': bookingCount};
  }

  @override
  List<Object?> get props => [month, revenue, bookingCount];
}
