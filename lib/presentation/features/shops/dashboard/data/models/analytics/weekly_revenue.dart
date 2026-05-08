class WeeklyRevenue {
  final int weekNumber;
  final int year;

  final DateTime startDate;
  final DateTime endDate;
  final double revenue;
  final int bookingCount;
  final bool isPartial; // Add this for current week

  WeeklyRevenue({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.revenue,
    required this.year,
    required this.bookingCount,
    this.isPartial = false,
  });
  String get weekLabel => 'Week $weekNumber';

  String get weekRange {
    if (startDate.month == endDate.month) {
      return '${_getMonthAbbr(startDate.month)} ${startDate.day} - ${endDate.day}';
    } else {
      return '${_getMonthAbbr(startDate.month)} ${startDate.day} - ${_getMonthAbbr(endDate.month)} ${endDate.day}';
    }
  }

  String _getMonthAbbr(int month) {
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
}
