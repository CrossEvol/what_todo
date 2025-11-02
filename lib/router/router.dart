import 'package:flutter_app/dao/reminder_db.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_app/pages/export/export_page.dart';
import 'package:flutter_app/pages/home/home.dart';
import 'package:flutter_app/pages/import/import_page.dart';
import 'package:flutter_app/pages/labels/add_label.dart';
import 'package:flutter_app/pages/labels/label_grid.dart';
import 'package:flutter_app/pages/order/order_page.dart';
import 'package:flutter_app/pages/profile/profile_page.dart';
import 'package:flutter_app/pages/projects/add_project.dart';
import 'package:flutter_app/pages/projects/project_grid.dart';
import 'package:flutter_app/pages/reminder/reminder_create_page.dart';
import 'package:flutter_app/pages/reminder/reminder_grid.dart';
import 'package:flutter_app/pages/reminder/reminder_update_page.dart';
import 'package:flutter_app/pages/settings/settings_screen.dart';
import 'package:flutter_app/pages/tasks/add_task.dart';
import 'package:flutter_app/pages/tasks/edit_task.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_completed/task_completed.dart';
import 'package:flutter_app/pages/tasks/task_detail.dart';
import 'package:flutter_app/pages/tasks/task_uncompleted/task_uncompleted.dart';
import 'package:flutter_app/pages/tasks/task_grid.dart';
import 'package:flutter_app/pages/update/update_manager_page.dart';
import 'package:flutter_app/pages/resource/resource_manage_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/models/reminder/reminder.dart';

class DefaultGrid extends StatelessWidget {
  const DefaultGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// The route configuration.
final GoRouter goRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        context.read<HomeBloc>().add(LoadTodayCountEvent());
        return AdaptiveHomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'order',
          builder: (BuildContext context, GoRouterState state) {
            return OrderApp();
          },
        ),
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
          path: 'update_manager',
          builder: (BuildContext context, GoRouterState state) {
            return const UpdateManagerPage();
          },
        ),
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return ProfilePage();
          },
        ),
        GoRoute(
          path: 'export',
          builder: (BuildContext context, GoRouterState state) {
            return ExportPage();
          },
        ),
        GoRoute(
          path: 'import',
          builder: (BuildContext context, GoRouterState state) {
            return ImportPage();
          },
        ),
        GoRoute(
            path: 'task',
            builder: (BuildContext context, GoRouterState state) {
              return DefaultGrid();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'add',
                builder: (BuildContext context, GoRouterState state) {
                  return AddTaskProvider();
                },
              ),
              GoRoute(
                path: 'completed',
                builder: (BuildContext context, GoRouterState state) {
                  return TaskCompletedPage();
                },
              ),
              GoRoute(
                path: 'uncompleted',
                builder: (BuildContext context, GoRouterState state) {
                  return TaskUnCompletedPage();
                },
              ),
              GoRoute(
                path: ':id/edit',
                builder: (BuildContext context, GoRouterState state) {
                  final String taskIdValue = state.pathParameters['id'] ?? '';
                  final int taskId = int.parse(taskIdValue);
                  return FutureBuilder(
                    future: Future.wait([
                      TaskDB.get().getTaskById(taskId),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('Task not found');
                      }
                      final task = snapshot.data![0];

                      if (task == null) {
                        return const Text('Task not found');
                      }

                      return EditTaskProvider(
                        task: task,
                      );
                    },
                  );
                },
              ),
              GoRoute(
                path: 'grid',
                builder: (BuildContext context, GoRouterState state) {
                  return TaskGrid();
                },
              ),
              GoRoute(
                path: ':id/detail', // 使用 :id 定义动态参数
                builder: (BuildContext context, GoRouterState state) {
                  final String taskIdValue = state.pathParameters['id'] ?? '';
                  final int taskId = int.parse(taskIdValue);
                  return FutureBuilder(
                    future: Future.wait([
                      TaskDB.get().getTaskById(taskId),
                      ReminderDB.get().getRemindersForTask(taskId)
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('Task not found');
                      }
                      final task = snapshot.data![0] as Task?;
                      final reminders = snapshot.data![1] as List<Reminder>;

                      if (task == null) {
                        return const Text('Task not found');
                      }

                      return TaskDetailPage(task: task, reminders: reminders);
                    },
                  );
                },
              ),
            ]),
        GoRoute(
            path: 'project',
            builder: (BuildContext context, GoRouterState state) {
              return DefaultGrid();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'add',
                builder: (BuildContext context, GoRouterState state) {
                  return AddProjectPage();
                },
              ),
              GoRoute(
                path: 'grid',
                builder: (BuildContext context, GoRouterState state) {
                  context.read<AdminBloc>().add(AdminLoadProjectsEvent());
                  return ProjectGridPage();
                },
              ),
            ]),
        GoRoute(
            path: 'label',
            builder: (BuildContext context, GoRouterState state) {
              return DefaultGrid();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'add',
                builder: (BuildContext context, GoRouterState state) {
                  return AddLabelPage();
                },
              ),
              GoRoute(
                path: 'grid',
                builder: (BuildContext context, GoRouterState state) {
                  context.read<AdminBloc>().add(AdminLoadLabelsEvent());
                  return LabelGridPage();
                },
              ),
            ]),
        GoRoute(
          path: 'reminder',
          builder: (BuildContext context, GoRouterState state) {
            return TaskGrid();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'create',
              builder: (BuildContext context, GoRouterState state) {
                final map = state.extra as Map<String, int?>?;
                return ReminderCreatePage(taskId: map!["taskId"]!);
              },
            ),
            GoRoute(
              path: 'update',
              builder: (BuildContext context, GoRouterState state) {
                final reminder = state.extra as Reminder;
                return ReminderUpdatePage(
                  reminder: reminder,
                );
              },
            ),
            GoRoute(
              path: 'grid',
              builder: (BuildContext context, GoRouterState state) {
                return ReminderGrid();
              },
            ),
          ],
        ),
        GoRoute(
          path: 'resource',
          builder: (BuildContext context, GoRouterState state) {
            return DefaultGrid();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'edit',
              builder: (BuildContext context, GoRouterState state) {
                final taskId = state.uri.queryParameters['taskId'];
                if (taskId == null) {
                  return const Text('Task ID is required');
                }
                return ResourceManagePage(taskId: int.parse(taskId));
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
