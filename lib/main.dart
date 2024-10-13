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
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/profile/profile_db.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/router/router.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  setupLogger();
  if (Platform.isWindows) {
    setupWindow();
  }
  // https://drift.simonbinder.eu/docs/getting-started/advanced_dart_tables/#datetime-options
  driftRuntimeOptions.defaultSerializer =
      ValueSerializer.defaults(serializeDateTimeValuesAsString: true);
  runApp(MyApp());
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3543DE);
    final theme = ThemeData(
      primaryColor: primaryColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
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
        BlocProvider(
          create: (_) => AdminBloc(
            LabelDB.get(),
            ProjectDB.get(),
          ),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
            ProfileDB.get(),
          )..add(ProfileLoadEvent()),
        ),
        BlocProvider(
          create: (_) => SettingsBloc()
            ..add(
              LoadSettingsEvent(),
            ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            secondary: Colors.purple,
            primary: primaryColor,
          ),
        ),
        routerConfig: goRouter,
      ),
    );
  }
}
