import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_app/pages/home/home.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/labels/label_grid.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/profile/profile_page.dart';
import 'package:flutter_app/pages/projects/project_grid.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_app/pages/settings/settings_screen.dart';
import 'package:flutter_app/pages/tasks/add_task.dart';
import 'package:flutter_app/pages/tasks/edit_task.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_completed/task_completed.dart';
import 'package:flutter_app/pages/tasks/task_uncompleted/task_uncompleted.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The route configuration.
final GoRouter goRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        context.read<HomeBloc>().add(LoadTodayCountEvent());
        return CustomBlocProvider(
          bloc: MyHomeBloc(),
          child: AdaptiveHomePage(),
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'about',
          builder: (BuildContext context, GoRouterState state) {
            return AboutUsScreen();
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return SettingsScreen();
          },
        ),
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return ProfilePage();
          },
        ),
        GoRoute(
          path: 'task/add',
          builder: (BuildContext context, GoRouterState state) {
            return AddTaskProvider();
          },
        ),
        GoRoute(
          path: 'task/completed',
          builder: (BuildContext context, GoRouterState state) {
            return TaskCompletedPage();
          },
        ),
        GoRoute(
          path: 'project/add',
          builder: (BuildContext context, GoRouterState state) {
            return AddProjectPage();
          },
        ),
        GoRoute(
          path: 'label/add',
          builder: (BuildContext context, GoRouterState state) {
            return AddLabelPage();
          },
        ),
        GoRoute(
          path: 'project/grid',
          builder: (BuildContext context, GoRouterState state) {
            context.read<AdminBloc>().add(AdminLoadProjectsEvent());
            return ProjectGridPage();
          },
        ),
        GoRoute(
          path: 'label/grid',
          builder: (BuildContext context, GoRouterState state) {
            context.read<AdminBloc>().add(AdminLoadLabelsEvent());
            return LabelGridPage();
          },
        ),
        GoRoute(
          path: 'task/uncompleted',
          builder: (BuildContext context, GoRouterState state) {
            return TaskUnCompletedPage();
          },
        ),
        GoRoute(
          path: 'task/edit',
          builder: (BuildContext context, GoRouterState state) {
            var task = state.extra as Task;
            return EditTaskProvider(
              task: task,
            );
          },
        ),
      ],
    ),
  ],
);
