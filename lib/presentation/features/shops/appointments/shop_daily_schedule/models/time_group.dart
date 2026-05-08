import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';

enum TimeGroup {
  morning,
  afternoon,
  evening,
}

extension TimeGroupExtensions on TimeGroup {
  String get displayName {
    switch (this) {
      case TimeGroup.morning:
        return 'Morning';
      case TimeGroup.afternoon:
        return 'Afternoon';
      case TimeGroup.evening:
        return 'Evening';
    }
  }

  static List<TimeGroup> get values => [TimeGroup.morning, TimeGroup.afternoon, TimeGroup.evening];

  static TimeGroup fromDateTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 12) return TimeGroup.morning;
    if (hour >= 12 && hour < 17) return TimeGroup.afternoon;
    return TimeGroup.evening;
  }
}

class GroupedAppointments extends Equatable {
  final TimeGroup group;
  final List<ShopCalendarBooking> appointments;

  const GroupedAppointments({
    required this.group,
    required this.appointments,
  });

  bool get hasAppointments => appointments.isNotEmpty;
  int get count => appointments.length;

  @override
  List<Object?> get props => [group, appointments];
}
