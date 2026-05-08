// lib/features/shop/query/data/models/dtos/duration_option.dart

class DurationOption {
  final String display;
  final int minutes;

  const DurationOption(this.display, this.minutes);

  static const List<DurationOption> options = [
    DurationOption('15 minutes', 15),
    DurationOption('30 minutes', 30),
    DurationOption('45 minutes', 45),
    DurationOption('1 hour', 60),
    DurationOption('1 hour 15 minutes', 75),
    DurationOption('1 hour 30 minutes', 90),
    DurationOption('1 hour 45 minutes', 105),
    DurationOption('2 hours', 120),
    DurationOption('2 hours 30 minutes', 150),
    DurationOption('3 hours', 180),
    DurationOption('3 hours 30 minutes', 210),
    DurationOption('4 hours', 240),
    DurationOption('Half day (4 hours)', 240),
    DurationOption('Full day (8 hours)', 480),
  ];
}
