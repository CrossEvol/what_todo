import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dao/reminder_db.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/models/setting_type.dart' show SettingType;
import 'package:flutter_app/pages/settings/settings_db.dart';
import 'package:flutter_app/models/reminder/reminder.dart';
import 'package:flutter_app/models/reminder/reminder_type.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/router/router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart' hide TaskStatus;

import '../pages/settings/setting.dart' show Setting;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    driftRuntimeOptions.defaultSerializer =
        ValueSerializer.defaults(serializeDateTimeValuesAsString: true);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    final settingsDb = SettingsDB.get();
    final notificationSetting =
        await settingsDb.findByName(SettingKeys.ENABLE_NOTIFICATIONS);
    final dailyReminderSetting =
        await settingsDb.findByName(SettingKeys.ENABLE_DAILY_REMINDER);

    // Only process and show notifications if the setting is explicitly 'true'
    if (notificationSetting?.value != 'true') {
      if (kDebugMode) {
        debugPrint('CallbackDispatcher: 通知功能未启用，跳过处理。');
      }
    } else {
      await _processRemindersAndShowNotifications(notificationDetails);
    }

    // Only process and show notifications if the setting is explicitly 'true'
    if (dailyReminderSetting?.value != 'true') {
      if (kDebugMode) {
        debugPrint('CallbackDispatcher: 日常提醒功能未启用，跳过处理。');
      }
    } else {
      await _processDailyReminder(notificationDetails);
    }

    return Future.value(true);
  });
}

Future<void> setupWorkManagerWithStoredInterval() async {
  try {
    final settingsDb = SettingsDB.get();
    final intervalSetting =
        await settingsDb.findByName(SettingKeys.REMINDER_INTERVAL);

    int intervalMinutes = 15; // Default value

    if (intervalSetting != null) {
      // Try to parse the stored value
      final parsedInterval = int.tryParse(intervalSetting.value);
      if (parsedInterval != null &&
          parsedInterval >= 15 &&
          parsedInterval <= 240) {
        intervalMinutes = parsedInterval;
      }
    } else {
      // Create default setting if it doesn't exist
      final defaultSetting = Setting.create(
        key: SettingKeys.REMINDER_INTERVAL,
        value: intervalMinutes.toString(),
        updatedAt: DateTime.now(),
        type: SettingType.IntNumber,
      );
      await settingsDb.createSetting(defaultSetting);
    }

    setupWorkManager(intervalMinutes: intervalMinutes);
  } catch (e) {
    // If there's any error, fall back to default setup
    if (kDebugMode) {
      debugPrint('Error setting up WorkManager with stored interval: $e');
    }
    setupWorkManager(); // Use default 15 minutes
  }
}

/// Filters reminders based on enabled status, type, time window, and priority
///
/// Returns a list of up to 5 reminders that should trigger notifications:
/// 1. Filters to only enabled reminders
/// 2. Filters by reminder type (daily, workday, holiday, once) based on current weekday
/// 3. Filters by time - only reminders within the specified time window
/// 4. Groups by taskId and keeps only the latest reminder per task
/// 5. Sorts by updateTime (newest first) and takes top 5
///
/// Parameters:
/// - [allReminders]: List of all reminders to filter
/// - [currentTime]: The current time to compare against
/// - [timeWindowMinutes]: Time window in minutes (default 15)
///
/// Returns: List of filtered reminders ready to send notifications
List<Reminder> filterRemindersForNotification(
  List<Reminder> allReminders,
  DateTime currentTime, {
  int timeWindowMinutes = 15,
}) {
  final weekday = currentTime.weekday;

  if (kDebugMode) {
    debugPrint(
        'filterRemindersForNotification: Starting with ${allReminders.length} reminders');
  }

  // 1. Filter to only enabled reminders
  final enabledReminders = allReminders.where((r) => r.enable).toList();
  if (kDebugMode) {
    debugPrint(
        'filterRemindersForNotification: Enabled reminders: ${enabledReminders.length}');
  }

  // 2. Filter by type (daily, weekday, holiday, once)
  final remindersFilteredByType = enabledReminders.where((r) {
    switch (r.type) {
      case ReminderType.daily:
        return true;
      case ReminderType.workDay:
        return weekday >= 1 && weekday <= 5;
      case ReminderType.holiday:
        return weekday == 6 || weekday == 7;
      case ReminderType.once:
        return true;
      default:
        return false;
    }
  }).toList();
  if (kDebugMode) {
    debugPrint(
        'filterRemindersForNotification: After type filter: ${remindersFilteredByType.length}');
  }

  // 3. Filter by time (within time window)
  final remindersToSend = remindersFilteredByType.where((r) {
    if (r.remindTime == null) return false;
    final reminderTime = r.remindTime!;
    final reminderTimeAsToday = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    final difference = currentTime.difference(reminderTimeAsToday);
    return difference.inMinutes.abs() <= timeWindowMinutes;
  }).toList();
  if (kDebugMode) {
    debugPrint(
        'filterRemindersForNotification: After time filter: ${remindersToSend.length}');
  }

  // 4. Group by taskId and get the latest one by updateTime
  final remindersByTask = <int, Reminder>{};
  for (final reminder in remindersToSend) {
    if (reminder.taskId != null) {
      if (!remindersByTask.containsKey(reminder.taskId!) ||
          reminder.updateTime!
              .isAfter(remindersByTask[reminder.taskId!]!.updateTime!)) {
        remindersByTask[reminder.taskId!] = reminder;
      }
    }
  }
  if (kDebugMode) {
    debugPrint(
        'filterRemindersForNotification: After grouping by task: ${remindersByTask.values.length}');
  }

  var finalReminders = remindersByTask.values.toList();

  // 5. Sort by updateTime and take top 5
  finalReminders.sort((a, b) => b.updateTime!.compareTo(a.updateTime!));
  if (finalReminders.length > 5) {
    finalReminders = finalReminders.sublist(0, 5);
  }
  if (kDebugMode) {
    debugPrint(
        'filterRemindersForNotification: Final reminders: ${finalReminders.length}');
  }

  return finalReminders;
}

