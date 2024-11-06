import 'dart:io' show Platform;

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/drift_schema/drift_schema_db.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/profile/profile_db.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/providers/theme_provider.dart';
import 'package:flutter_app/router/router.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogger();
  if (Platform.isWindows) {
    setupWindow();
  }
  // https://drift.simonbinder.eu/docs/getting-started/advanced_dart_tables/#datetime-options
  driftRuntimeOptions.defaultSerializer =
      ValueSerializer.defaults(serializeDateTimeValuesAsString: true);
  await _migrate();
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

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ja');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LabelBloc(LabelDB.get())..add(LoadLabelsEvent()),
        ),
        BlocProvider(
          create: (context) =>
              ProjectBloc(ProjectDB.get())..add(LoadProjectsEvent()),
        ),
        BlocProvider(
          create: (context) =>
              HomeBloc()..add(ApplyFilterEvent("Today", Filter.byToday())),
        ),
        BlocProvider(
          create: (context) => TaskBloc(TaskDB.get())
            ..add(FilterTasksEvent(filter: Filter.byToday())),
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
          create: (_) => SettingsBloc()
            ..add(LoadSettingsEvent())
            ..add(AddSetLocaleFunction(setLocale: setLocale)),
        ),
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
