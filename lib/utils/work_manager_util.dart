import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dao/reminder_db.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/pages/settings/settings_db.dart';
import 'package:flutter_app/models/reminder.dart';
import 'package:flutter_app/models/reminder_type.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/router/router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart' hide TaskStatus;

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
      return Future.value(true);
    } else {
      await _processRemindersAndShowNotifications(notificationDetails);
    }

    // Only process and show notifications if the setting is explicitly 'true'
    if (dailyReminderSetting?.value != 'true') {
      if (kDebugMode) {
        debugPrint('CallbackDispatcher: 日常提醒功能未启用，跳过处理。');
      }
      return Future.value(true);
    } else {
      await _processDailyReminder(notificationDetails);
    }

    return Future.value(true);
  });
}

Future<void> _processRemindersAndShowNotifications(
    NotificationDetails notificationDetails) async {
  final reminderDb = ReminderDB.get();
  final taskDb = TaskDB.get();
  final now = tz.TZDateTime.now(tz.local);
  final weekday = now.weekday;

  if (kDebugMode) {
    debugPrint('CallbackDispatcher: 开始过滤提醒事项...');
  }

  // 1. Get all enabled reminders
  final allReminders = await reminderDb.getAllReminders();
  if (kDebugMode) {
    debugPrint(
        'CallbackDispatcher: 所有提醒事项 (${allReminders.length}): ${allReminders.map((reminder) => reminder.toMap()).map((map) => jsonEncode(map)).toList()}');
  }

  final enabledReminders = allReminders.where((r) => r.enable).toList();
  if (kDebugMode) {
    debugPrint(
        'CallbackDispatcher: 启用的提醒事项 (${enabledReminders.length}): ${enabledReminders.map((reminder) => reminder.toMap()).map((map) => jsonEncode(map)).toList()}');
  }

  // 6. Filter by type (daily, weekday, holiday)
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
        'CallbackDispatcher: 按类型过滤后 (${remindersFilteredByType.length}): ${remindersFilteredByType.map((reminder) => reminder.toMap()).map((map) => jsonEncode(map)).toList()}');
  }

  // 4. Filter by time (within 15 minutes)
  final remindersToSend = remindersFilteredByType.where((r) {
    if (r.remindTime == null) return false;
    final reminderTime = r.remindTime!;
    final reminderTimeAsToday = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, reminderTime.hour, reminderTime.minute);
    final difference = now.difference(reminderTimeAsToday);
    return difference.inMinutes.abs() <= 15;
  }).toList();
  if (kDebugMode) {
    debugPrint('CallbackDispatcher: 当前时间为 (${now.toIso8601String()})');
    debugPrint('CallbackDispatcher: 当前时间为 (${now.toString()})');
    debugPrint('CallbackDispatcher: 当前时间为 (${now.millisecondsSinceEpoch})');
    debugPrint(
        'CallbackDispatcher: 按时间过滤后 (${remindersToSend.length}): ${remindersToSend.map((reminder) => reminder.toMap()).map((map) => jsonEncode(map)).toList()}');
  }

  // 3. Group by taskId and get the latest one by updateTime
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
        'CallbackDispatcher: 按任务分组并取最新 (${remindersByTask.values.length}): ${remindersByTask.values.map((reminder) => reminder.toMap()).map((map) => jsonEncode(map)).toList().toList()}');
  }

  var finalReminders = remindersByTask.values.toList();

  // 2. Sort by updateTime and take top 5
  finalReminders.sort((a, b) => b.updateTime!.compareTo(a.updateTime!));
  if (kDebugMode) {
    debugPrint(
        'CallbackDispatcher: 排序前5个 (${finalReminders.length}): ${finalReminders.map((reminder) => reminder.toMap()).map((map) => jsonEncode(map)).toList()}');
  }
  if (finalReminders.length > 5) {
    finalReminders = finalReminders.sublist(0, 5);
  }

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

        // 5. Disable reminder if type is "once"
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
      debugPrint('WorkManager setup completed with interval: $interval minutes');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('WorkManager setup failed: $e');
    }
    // Re-throw the exception so calling code can handle it
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
