import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';
import 'package:flutter_app/pages/home/side_drawer.dart';
import 'package:flutter_app/pages/labels/add_label.dart';
import 'package:flutter_app/pages/projects/add_project.dart';
import 'package:flutter_app/pages/tasks/add_task.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/edit_task.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_completed/task_completed.dart';
import 'package:flutter_app/pages/tasks/task_uncompleted/task_uncompleted.dart';
import 'package:flutter_app/pages/tasks/task_widgets.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_app/utils/localization_ext.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    final homeBloc = context.read<HomeBloc>();
    final screen = homeBloc.state.screen;
    return Row(
      children: [
        Expanded(
          child: SideDrawer(),
          flex: 2,
        ),
        SizedBox(
          width: 0.5,
        ),
        Expanded(
          child: ScreenSelector(screen),
          flex: 5,
        )
      ],
    );
  }

  Widget ScreenSelector(SCREEN? data) {
    if (data != null) {
      // ignore: missing_enum_constant_in_switch
      switch (data) {
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
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();
  late final VoidCallback _scrollListener;

  String get restorationId => 'home_page';

  @override
  void initState() {
    super.initState();

    // Define the scroll listener function
    _scrollListener = () {
      context
          .read<HomeBloc>()
          .add(SaveScrollPositionEvent(_scrollController.offset));
    };

    // Restore saved scroll position on initialization
    final homeBloc = context.read<HomeBloc>();
    final scrollPosition = homeBloc.state.scrollPosition;
    if (scrollPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(scrollPosition);
      });
    }

    // Listen to scroll changes to save position continuously
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Clear the scroll listener before disposing
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWiderScreen = context.isWiderScreen();
    final homeBloc = context.read<HomeBloc>();
    scheduleMicrotask(() {
      StreamSubscription? _filterSubscription;
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Text(
              state.title.localize(context),
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
          // _taskBloc.refresh();
        },
      ),
      drawer: isWiderScreen ? null : SideDrawer(),
      body: TasksPage(scrollController: _scrollController),
    );
  }

// This menu button widget updates a _selection field (of type WhyFarther,
  Widget buildPopupMenu(BuildContext context, String title) {
    final homeBloc = context.read<HomeBloc>();
    final homeState = homeBloc.state;
    final taskBloc = context.read<TaskBloc>();

    return PopupMenuButton<MenuItem>(
      icon: Icon(Icons.adaptive.more),
      key: ValueKey(CompletedTaskPageKeys.POPUP_ACTION),
      onSelected: (MenuItem result) async {
        switch (result) {
          case MenuItem.TASK_COMPLETED:
            homeBloc.add(ApplyFilterEvent(homeState.title,
                homeState.filter!.copyWith(status: TaskStatus.COMPLETE)));
            taskBloc.add(FilterTasksEvent(
                filter:
                    homeState.filter!.copyWith(status: TaskStatus.COMPLETE)));
            // context.go('/task/completed'); // should be removed in later version
            break;
          case MenuItem.TASK_UNCOMPLETED:
            homeBloc.add(ApplyFilterEvent(homeState.title,
                homeState.filter!.copyWith(status: TaskStatus.PENDING)));
            taskBloc.add(FilterTasksEvent(
                filter:
                    homeState.filter!.copyWith(status: TaskStatus.PENDING)));
            // context.go('/task/uncompleted'); // should be removed in later version
            break;
          case MenuItem.TASK_POSTPONE:
            taskBloc.add(PostponeTasksEvent());
            break;
          case MenuItem.ALL_TO_TODAY:
            taskBloc.add(PushAllToTodayEvent());
            context
                .read<HomeBloc>()
                .add(ApplyFilterEvent("Today", Filter.byToday()));
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<MenuItem>>[
          PopupMenuItem<MenuItem>(
            value: MenuItem.TASK_COMPLETED,
            child: Text(
              AppLocalizations.of(context)!.completedTasks,
              key: ValueKey(CompletedTaskPageKeys.COMPLETED_TASKS),
            ),
          ),
          PopupMenuItem<MenuItem>(
            value: MenuItem.TASK_UNCOMPLETED,
            child: Text(
              AppLocalizations.of(context)!.uncompletedTasks,
              key: ValueKey(CompletedTaskPageKeys.UNCOMPLETED_TASKS),
            ),
          ),
          if (title == 'Inbox')
            PopupMenuItem<MenuItem>(
              value: MenuItem.ALL_TO_TODAY,
              child: Text(
                AppLocalizations.of(context)!.allToToday,
                key: ValueKey(CompletedTaskPageKeys.ALL_TO_TODAY),
              ),
            ),
          if (title == 'Today')
            PopupMenuItem<MenuItem>(
              value: MenuItem.TASK_POSTPONE,
              child: Text(
                AppLocalizations.of(context)!.postponeTasks,
                key: ValueKey(CompletedTaskPageKeys.POSTPONE_TASKS),
              ),
            ),
        ];
      },
    );
  }
}

// This is the type used by the popup menu below.
enum MenuItem {
  TASK_COMPLETED,
  TASK_UNCOMPLETED,
  TASK_POSTPONE,
  ALL_TO_TODAY,
}