Future<void> _processRemindersAndShowNotifications(
    NotificationDetails notificationDetails) async {
  final reminderDb = ReminderDB.get();
  final settingsDB = SettingsDB.get();
  final setting = await settingsDB.findByName(SettingKeys.REMINDER_INTERVAL);
  final timeWindowMinutes = int.parse(setting?.value ?? "15");
  final taskDb = TaskDB.get();
  final now = tz.TZDateTime.now(tz.local);

  if (kDebugMode) {
    debugPrint('CallbackDispatcher: 开始过滤提醒事项...');
  }

  // Get all reminders and filter them
  final allReminders = await reminderDb.getAllReminders();
  final finalReminders = filterRemindersForNotification(allReminders, now,
      timeWindowMinutes: timeWindowMinutes);

  // Send notifications for filtered reminders
  if (finalReminders.isNotEmpty) {
    for (final reminder in finalReminders) {
      final task = await taskDb.getTaskById(reminder.taskId!);
      if (task != null) {
        final title = task.title;
        final project = task.projectName;
        final labels = task.labelList.map((e) => e.name).join(', ');
        final body = 'Project: $project Labels: $labels';

        await flutterLocalNotificationsPlugin.show(
            task.id!, title, body, notificationDetails,
            payload: 'task_id=${task.id}');

        // Disable reminder if type is "once"
        if (reminder.type == ReminderType.once) {
          await reminderDb.updateReminder(reminder..enable = false);
        }
      }
    }
  }
}

Future<void> _processDailyReminder(
    NotificationDetails notificationDetails) async {
  final taskDb = TaskDB.get();
  final randomTask = await taskDb.getRandomTask();

  if (randomTask != null) {
    final title = randomTask.title;
    final project = randomTask.projectName;
    final labels = randomTask.labelList.map((e) => e.name).join(', ');
    final body = 'Project: $project\nLabels: $labels';

    await flutterLocalNotificationsPlugin.show(
        randomTask.id!, title, body, notificationDetails,
        payload: 'task_id=${randomTask.id}');
  }
}

void setupWorkManager({int? intervalMinutes}) async {
  final interval = intervalMinutes ?? 15;

  try {
    // Initialize workmanager
    Workmanager().initialize(
      callbackDispatcher,
    );

    // Cancel existing task before registering new one
    await Workmanager().cancelByUniqueName("1");

    // Register a periodic task with configurable interval
    await Workmanager().registerPeriodicTask(
      "1", // uniqueName
      "simplePeriodicTask", // taskName
      frequency: Duration(minutes: interval), // Configurable interval
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    if (kDebugMode) {
      debugPrint(
          'WorkManager setup completed with interval: $interval minutes');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('WorkManager setup failed: $e');
    }
    // Re-throw the exception so calling code can handle it
    rethrow;
  }
}

Future<void> reconfigureWorkManager(int intervalMinutes) async {
  try {
    if (kDebugMode) {
      debugPrint(
          'Reconfiguring WorkManager with interval: $intervalMinutes minutes');
    }

    // Cancel existing task
    await Workmanager().cancelByUniqueName("1");

    // Register new task with updated interval
    await Workmanager().registerPeriodicTask(
      "1", // uniqueName
      "simplePeriodicTask", // taskName
      frequency: Duration(minutes: intervalMinutes),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    if (kDebugMode) {
      debugPrint('WorkManager reconfigured successfully.');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('WorkManager reconfiguration failed: $e');
    }
    // Optionally, re-throw or handle the error as needed
    rethrow;
  }
}

Future<void> setupNotification() async {
  // Initialize flutter_local_notifications for the foreground app
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
    // Handle notification tap
    if (notificationResponse.payload != null &&
        notificationResponse.payload!.startsWith('task_id=')) {
      debugPrint('notification payload: ${notificationResponse.payload}');
      final taskIdString = notificationResponse.payload!.split('=')[1];
      final taskId = int.tryParse(taskIdString);
      if (taskId != null) {
        goRouter.push('/task/$taskId/detail');
      }
    }
  });
}
