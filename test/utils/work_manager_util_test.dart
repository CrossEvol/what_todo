import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/reminder/reminder.dart';
import 'package:flutter_app/models/reminder/reminder_type.dart';
import 'package:flutter_app/utils/work_manager_util.dart';

void main() {
  group('filterRemindersForNotification', () {
    late DateTime mondayMorning;
    late DateTime saturdayAfternoon;
    late DateTime sundayEvening;

    setUp(() {
      // Monday, 10:00 AM
      mondayMorning = DateTime(2024, 1, 8, 10, 0);
      // Saturday, 2:00 PM
      saturdayAfternoon = DateTime(2024, 1, 13, 14, 0);
      // Sunday, 6:00 PM
      sundayEvening = DateTime(2024, 1, 14, 18, 0);
    });

    test('should filter out disabled reminders', () {
      final reminders = [
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 3),
          false, // disabled
          2,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 2,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 1);
      expect(result[0].id, 1);
    });

    test('should filter daily reminders correctly on weekday', () {
      final reminders = [
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 1);
      expect(result[0].type, ReminderType.daily);
    });

    test('should filter daily reminders correctly on weekend', () {
      final reminders = [
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 13, 14, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 13, 13, 0),
        )..id = 1,
      ];

      final result = filterRemindersForNotification(reminders, saturdayAfternoon);

      expect(result.length, 1);
      expect(result[0].type, ReminderType.daily);
    });

    test('should include workDay reminders on Monday', () {
      final reminders = [
        Reminder.create(
          ReminderType.workDay,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 1);
      expect(result[0].type, ReminderType.workDay);
    });

    test('should exclude workDay reminders on Saturday', () {
      final reminders = [
        Reminder.create(
          ReminderType.workDay,
          DateTime(2024, 1, 13, 14, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 13, 13, 0),
        )..id = 1,
      ];

      final result = filterRemindersForNotification(reminders, saturdayAfternoon);

      expect(result.length, 0);
    });

    test('should exclude workDay reminders on Sunday', () {
      final reminders = [
        Reminder.create(
          ReminderType.workDay,
          DateTime(2024, 1, 14, 18, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 14, 17, 0),
        )..id = 1,
      ];

      final result = filterRemindersForNotification(reminders, sundayEvening);

      expect(result.length, 0);
    });

    test('should include holiday reminders on Saturday', () {
      final reminders = [
        Reminder.create(
          ReminderType.holiday,
          DateTime(2024, 1, 13, 14, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 13, 13, 0),
        )..id = 1,
      ];

      final result = filterRemindersForNotification(reminders, saturdayAfternoon);

      expect(result.length, 1);
      expect(result[0].type, ReminderType.holiday);
    });

    test('should include holiday reminders on Sunday', () {
      final reminders = [
        Reminder.create(
          ReminderType.holiday,
          DateTime(2024, 1, 14, 18, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 14, 17, 0),
        )..id = 1,
      ];

      final result = filterRemindersForNotification(reminders, sundayEvening);

      expect(result.length, 1);
      expect(result[0].type, ReminderType.holiday);
    });

    test('should exclude holiday reminders on Monday', () {
      final reminders = [
        Reminder.create(
          ReminderType.holiday,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 0);
    });

    test('should filter reminders within 15 minute time window', () {
      final reminders = [
        // Within window: 10:05 (5 minutes after 10:00)
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
        // Within window: 9:50 (10 minutes before 10:00)
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 9, 50),
          true,
          2,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 2,
        // Outside window: 10:20 (20 minutes after 10:00)
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 20),
          true,
          3,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 3,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 2);
      expect(result.any((r) => r.id == 1), true);
      expect(result.any((r) => r.id == 2), true);
      expect(result.any((r) => r.id == 3), false);
    });

    test('should filter reminders with custom time window', () {
      final reminders = [
        // Within 5 minute window
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 3),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
        // Outside 5 minute window
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 10),
          true,
          2,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 2,
      ];

      final result = filterRemindersForNotification(
        reminders,
        mondayMorning,
        timeWindowMinutes: 5,
      );

      expect(result.length, 1);
      expect(result[0].id, 1);
    });

    test('should exclude reminders with null remindTime', () {
      final reminders = [
        Reminder.create(
          ReminderType.daily,
          null, // null remindTime
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          2,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 2,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 1);
      expect(result[0].id, 2);
    });

    test('should keep only latest reminder per task', () {
      final reminders = [
        // Older reminder for task 1
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 8, 0),
        )..id = 1,
        // Newer reminder for task 1
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 2,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 1);
      expect(result[0].id, 2); // Should keep the newer one
    });

    test('should return maximum 5 reminders sorted by updateTime', () {
      final reminders = List.generate(10, (index) {
        return Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          index + 1, // Different task IDs
          updateTime: DateTime(2024, 1, 8, 9, index),
        )..id = index + 1;
      });

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 5);
      // Should be sorted by updateTime descending (newest first)
      for (int i = 0; i < result.length - 1; i++) {
        expect(
          result[i].updateTime!.isAfter(result[i + 1].updateTime!),
          true,
        );
      }
      // Should contain the 5 most recent reminders (ids 10, 9, 8, 7, 6)
      expect(result[0].id, 10);
      expect(result[1].id, 9);
      expect(result[2].id, 8);
      expect(result[3].id, 7);
      expect(result[4].id, 6);
    });

    test('should handle mixed reminder types correctly', () {
      final reminders = [
        // Daily - should pass on Monday
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
        // WorkDay - should pass on Monday
        Reminder.create(
          ReminderType.workDay,
          DateTime(2024, 1, 8, 10, 5),
          true,
          2,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 2,
        // Holiday - should NOT pass on Monday
        Reminder.create(
          ReminderType.holiday,
          DateTime(2024, 1, 8, 10, 5),
          true,
          3,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 3,
        // Once - should pass
        Reminder.create(
          ReminderType.once,
          DateTime(2024, 1, 8, 10, 5),
          true,
          4,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 4,
        // Custom - should NOT pass (not handled)
        Reminder.create(
          ReminderType.custom,
          DateTime(2024, 1, 8, 10, 5),
          true,
          5,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 5,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 3);
      expect(result.any((r) => r.id == 1), true); // daily
      expect(result.any((r) => r.id == 2), true); // workDay
      expect(result.any((r) => r.id == 3), false); // holiday
      expect(result.any((r) => r.id == 4), true); // once
      expect(result.any((r) => r.id == 5), false); // custom
    });

    test('should handle empty reminder list', () {
      final result = filterRemindersForNotification([], mondayMorning);

      expect(result.length, 0);
    });

    test('should exclude reminders with null taskId', () {
      final reminders = [
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          null, // null taskId
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 1,
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          2,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 2,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 1);
      expect(result[0].id, 2);
    });

    test('should handle complex scenario with all filters', () {
      final reminders = [
        // Should pass: enabled, daily, within time, task 1
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 30),
        )..id = 1,
        // Should NOT pass: disabled
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          false,
          2,
          updateTime: DateTime(2024, 1, 8, 9, 30),
        )..id = 2,
        // Should NOT pass: holiday type on Monday
        Reminder.create(
          ReminderType.holiday,
          DateTime(2024, 1, 8, 10, 5),
          true,
          3,
          updateTime: DateTime(2024, 1, 8, 9, 30),
        )..id = 3,
        // Should NOT pass: outside time window
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 11, 0),
          true,
          4,
          updateTime: DateTime(2024, 1, 8, 9, 30),
        )..id = 4,
        // Should pass: enabled, workDay, within time, task 5
        Reminder.create(
          ReminderType.workDay,
          DateTime(2024, 1, 8, 10, 5),
          true,
          5,
          updateTime: DateTime(2024, 1, 8, 9, 20),
        )..id = 5,
        // Should NOT pass: older reminder for task 1
        Reminder.create(
          ReminderType.daily,
          DateTime(2024, 1, 8, 10, 5),
          true,
          1,
          updateTime: DateTime(2024, 1, 8, 9, 0),
        )..id = 6,
      ];

      final result = filterRemindersForNotification(reminders, mondayMorning);

      expect(result.length, 2);
      expect(result.any((r) => r.id == 1), true); // Latest for task 1
      expect(result.any((r) => r.id == 5), true); // Task 5
      // Result should be sorted by updateTime (id 1 before id 5)
      expect(result[0].id, 1);
      expect(result[1].id, 5);
    });
  });
}
