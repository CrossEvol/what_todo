import 'dart:async' show StreamSubscription;
import 'dart:io' show Platform;

import 'package:drift/drift.dart';
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
import 'package:flutter_app/dao/resource_db.dart';
import 'package:flutter_app/dao/search_db.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/profile/profile_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/settings/settings_db.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/providers/theme_provider.dart';
import 'package:flutter_app/router/router.dart';
import 'package:flutter_app/utils/drift_util.dart' show migrate;
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_app/utils/shard_prefs_util.dart';
import 'package:flutter_app/utils/window_util.dart' show setupWindow;
import 'package:flutter_app/utils/work_manager_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Update system imports
import 'package:flutter_app/bloc/update/update_bloc.dart';
import 'package:flutter_app/repositories/update_repository.dart';
import 'package:flutter_app/services/update_scheduler_service.dart';
import 'package:flutter_app/utils/download_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'bloc/resource/resource_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLogger();
  if (Platform.isWindows) {
    await setupWindow();
  }
  // https://drift.simonbinder.eu/docs/getting-started/advanced_dart_tables/#datetime-options
  driftRuntimeOptions.defaultSerializer =
      ValueSerializer.defaults(serializeDateTimeValuesAsString: true);
  await migrate();
  await setupSharedPreference();

  // Initialize workmanager with stored interval
  await setupWorkManagerWithStoredInterval();
  await setupNotification();

  // Initialize update services
  await setupDownloadManager();

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with RouteAware, WidgetsBindingObserver {
  Locale _locale = Locale(prefs.getLocale());
  bool _schedulerInitialized = false;
  late StreamSubscription _intentSub;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 封装处理分享的逻辑
    void handleSharedFiles(List<SharedMediaFile> files) {
      if (files.isEmpty) return;

      for (var file in files) {
        print(file.toMap());
      }

      // 关键！通过 GlobalKey 获取当前的 context
      final context = rootNavigatorKey.currentContext;

      if (context != null) {
        // 现在你可以安全地访问 BLoC 和 GoRouter 了
        final resourceBloc = context.read<ResourceBloc>();
        // 假设你有一个方法来处理文件
        // resourceBloc.add(AddResourcesFromFilesEvent(files));

        // 跳转到指定页面
        // 假设你有一个路由 '/share-preview' 用来预览分享的内容
        context.go('/about');
      } else {
        // 如果 context 为 null (极少见，可能在 app 启动的极早期)
        // 可以考虑延迟处理或记录日志
        logger.warn(
            "Navigator context not available yet for handling share intent.");
      }
    }

    // 监听 app 运行时收到的分享
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      handleSharedFiles(value);
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // 监听 app 关闭状态下通过分享启动
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        handleSharedFiles(value);
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    UpdateSchedulerService.instance.dispose();
    _intentSub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        UpdateSchedulerService.instance.onAppResumed();
        break;
      case AppLifecycleState.paused:
        UpdateSchedulerService.instance.onAppPaused();
        break;
      default:
        break;
    }
  }

  /// Initialize the update scheduler after BLoC is available
  Future<void> _initializeUpdateScheduler(BuildContext context) async {
    if (_schedulerInitialized) return;

    try {
      final updateBloc = context.read<UpdateBloc>();
      await UpdateSchedulerService.instance.initializeWithLifecycle(
        updateBloc: updateBloc,
      );
      _schedulerInitialized = true;
      logger.info('Update scheduler initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize update scheduler: $e');
    }
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
                project.name, Filter.byStatus(TaskStatus.PENDING))),
        ),
        BlocProvider(
          create: (context) => TaskBloc(TaskDB.get(), ResourceDB.get())
            ..add(
                FilterTasksEvent(filter: Filter.byStatus(TaskStatus.PENDING))),
        ),
        BlocProvider(
          create: (_) => AdminBloc()
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
        BlocProvider(
          create: (_) => UpdateBloc(repository: UpdateRepository()),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => ResourceBloc(ResourceDB.get()),
          lazy: true,
        ),
      ],
      child: Builder(
        builder: (context) {
          // Initialize scheduler after BLoCs are available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeUpdateScheduler(context);
          });

          return MaterialApp.router(
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
          );
        },
      ),
    );
  }
}
