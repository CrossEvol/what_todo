class ReminderInterval {
  final int minutes;
  final String displayName;

  const ReminderInterval({
    required this.minutes,
    required this.displayName,
  });

  static const List<ReminderInterval> options = [
    ReminderInterval(minutes: 15, displayName: '15 minutes'),
    ReminderInterval(minutes: 30, displayName: '30 minutes'),
    ReminderInterval(minutes: 60, displayName: '1 hour'),
    ReminderInterval(minutes: 120, displayName: '2 hours'),
    ReminderInterval(minutes: 240, displayName: '4 hours'),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderInterval &&
          runtimeType == other.runtimeType &&
          minutes == other.minutes &&
          displayName == other.displayName;

  @override
  int get hashCode => minutes.hashCode ^ displayName.hashCode;

  @override
  String toString() =>
      'ReminderInterval(minutes: $minutes, displayName: $displayName)';
}
