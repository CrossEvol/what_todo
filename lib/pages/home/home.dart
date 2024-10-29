import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';
import 'package:flutter_app/pages/home/side_drawer.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_app/pages/tasks/add_task.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/bloc/my_task_bloc.dart';
import 'package:flutter_app/pages/tasks/edit_task.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_completed/task_completed.dart';
import 'package:flutter_app/pages/tasks/task_uncompleted/task_uncompleted.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/pages/tasks/task_widgets.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class AdaptiveHomePage extends StatelessWidget {
  const AdaptiveHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return context.isWiderScreen() ? WiderHomePage() : HomePage();
  }
}

class WiderHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homeBloc = context.bloc<MyHomeBloc>();
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<SCREEN>(
              stream: homeBloc.screens,
              builder: (context, snapshot) {
                //Refresh side drawer whenever screen is updated
                return SideDrawer();
              }),
          flex: 2,
        ),
        SizedBox(
          width: 0.5,
        ),
        Expanded(
          child: StreamBuilder<SCREEN>(
              stream: homeBloc.screens,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  // ignore: missing_enum_constant_in_switch
                  switch (snapshot.data) {
                    case SCREEN.ABOUT:
                      return AboutUsScreen();
                    case SCREEN.ADD_TASK:
                      return AddTaskProvider();
                    case SCREEN.COMPLETED_TASK:
                      return TaskCompletedPage();
                    case SCREEN.ADD_PROJECT:
                      return AddProjectPage();
                    case SCREEN.ADD_LABEL:
                      return AddLabelPage();
                    case SCREEN.HOME:
                      return HomePage();
                    case SCREEN.UNCOMPLETED_TASK:
                      return TaskUnCompletedPage();
                    case SCREEN.EDIT_TASK:
                      return EditTaskProvider();
                    case null:
                    // TODO: Handle this case.
                  }
                }
                return HomePage();
              }),
          flex: 5,
        )
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  final MyTaskBloc _taskBloc = MyTaskBloc(TaskDB.get());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isWiderScreen = context.isWiderScreen();
    final homeBloc = context.bloc<MyHomeBloc>();
    scheduleMicrotask(() {
      StreamSubscription? _filterSubscription;
      _filterSubscription = homeBloc.filter.listen((filter) {
        _taskBloc.updateFilters(filter);
        //_filterSubscription?.cancel();
      });
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Text(
              state.title,
              key: ValueKey(HomePageKeys.HOME_TITLE),
            );
          },
        ),
        actions: <Widget>[
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return buildPopupMenu(context, state.title);
            },
          ),
        ],
        leading: isWiderScreen
            ? null
            : new IconButton(
                icon: new Icon(
                  Icons.menu,
                  key: ValueKey(SideDrawerKeys.DRAWER),
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        key: ValueKey(HomePageKeys.ADD_NEW_TASK_BUTTON),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.purple,
        onPressed: () async {
          context.go('/task/add');
          // await context.adaptiveNavigate(SCREEN.ADD_TASK, AddTaskProvider());
          _taskBloc.refresh();
        },
      ),
      drawer: isWiderScreen ? null : SideDrawer(),
      body: CustomBlocProvider(
        bloc: _taskBloc,
        child: TasksPage(),
      ),
    );
  }

