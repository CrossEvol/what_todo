class ReminderInterval {
  final int intervalMinutes;
  final String displayName;

  const ReminderInterval({
    required this.intervalMinutes,
    required this.displayName,
  });

  static const List<ReminderInterval> options = [
    ReminderInterval(intervalMinutes: 15, displayName: '15 minutes'),
    ReminderInterval(intervalMinutes: 30, displayName: '30 minutes'),
    ReminderInterval(intervalMinutes: 60, displayName: '1 hour'),
    ReminderInterval(intervalMinutes: 120, displayName: '2 hours'),
    ReminderInterval(intervalMinutes: 180, displayName: '3 hours'),
    ReminderInterval(intervalMinutes: 240, displayName: '4 hours'),
  ];

  static String getDisplayName(int intervalMinutes) {
    return options
        .firstWhere((option) => option.intervalMinutes == intervalMinutes,
            orElse: () => const ReminderInterval(
                intervalMinutes: 15, displayName: '15 minutes'))
        .displayName;
  }
}