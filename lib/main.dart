import 'dart:convert';
import 'dart:io' show Platform;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/export/export_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/import/import_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/bloc/reminder/reminder_bloc.dart'
    show ReminderBloc, RemindersInitialEvent;
import 'package:flutter_app/bloc/search/search_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/dao/reminder_db.dart';
import 'package:flutter_app/dao/search_db.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/pages/drift_schema/drift_schema_db.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/profile/profile_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/settings/settings_db.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/models/reminder.dart';
import 'package:flutter_app/models/reminder_type.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/providers/theme_provider.dart';
import 'package:flutter_app/router/router.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_app/utils/shard_prefs_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:window_manager/window_manager.dart';
import 'package:workmanager/workmanager.dart';

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
      final reminderTimeAsToday = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          reminderTime.hour,
          reminderTime.minute);
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
    } else {
      await flutterLocalNotificationsPlugin.show(
          0, 'WhatTodo', 'You have no tasks.', notificationDetails,
          payload: 'no_tasks');
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLogger();
  if (Platform.isWindows) {
    setupWindow();
  }
  // https://drift.simonbinder.eu/docs/getting-started/advanced_dart_tables/#datetime-options
  driftRuntimeOptions.defaultSerializer =
      ValueSerializer.defaults(serializeDateTimeValuesAsString: true);
  await _migrate();
  await setupSharedPreference();

  // Initialize workmanager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Set to false for production
  );

  // Register a periodic task
  Workmanager().registerPeriodicTask(
    "1", // uniqueName
    "simplePeriodicTask", // taskName
    frequency: const Duration(minutes: 15), // Android minimum is 15 minutes
    initialDelay: const Duration(minutes: 1),
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );

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
        final task = await TaskDB.get().getTaskById(taskId);
        if (task != null) {
          goRouter.push('/task/edit', extra: task);
        }
      }
    }
  });

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MyApp(),
  ));
}

Future<void> _migrate() async {
  var schemaDB = DriftSchemaDB.get();
  var existsSchema = await schemaDB.exists();
  if (!existsSchema) {
    schemaDB.createSchema(1);
  }
  // 1->2
  if ((await schemaDB.getMaximalVersion()) == 1) {
    if ((await schemaDB.shouldMigrate(1))) {
      schemaDB.createSchema(2);
      AppDatabase().customStatement(r'''
      WITH numbered_rows AS (
        SELECT 
          id,
          ROW_NUMBER() OVER (ORDER BY id) AS row_num
        FROM task
      )
      UPDATE task
      SET "order" = (
        SELECT row_num * 1000 
        FROM numbered_rows 
        WHERE numbered_rows.id = task.id
      );
      ''');
    }
  }
}

const double windowWidth = 400;
const double windowHeight = 760;

void setupWindow() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    title: 'WhatTodo',
    size: Size(windowWidth, windowHeight),
    minimumSize: Size(windowWidth, windowHeight),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with RouteAware {
  Locale _locale = Locale(prefs.getLocale());

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    var project = Project.inbox();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LabelBloc(LabelDB.get())..add(LoadLabelsEvent()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              ProjectBloc(ProjectDB.get())..add(LoadProjectsEvent()),
        ),
        BlocProvider(
          create: (context) => HomeBloc(TaskDB.get())
            ..add(ApplyFilterEvent(
                project.name,
                Filter.byProject(project.id!)
                    .copyWith(status: TaskStatus.PENDING))),
        ),
        BlocProvider(
          create: (context) => TaskBloc(TaskDB.get())
            ..add(FilterTasksEvent(
                filter: Filter.byProject(project.id)
                    .copyWith(status: TaskStatus.PENDING))),
        ),
        // TODO: it did not load projects at the first time on mobile device
        BlocProvider(
          create: (_) => AdminBloc(
            LabelDB.get(),
            ProjectDB.get(),
          )
            ..add(AdminLoadProjectsEvent())
            ..add(AdminLoadLabelsEvent()),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
            ProfileDB.get(),
          )..add(ProfileLoadEvent()),
        ),
        BlocProvider(
          create: (_) => SettingsBloc(SettingsDB.get())
            ..add(LoadSettingsEvent())
            ..add(AddSetLocaleFunction(setLocale: setLocale)),
          lazy: false,
        ),
        BlocProvider(
            create: (_) =>
                ExportBloc(ProjectDB.get(), LabelDB.get(), TaskDB.get())
                  ..add(LoadExportDataEvent())),
        BlocProvider(
            create: (_) =>
                ImportBloc(ProjectDB.get(), LabelDB.get(), TaskDB.get())),
        BlocProvider(
            create: (_) => SearchBloc(SearchDB.get())..add(ResetSearchEvent())),
        BlocProvider(
            create: (_) => ReminderBloc(reminderDB: ReminderDB.get())
              ..add(RemindersInitialEvent())),
      ],
      child: MaterialApp.router(
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ja'),
          Locale('zh'),
        ],
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeDataStyle,
        routerConfig: goRouter,
      ),
    );
  }
}