// This menu button widget updates a _selection field (of type WhyFarther,
// not shown here).
  Widget buildPopupMenu(BuildContext context, String title) {
    return PopupMenuButton<MenuItem>(
      icon: Icon(Icons.adaptive.more),
      key: ValueKey(CompletedTaskPageKeys.POPUP_ACTION),
      onSelected: (MenuItem result) async {
        switch (result) {
          case MenuItem.TASK_COMPLETED:
            context.read<TaskBloc>().add(
                FilterTasksEvent(filter: Filter.byStatus(TaskStatus.COMPLETE)));
            context.go('/task/completed');
            break;
          case MenuItem.TASK_UNCOMPLETED:
            context.read<TaskBloc>().add(
                FilterTasksEvent(filter: Filter.byStatus(TaskStatus.PENDING)));
            context.go('/task/uncompleted');
            break;
          case MenuItem.TASK_POSTPONE:
            context.read<TaskBloc>().add(PostponeTasksEvent());
            break;
          case MenuItem.EXPORTS:
            await _export(context);
            break;
          case MenuItem.IMPORTS:
            _import(context);
            break;
          case MenuItem.ALL_TO_TODAY:
            context.read<TaskBloc>().add(PushAllToTodayEvent());
            context
                .read<HomeBloc>()
                .add(ApplyFilterEvent("Today", Filter.byToday()));
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        final enableImportExport =
            context.read<SettingsBloc>().state.enableImportExport;
        return <PopupMenuEntry<MenuItem>>[
          const PopupMenuItem<MenuItem>(
            value: MenuItem.TASK_COMPLETED,
            child: const Text(
              'Completed Tasks',
              key: ValueKey(CompletedTaskPageKeys.COMPLETED_TASKS),
            ),
          ),
          const PopupMenuItem<MenuItem>(
            value: MenuItem.TASK_UNCOMPLETED,
            child: const Text(
              'Uncompleted Tasks',
              key: ValueKey(CompletedTaskPageKeys.UNCOMPLETED_TASKS),
            ),
          ),
          if (title == 'Inbox')
            const PopupMenuItem<MenuItem>(
                value: MenuItem.ALL_TO_TODAY,
                child: const Text(
                  'All to Today',
                  key: ValueKey(CompletedTaskPageKeys.ALL_TO_TODAY),
                )),
          if (title == 'Today')
            const PopupMenuItem<MenuItem>(
                value: MenuItem.TASK_POSTPONE,
                child: const Text(
                  'Postpone Tasks',
                  key: ValueKey(CompletedTaskPageKeys.POSTPONE_TASKS),
                )),
          if (enableImportExport)
            const PopupMenuItem<MenuItem>(
              value: MenuItem.EXPORTS,
              child: const Text(
                'Exports',
                key: ValueKey(CompletedTaskPageKeys.EXPORT_DATA),
              ),
            ),
          if (enableImportExport)
            const PopupMenuItem<MenuItem>(
              value: MenuItem.IMPORTS,
              child: const Text(
                'Imports',
                key: ValueKey(CompletedTaskPageKeys.IMPORT_DATA),
              ),
            ),
        ];
      },
    );
  }

  Future<void> _export(BuildContext context) async {
    try {
      var tasks = await TaskDB.get().getExports();
      const encoder = JsonEncoder.withIndent('  ');
      var json = encoder.convert(tasks.map((t) => t.toMap()).toList());
      var importPath = await _getImportPath();

      if (importPath != null) {
        var file = File('$importPath');
        await file.writeAsString(json);
      }
      showSnackbar(context, 'Saved to $importPath.');
    } catch (e) {
      showSnackbar(context, 'Error', materialColor: Colors.red);
    }
  }

  Future<String?> _getImportPath() async {
    const filename = 'tasks.json';
    String? dest;

    if (Platform.isAndroid) {
      var directory = await getExternalStorageDirectory();
      dest = directory?.path;
    } else if (Platform.isWindows) {
      var directory = await getApplicationDocumentsDirectory();
      dest = directory.path;
    }

    if (dest == null) {
      return null;
    }

    return p.join(dest, filename);
  }

  Future<void> _import(BuildContext context) async {
    // Call _getImportPath() before showing the dialog
    String? importPath = await _getImportPath();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Initialize the controller with the import path
        TextEditingController filePathController =
            TextEditingController(text: importPath ?? '');
        return AlertDialog(
          title: Text('Import File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: filePathController,
                decoration: InputDecoration(
                  labelText: 'File Path',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    filePathController.text = result.files.single.path!;
                  }
                },
                child: Text('Pick File'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (filePathController.text.isNotEmpty) {
                  File file = File(filePathController.text);
                  String fileContent = await file.readAsString();
                  List<dynamic> jsonData = jsonDecode(fileContent);
                  Set<String> projectNames = {};
                  List<Map<String, dynamic>> taskData = [];
                  for (var task in jsonData) {
                    if (task is Map<String, dynamic>) {
                      projectNames.add(task['projectName']);
                      taskData.add(task);
                    }
                  }
                  await ProjectDB.get().importProjects(projectNames);
                  if (projectNames.isNotEmpty) {
                    context.read<ProjectBloc>().add(RefreshProjectsEvent());
                    context.read<AdminBloc>().add(AdminLoadProjectsEvent());
                  }
                  await TaskDB.get().importTasks(taskData);
                  var filter = context.read<HomeBloc>().state.filter;
                  if (filter != null) {
                    context
                        .read<TaskBloc>()
                        .add(FilterTasksEvent(filter: filter));
                  }
                  Navigator.of(context).pop();
                } else {
                  showSnackbar(context, 'No file selected',
                      materialColor: Colors.red);
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

// This is the type used by the popup menu below.
enum MenuItem {
  TASK_COMPLETED,
  TASK_UNCOMPLETED,
  TASK_POSTPONE,
  EXPORTS,
  IMPORTS,
  ALL_TO_TODAY,
}
