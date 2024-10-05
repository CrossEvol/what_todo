import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/home/side_drawer.dart';
import 'package:flutter_app/pages/tasks/add_task.dart';
import 'package:flutter_app/pages/tasks/bloc/my_task_bloc.dart';
import 'package:flutter_app/pages/tasks/task_completed/task_completed.dart';
import 'package:flutter_app/pages/tasks/task_uncompleted/task_uncompleted.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/pages/tasks/task_widgets.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';

class HomePage extends StatelessWidget {
  final TaskBloc _taskBloc = TaskBloc(TaskDB.get());
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
        title: StreamBuilder<String>(
            initialData: 'Today',
            stream: homeBloc.title,
            builder: (context, snapshot) {
              return Text(
                snapshot.data!,
                key: ValueKey(HomePageKeys.HOME_TITLE),
              );
            }),
        actions: <Widget>[
          StreamBuilder<String>(
            initialData: 'Today',
            stream: homeBloc.title,
            builder: (context, snapshot) {
              return buildPopupMenu(context, snapshot.data!);
            },
          )
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
          await context.adaptiveNavigate(SCREEN.ADD_TASK, AddTaskProvider());
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
            await context.adaptiveNavigate(
                SCREEN.COMPLETED_TASK, TaskCompletedPage());
            _taskBloc.refresh();
            break;
          case MenuItem.TASK_UNCOMPLETED:
            await context.adaptiveNavigate(
                SCREEN.UNCOMPLETED_TASK, TaskUnCompletedPage());
            _taskBloc.refresh();
            break;
          case MenuItem.TASK_POSTPONE:
            _taskBloc.postponeTodayTasks();
            _taskBloc.refresh();
            break;
        }
      },
      itemBuilder: (BuildContext context) {
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
          if (title == 'Today')
            const PopupMenuItem<MenuItem>(
                value: MenuItem.TASK_POSTPONE,
                child: const Text(
                  'Postpone Tasks',
                  key: ValueKey(CompletedTaskPageKeys.POSTPONE_TASKS),
                ))
        ];
      },
    );
  }
}

// This is the type used by the popup menu below.
enum MenuItem { TASK_COMPLETED, TASK_UNCOMPLETED, TASK_POSTPONE }
